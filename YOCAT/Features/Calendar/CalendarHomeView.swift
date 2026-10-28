//
//  CalendarHomeView.swift
//  YOCAT
//
//  홈 탭 — Figma Home-default 시안 기준.
//  구성(위→아래): 헤더(월 손그림 이미지 + thread 토글) · 이번 달 목표 위젯 · 캘린더 그리드.
//  전부 크림 배경 위(카드 없음). 리스트 뷰는 thread 토글로 전환(AppStorage 유지).
//

import SwiftUI
import SwiftData
import UIKit

struct CalendarHomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query private var goals: [MonthlyGoal]
    @AppStorage("homeViewMode") private var viewModeRaw = "calendar"

    @State private var currentMonth: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDay: DaySelection?
    @State private var writeExpanded = false
    @State private var writeDate: Date = Calendar.current.startOfDay(for: .now)

    // 이번 달 목표 인라인 편집
    @State private var editingGoal = false
    @State private var goalDraft = ""
    @FocusState private var goalFocused: Bool
    @State private var showGoalPosePicker = false
    @State private var path = NavigationPath()

    // 월 롤오버 다이얼로그 단계
    enum RolloverStep { case none, askAchieved, askCarryOver }
    @State private var rolloverStep: RolloverStep = .none
    @State private var rolloverChecked = false

    private var activeGoal: MonthlyGoal? { GoalPolicy.activeGoal(goals) }
    private var goalText: String { activeGoal?.text ?? "" }
    private var hasGoalText: Bool { !goalText.isEmpty }

    private var calendar: Calendar {
        var c = Calendar.current
        c.firstWeekday = 2
        return c
    }
    private var isCalendar: Bool { viewModeRaw != "list" }

    private var monthAssetName: String {
        String(format: "Month%02d", calendar.component(.month, from: currentMonth))
    }

    var body: some View {
            NavigationStack(path: $path) {
                ZStack(alignment: .bottom) {
                    Theme.Color.background.ignoresSafeArea()

                    VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                        header
                        if isCalendar {
                            goalWidget
                            MonthCalendarView(
                                month: currentMonth,
                                selectedDay: selectedDay?.date,
                                entriesByDay: entriesByDay,
                                onSelectDay: { day in handleDayTap(day) }
                            )
                            .gesture(monthSwipe)

                            // 선택한 날짜 하단 섹션
                            //  · 기록 있음      → 수련 기록 스레드
                            //  · 기록 없는 지난날 → "이 날은 수련을 기록하지 않았어요"
                            //  · 기록 없는 오늘   → 아래 peek(작성 유도)가 담당
                            if !shownEntries.isEmpty {
                                TodayRecordSection(date: shownDate, entries: shownEntries) {
                                    openWrite(shownDate)
                                }
                                .padding(.top, Theme.Spacing.m)
                            } else if !isShownToday {
                                EmptyRecordSection(date: shownDate) {
                                    openWrite(shownDate)
                                }
                                .padding(.top, Theme.Spacing.m)
                            }

                            Spacer(minLength: 0)
                        } else {
                            listSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, Theme.Spacing.s)

                    // 오늘 + 기록 없음: 작성 유도 peek (탭 → 작성화면 확장)
                    //  · 목표 편집 중(키보드 ↑)엔 하단으로 내려 숨김 — 키패드와 동시에 못 올라옴
                    if isCalendar && !writeExpanded && !editingGoal && isShownToday && shownEntries.isEmpty {
                        TodayPeekCard(date: calendar.startOfDay(for: .now)) {
                            openWrite(calendar.startOfDay(for: .now))
                        }
                        .transition(.move(edge: .bottom))
                    }

                    // 월 롤오버 다이얼로그 (지난 목표 달성/이어감)
                    NoticeOverlay(isPresented: rolloverStep != .none) {
                        rolloverDialog
                    }
                }
                .navigationBarHidden(true)
                .navigationDestination(for: JournalEntry.self) { entry in
                    EntryDetailView(entry: entry)
                }
                .navigationDestination(for: MyPageRoute.self) { _ in MyPageView() }
                .navigationDestination(for: MyPageDest.self) { dest in
                    switch dest {
                    case .journal: JournalThreadView()
                    case .goals:   CompletedGoalsView()
                    }
                }
                .fullScreenCover(isPresented: $writeExpanded) {
                    WriteView(date: writeDate) {
                        writeExpanded = false
                    }
                }
                .sheet(isPresented: $showGoalPosePicker) {
                    AsanaPickerSheet(selectedPoseId: activeGoal?.poseId ?? "") { picked in
                        setGoalPose(picked)
                    }
                }
            }
        .task {
            #if DEBUG
            SampleData.seedIfNeeded(context)
            #endif
            checkRollover()
        }
        .onChange(of: goals.count) { _, _ in checkRollover() }
    }

    // MARK: - 롤오버 다이얼로그

    @ViewBuilder private var rolloverDialog: some View {
        switch rolloverStep {
        case .askAchieved:
            NoticeSheet(
                iconAsset: "GoalDialogPencil",
                title: "지난 달 목표를 달성했나요?",
                message: "달성했다면 새로운 목표를 세워봐요!",
                secondaryTitle: "아니오",
                onSecondary: { withAnimation { rolloverStep = .askCarryOver } },
                primaryTitle: "네",
                onPrimary: { rolloverAchieved() }
            )
        case .askCarryOver:
            NoticeSheet(
                iconAsset: "GoalDialogPencil",
                title: "이번 달도 이 목표를 가져갈까요?",
                message: activeGoal?.text,
                secondaryTitle: "아니오",
                onSecondary: { rolloverReplace() },
                primaryTitle: "네",
                onPrimary: { rolloverCarry() }
            )
        case .none:
            EmptyView()
        }
    }

    private func checkRollover() {
        guard !rolloverChecked, rolloverStep == .none else { return }
        // goals 로드 전이면(activeGoal nil) 표시만 안 하고, 로드되면 onChange로 재시도
        guard let g = activeGoal else { return }
        rolloverChecked = true
        if GoalPolicy.needsRollover(g) {
            withAnimation { rolloverStep = .askAchieved }
        }
    }

    private func rolloverAchieved() {          // ① 네: 달성
        if let g = activeGoal { GoalPolicy.markAchieved(g, context: context) }
        withAnimation { rolloverStep = .none }
        startEditingGoal()                     // 새 목표 작성
    }

    private func rolloverCarry() {             // ②-네: 이어감
        if let g = activeGoal { GoalPolicy.carryOver(g, context: context) }
        withAnimation { rolloverStep = .none }
    }

    private func rolloverReplace() {           // ②-아니오: 새 목표
        if let g = activeGoal {
            g.status = .failed
            g.updatedAt = .now
            try? context.save()
        }
        withAnimation { rolloverStep = .none }
        startEditingGoal()                     // 새 목표 작성
    }

    private var today: Date { calendar.startOfDay(for: .now) }

    /// 하단 섹션이 표시하는 날짜 (선택한 날짜, 없으면 오늘)
    private var shownDate: Date { selectedDay.map { calendar.startOfDay(for: $0.date) } ?? today }
    private var isShownToday: Bool { calendar.isDate(shownDate, inSameDayAs: today) }

    /// 표시 날짜의 기록 (첫 수련 → 이후 순, 오름차순)
    private var shownEntries: [JournalEntry] {
        (entriesByDay[shownDate] ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    /// 캘린더 날짜 탭: 기록 없는 과거·오늘 → 바로 작성 / 그 외 → 선택
    private func handleDayTap(_ day: Date) {
        let d = calendar.startOfDay(for: day)
        selectedDay = DaySelection(date: d)
        let hasRecord = !(entriesByDay[d] ?? []).isEmpty
        if !hasRecord && d <= today {
            openWrite(d)                 // 기록 없는 과거/오늘 → 작성화면
        }
    }

    /// 지정 날짜로 작성화면 열기
    private func openWrite(_ date: Date) {
        writeDate = calendar.startOfDay(for: date)
        withAnimation(.easeOut(duration: 0.45)) { writeExpanded = true }
    }

    // MARK: - 헤더 (월 손그림 이미지 + 마이페이지 진입)
    private var header: some View {
        HStack(alignment: .center) {          // 월 이미지 ↔ 아이콘 상하 중앙정렬
            Image(monthAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 80)   // 월 숫자 영역 (이미지도 프레임에 맞춰 스케일)
            Spacer()
            AppIconButton(icon: .asset("MyPageEntryIcon")) {   // 마이페이지(내 요가존)
                path.append(MyPageRoute.myPage)
            }
        }
    }

    // MARK: - 이번 달 목표 위젯 (인라인 편집: 빈 상태 / 작성 중 / 작성 완료)
    private var goalWidget: some View {
        HStack(alignment: .bottom) {          // 하단 정렬 (Figma: 텍스트 블록 bottom = 이미지 bottom)
            VStack(alignment: .leading, spacing: 8) {
                Text("이번 달 목표")
                    .textStyle(.caption2)                 // 13 (Figma Caption2)
                    .foregroundStyle(Theme.Color.text)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.Color.surfaceAlt, in: Capsule())

                if editingGoal {
                    // 작성 중: 인라인 TextField + 커서 + 키보드
                    TextField("어떤 것에 집중하고 싶나요?", text: $goalDraft)
                        .textStyle(.body)
                        .foregroundStyle(Theme.Color.text)
                        .tint(Theme.Color.text)
                        .focused($goalFocused)
                        .submitLabel(.done)
                        .onSubmit { commitGoal() }
                        .frame(maxWidth: 220, alignment: .leading)
                } else {
                    // 빈 상태(플레이스홀더 + 연필) / 작성 완료(목표 텍스트만, 연필 없음)
                    Button { startEditingGoal() } label: {
                        HStack(spacing: 6) {
                            Text(hasGoalText ? goalText : "어떤 것에 집중하고 싶나요?")
                                .textStyle(.body)
                                .foregroundStyle(hasGoalText ? Theme.Color.text : Color(white: 0.616))
                            if !hasGoalText {
                                // 미작성 시에만 연필 노출 (작성 완료 시엔 텍스트만, 탭하면 편집)
                                Image("EditIcon")
                                    .renderingMode(.template)
                                    .resizable().scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Theme.Color.text)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)            // 라벨+텍스트 래퍼 상하 8 패딩 (Figma 23:794)
            Spacer()
            // 목표 대표 자세 고양이 — 탭하면 아사나 피커로 변경
            Button { showGoalPosePicker = true } label: {
                goalPoseImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 96)
        .onChange(of: goalFocused) { _, focused in
            if !focused && editingGoal { commitGoal() }   // 탭 아웃 시 저장
        }
    }

    /// 목표 대표 자세 이미지 (자세별 에셋 있으면 사용, 없으면 기본 고양이)
    private var goalPoseImage: Image {
        if let pid = activeGoal?.poseId,
           let ui = UIImage(named: PoseCatArt.assetName(for: pid)) {
            return Image(uiImage: ui)
        }
        return Image("PoseCatDefault")
    }

    private func setGoalPose(_ poseId: String) {
        if let g = activeGoal {
            g.poseId = poseId
            g.updatedAt = .now
            try? context.save()
        } else {
            // 목표 텍스트는 없지만 이미지만 먼저 지정한 경우
            let g = MonthlyGoal(text: "", poseId: poseId, startMonth: .now)
            context.insert(g)
            try? context.save()
        }
    }

    private func startEditingGoal() {
        goalDraft = activeGoal?.text ?? ""
        withAnimation(.easeOut(duration: 0.25)) { editingGoal = true }   // 하단 카드 내려감
        goalFocused = true
    }

    private func commitGoal() {
        let text = goalDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        withAnimation(.easeOut(duration: 0.25)) { editingGoal = false }  // 하단 카드 다시 올라옴
        goalFocused = false
        guard !text.isEmpty else { return }   // 빈 값이면 저장 안 함
        if let g = activeGoal {
            g.text = text
            g.updatedAt = .now
            try? context.save()
        } else {
            GoalPolicy.setInitial(text: text, context: context)
        }
    }

    // MARK: - 리스트 뷰
    private var listSection: some View {
        Group {
            if entries.isEmpty {
                EmptyStateView(
                    systemImage: "list.bullet.rectangle",
                    title: "아직 기록이 없어요",
                    message: "수련하고 돌아와요"
                )
                .frame(maxWidth: .infinity)
                .padding(.top, Theme.Spacing.xxl)
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.m) {
                        ForEach(entries) { entry in
                            NavigationLink(value: entry) {
                                JournalEntryCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 월 이동 (좌우 스와이프)
    private var monthSwipe: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height),
                      abs(value.translation.width) > 50 else { return }
                changeMonth(value.translation.width < 0 ? 1 : -1)
            }
    }

    private func changeMonth(_ delta: Int) {
        if let next = calendar.date(byAdding: .month, value: delta, to: currentMonth) {
            withAnimation { currentMonth = next }
        }
    }

    private var entriesByDay: [Date: [JournalEntry]] {
        Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
            .mapValues { $0.sorted { $0.createdAt > $1.createdAt } }
    }
}
