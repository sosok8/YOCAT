//
//  QuickEntrySheet.swift
//  YOCAT
//
//  캘린더에서 날짜를 탭하면 반쯤 올라오는 빠른 기록 패널 (.medium).
//  - 기록 있으면: 그날 기록들 미리보기 → 탭 시 상세
//  - 기록 없으면: 메모 + 자세 선택 → 닫으면 자동 저장, 또는 상세 작성으로 인계
//

import SwiftUI
import SwiftData

struct QuickEntrySheet: View {
    let date: Date

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var dayEntries: [JournalEntry]

    @State private var memo = ""
    @State private var featuredPoseId: String?
    @State private var showPosePicker = false
    @State private var editorConfig: EditorConfig?
    @State private var didHandoff = false

    init(date: Date) {
        self.date = date
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        _dayEntries = Query(
            filter: #Predicate<JournalEntry> { $0.date >= start && $0.date < end },
            sort: \JournalEntry.createdAt,
            order: .reverse
        )
    }

    var body: some View {
        NavigationStack {
            AppScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                        Text(DateFormatting.dayLong.string(from: date))
                            .font(Theme.Font.title)
                            .foregroundStyle(Theme.Color.text)

                        if dayEntries.isEmpty {
                            quickAddSection
                        } else {
                            existingSection
                        }
                    }
                    .padding(Theme.Spacing.l)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { dismiss() }.tint(Theme.Color.text)
                }
            }
            .navigationDestination(for: JournalEntry.self) { entry in
                EntryDetailView(entry: entry)
            }
            .sheet(isPresented: $showPosePicker) {
                PosePickerSheet(selectedPoseId: $featuredPoseId)
            }
            .sheet(item: $editorConfig) { config in
                EntryEditorView(config: config)
            }
        }
        .presentationDetents([.medium, .large])
        .onDisappear { autosaveIfNeeded() }
    }

    // MARK: - 기존 기록
    private var existingSection: some View {
        VStack(spacing: Theme.Spacing.m) {
            ForEach(dayEntries) { entry in
                NavigationLink(value: entry) {
                    JournalEntryCard(entry: entry)
                }
                .buttonStyle(.plain)
            }
            AppButton(title: "이 날 기록 추가", kind: .ghost, systemImage: "plus") {
                editorConfig = EditorConfig(date: date)
            }
        }
    }

    // MARK: - 빠른 작성
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            AppTextField(placeholder: "오늘 수련은 어땠나요?", text: $memo, axis: .vertical)
                .frame(minHeight: 72, alignment: .top)

            HStack(spacing: Theme.Spacing.m) {
                if let fid = featuredPoseId {
                    CatThumbnail(poseId: fid, size: 56)
                        .id(fid)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
                Button {
                    showPosePicker = true
                } label: {
                    Label(
                        featuredPoseId.flatMap { PoseCatalog.pose(for: $0)?.nameKo } ?? "자세 선택",
                        systemImage: "pawprint.fill"
                    )
                    .font(Theme.Font.headline)
                    .foregroundStyle(Theme.Color.text)
                    .padding(.horizontal, Theme.Spacing.l)
                    .padding(.vertical, Theme.Spacing.m)
                    .frame(maxWidth: .infinity)
                    .background(Theme.Color.surfaceAlt)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.72), value: featuredPoseId)

            AppButton(title: "상세 작성 →", kind: .primary) {
                didHandoff = true
                editorConfig = EditorConfig(
                    date: date,
                    prefillMemo: memo,
                    prefillPoseIds: featuredPoseId.map { [$0] } ?? [],
                    prefillFeaturedPoseId: featuredPoseId
                )
            }
        }
    }

    // 닫을 때 자동 저장 (상세 작성으로 인계한 경우 제외)
    private func autosaveIfNeeded() {
        guard !didHandoff else { return }
        let trimmed = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || featuredPoseId != nil else { return }
        let entry = JournalEntry(
            date: date,
            memo: trimmed,
            poseIds: featuredPoseId.map { [$0] } ?? [],
            featuredPoseId: featuredPoseId ?? ""
        )
        context.insert(entry)
    }
}
