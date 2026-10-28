//
//  HomeBottomSheet.swift
//  YOCAT
//
//  홈 하단 바텀시트 관련 뷰.
//   · TodayPeekCard : 당일 기록이 없을 때 뜨는 peek (탭 → 작성 확장)
//   · WriteView     : 전체화면 작성 화면 (Figma Home-write 65:6500)
//  peek 탭 시 WriteView가 아래에서 확장되며 전환된다. (프로토타입 58:2783 → 65:6500)
//

import SwiftUI
import SwiftData
import UIKit
import PhotosUI

private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?
        .windows.first(where: { $0.isKeyWindow })
}

/// 키 윈도우 safe area inset (오버레이가 safe area를 무시할 때 신뢰 가능한 값)
private func keyWindowSafeInsets() -> UIEdgeInsets {
    keyWindow()?.safeAreaInsets ?? .zero
}

/// 키 윈도우 높이 (키보드 프레임 좌표계와 동일)
private func keyWindowHeight() -> CGFloat {
    keyWindow()?.bounds.height ?? UIScreen.main.bounds.height
}

// MARK: - Peek 카드

struct TodayPeekCard: View {
    let date: Date
    var onTap: () -> Void

    private var cal: Calendar { Calendar.current }
    private var dayNumber: Int { cal.component(.day, from: date) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragHandle()

            StrokeText(text: "\(dayNumber)일", style: .title1, radius: 0.5)
                .padding(.leading, 24)
                .padding(.top, 9)          // DragHandle(28)로 교체하며 21→9 (위치 유지)

            Text("오늘 수련은..")
                .textStyle(.headline)
                .foregroundStyle(Color(white: 0.616))
                .padding(.leading, 24)
                .padding(.top, 12)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 182)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 50, topTrailingRadius: 50)
                .fill(Theme.Color.surface)
                .padding(.bottom, -140)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - 오늘 기록 상태 (당일 수련 기록이 있을 때) — Figma 58-2840
//
// 캘린더 아래 구분선 → 날짜(+추가 버튼) → 수련 기록 스레드.

/// 구분선 + 날짜(숫자+요일) + 우측 추가(+) 버튼 — 기록/빈 상태 공용 헤더.
struct RecordSectionHeader: View {
    let date: Date
    var onAdd: () -> Void

    private var cal: Calendar { Calendar.current }
    private var dayNumber: Int { cal.component(.day, from: date) }
    private var weekday: String {
        ["일", "월", "화", "수", "목", "금", "토"][cal.component(.weekday, from: date) - 1]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Theme.Color.border)
                .frame(height: 2)
                .padding(.bottom, 20)

            HStack(alignment: .center) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    StrokeText(text: "\(dayNumber)", style: .largeTitle, radius: 0.5)
                    Text(weekday)
                        .textStyle(.title2)
                        .foregroundStyle(Color(white: 0.616))
                }
                Spacer()
                Button(action: onAdd) {
                    Image("PlusIcon")
                        .renderingMode(.template)
                        .resizable().scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Theme.Color.text)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TodayRecordSection: View {
    let date: Date
    /// 첫 수련 → 이후 순서(오름차순)
    let entries: [JournalEntry]
    var onAdd: () -> Void

    /// "N번째 수련" 제목 색 (Figma texttertiary #959183)
    private static let titleColor = Theme.Color.textTertiary   // #959183

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RecordSectionHeader(date: date, onAdd: onAdd)
                .padding(.bottom, 20)

            // 수련 기록 스레드 (탭 → 상세)
            VStack(alignment: .leading, spacing: 32) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                    NavigationLink(value: entry) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Self.ordinalTitle(idx))
                                .textStyle(.caption1)                       // 14
                                .foregroundStyle(Self.titleColor)           // #959183 회색
                            if !entry.memo.isEmpty {
                                Text(entry.memo)
                                    .textStyle(.body)                       // 16
                                    .foregroundStyle(Theme.Color.text)      // black
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private static let ordinals = [
        "첫 번째", "두 번째", "세 번째", "네 번째", "다섯 번째",
        "여섯 번째", "일곱 번째", "여덟 번째", "아홉 번째", "열 번째",
    ]
    static func ordinalTitle(_ i: Int) -> String {
        (i < ordinals.count ? ordinals[i] : "\(i + 1)번째") + " 수련"
    }
}

/// 기록 없는 지난 날짜를 선택했을 때 (Figma 104-6426)
struct EmptyRecordSection: View {
    let date: Date
    var onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RecordSectionHeader(date: date, onAdd: onAdd)
                .padding(.bottom, 20)

            Text("이 날은 수련을 기록하지 않았어요")
                .textStyle(.body)
                .foregroundStyle(Color(white: 0.616))
        }
    }
}

// MARK: - 전체화면 작성

struct WriteView: View {
    let date: Date
    /// 편집 대상. nil이면 새 기록 작성.
    var entry: JournalEntry?
    var onClose: () -> Void

    init(date: Date, entry: JournalEntry? = nil, onClose: @escaping () -> Void) {
        self.date = date
        self.entry = entry
        self.onClose = onClose
        _memo = State(initialValue: entry?.memo ?? "")
        _photos = State(initialValue: entry?.photos ?? [])
        _featuredPoseId = State(initialValue: entry?.featuredPoseId ?? "")
    }

    private var topInset: CGFloat { keyWindowSafeInsets().top }
    private var bottomInset: CGFloat { keyWindowSafeInsets().bottom }

    @Environment(\.modelContext) private var context
    @State private var memo = ""
    @State private var memoHeight: CGFloat = 140   // 메모 높이(글 길이에 따라 확장)
    @State private var featuredPoseId = ""   // 빈 값 = 미선택
    @State private var showAsanaSheet = false

    // 사진 첨부
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var photos: [Data] = []
    @State private var showPhotoPicker = false

    private var cal: Calendar { Calendar.current }
    private var dayNumber: Int { cal.component(.day, from: date) }
    private var weekday: String {
        ["일", "월", "화", "수", "목", "금", "토"][cal.component(.weekday, from: date) - 1]
    }

    var body: some View {
        VStack(spacing: 0) {
            // app bar (56pt, 아이콘 44×44 중앙정렬) — Figma app bar
            HStack {
                AppIconButton(icon: .system("chevron.left"), style: .background) { onClose() }
                Spacer()
                Button(action: save) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.Color.text))
                }
                .buttonStyle(.plain)
            }
            .frame(height: 56)
            .padding(.horizontal, 20)

            ScrollView {
              VStack(spacing: 0) {
                // 날짜 (31 목)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    StrokeText(text: "\(dayNumber)", style: .largeTitle, radius: 0.5)
                    Text(weekday)
                        .textStyle(.title2)
                        .foregroundStyle(Color(white: 0.616))
                }
                .padding(.top, 8)          // 20 → 8: 날짜·아사나·입력부 전체를 12px 위로

                // 대표 자세 + "오늘의 아사나 +" (탭 → 자세 선택 시트)
                VStack(spacing: 16) {
                    Image("PoseCatDefault")
                        .resizable().scaledToFit()
                        .frame(width: 120, height: 120)

                    Button { showAsanaSheet = true } label: {
                        if let name = PoseCatalog.pose(for: featuredPoseId)?.nameKo {
                            // 선택됨 → 자세명
                            StrokeText(text: name, style: .body, color: Theme.Color.text, radius: 0.2)
                        } else {
                            // 미선택 → "오늘의 아사나 +"
                            HStack(spacing: 6) {
                                StrokeText(text: "오늘의 아사나",
                                           style: .body,
                                           color: Color(white: 0.616),
                                           radius: 0.2)
                                Image("PlusIcon")
                                    .renderingMode(.template)
                                    .resizable().scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color(white: 0.616))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)          // 날짜 ↔ 아사나 영역 간격 (20 → 10)

                // 메모 — 글 길이만큼 높이가 늘어남(스크롤뷰 안). 툴바는 inputAccessoryView로 하단 고정/키보드 동반.
                ZStack(alignment: .topLeading) {
                    if memo.isEmpty {
                        Text("오늘의 수련은..")
                            .textStyle(.body)
                            .foregroundStyle(Color(white: 0.616))
                            .allowsHitTesting(false)
                    }
                    MemoEditor(text: $memo,
                               onPhoto: { showPhotoPicker = true },
                               onAsana: { showAsanaSheet = true },
                               onHeightChange: { memoHeight = $0 })
                }
                .frame(height: max(140, memoHeight), alignment: .topLeading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // 첨부 사진 (150×150, 라운드 20, 가로 스크롤) — 텍스트 아래로 흐름
                if !photos.isEmpty {
                    photoStrip
                        .frame(height: 150)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
              }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Color.surface.ignoresSafeArea())
        .photosPicker(isPresented: $showPhotoPicker,
                      selection: $pickerItems,
                      maxSelectionCount: 10,
                      matching: .images)
        .onChange(of: pickerItems) { _, items in
            Task { await appendPhotos(items) }
        }
        .sheet(isPresented: $showAsanaSheet) {
            AsanaPickerSheet(selectedPoseId: featuredPoseId) { picked in
                featuredPoseId = picked
            }
        }
    }

    // MARK: 사진 썸네일 (150×150, 라운드 20, 가로 스크롤)
    private var photoStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(photos.enumerated()), id: \.offset) { idx, data in
                    if let ui = UIImage(data: data) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: ui)
                                .resizable().scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            Button { removePhoto(at: idx) } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white, .black.opacity(0.45))
                            }
                            .buttonStyle(.plain)
                            .padding(6)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    /// 선택한 사진을 기존 목록에 추가(누적)하고 picker 선택은 비운다.
    /// (편집 시 기존 사진을 유지하면서 추가할 수 있도록 append 방식)
    private func appendPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        var added: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data),
               let jpeg = ui.jpegData(compressionQuality: 0.8) {
                added.append(jpeg)
            }
        }
        await MainActor.run {
            photos.append(contentsOf: added)
            pickerItems = []
        }
    }

    private func removePhoto(at idx: Int) {
        guard photos.indices.contains(idx) else { return }
        photos.remove(at: idx)
    }

    private func save() {
        if let entry {
            // 편집: 기존 기록 갱신
            entry.memo = memo
            entry.photos = photos
            entry.featuredPoseId = featuredPoseId
            entry.updatedAt = .now
        } else {
            // 새 기록
            let newEntry = JournalEntry(
                date: cal.startOfDay(for: date),
                memo: memo,
                featuredPoseId: featuredPoseId,
                photos: photos
            )
            context.insert(newEntry)
        }
        try? context.save()
        onClose()
    }
}

// MARK: - 툴바 행 (사진 / 아사나) — 하단 고정 & 키보드 액세서리 공용

struct WriteToolbarRow: View {
    /// 우측 키보드 토글 버튼 아이콘. nil이면 버튼 없음.
    /// 키보드 올라옴 → "KeyboardDismiss"(내리기), 내려감 → "KeyboardRaise"(올리기)
    var keyboardIcon: String? = nil
    var onKeyboardButton: () -> Void = {}
    var onPhoto: () -> Void = {}
    var onAsana: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {                 // 그룹 간 간격 12 (Figma 65:6363)
            Button(action: onPhoto)  { item(text: "사진", icon: "ToolbarAlbum") }
                .buttonStyle(.plain)
            Button(action: onAsana) { item(text: "아사나", icon: "ToolbarAsana") }
                .buttonStyle(.plain)
            Spacer()
            if let name = keyboardIcon {
                Button(action: onKeyboardButton) {
                    icon(name)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)               // 높이 50 = 아이콘 24 + 상하 13 (Figma)
        .frame(maxWidth: .infinity)
    }

    private func item(text: String, icon iconName: String) -> some View {
        HStack(spacing: 4) {                  // 텍스트-아이콘 간격 4 (Figma)
            Text(text).textStyle(.headline).foregroundStyle(Theme.Color.text)
            icon(iconName)
        }
    }

    private func icon(_ name: String) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable().scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundStyle(Theme.Color.text)
    }
}

// MARK: - 메모 입력 (단일 툴바 sticky inputAccessoryView)
//
// 하나의 툴바만 사용한다. 툴바는 뷰컨트롤러의 inputAccessoryView 로 두고,
//  · 편집 중  : textView가 first responder → 키보드 위에 툴바가 올라붙음
//  · 편집 종료: 뷰컨트롤러가 first responder → 같은 툴바가 화면 하단에 고정
// 동일한 뷰 인스턴스가 두 응답자 사이를 오가므로 자연스럽게 이어진다.

struct MemoEditor: UIViewControllerRepresentable {
    @Binding var text: String
    var onPhoto: () -> Void = {}
    var onAsana: () -> Void = {}
    var onHeightChange: (CGFloat) -> Void = { _ in }

    func makeUIViewController(context: Context) -> MemoInputController {
        let vc = MemoInputController()
        vc.onTextChange = { text = $0 }
        vc.onPhoto = onPhoto
        vc.onAsana = onAsana
        vc.onHeightChange = onHeightChange
        return vc
    }

    func updateUIViewController(_ vc: MemoInputController, context: Context) {
        vc.onPhoto = onPhoto
        vc.onAsana = onAsana
        vc.onHeightChange = onHeightChange
        vc.setText(text)
    }
}

/// 편집이 끝나도 툴바(inputAccessoryView)를 하단에 유지하기 위해
/// 스스로 first responder가 될 수 있는 컨트롤러.
final class MemoInputController: UIViewController, UITextViewDelegate {
    let textView = UITextView()
    private var barHost: UIHostingController<AnyView>!
    private var keyboardUp = false
    var onTextChange: ((String) -> Void)?
    var onPhoto: (() -> Void)?
    var onAsana: (() -> Void)?
    var onHeightChange: ((CGFloat) -> Void)?

    override var canBecomeFirstResponder: Bool { true }
    override var inputAccessoryView: UIView? { barHost?.view }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        textView.delegate = self
        textView.backgroundColor = .clear
        textView.textColor = UIColor(Theme.Color.text)
        textView.tintColor = UIColor(Theme.Color.text)
        textView.font = UIFont(name: "GriunOnhandwriting-Regular", size: 16)
            ?? .systemFont(ofSize: 16)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false        // 바깥 ScrollView가 스크롤 담당 → 높이는 글 길이에 맞춰 확장
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        barHost = UIHostingController(rootView: makeBar())
        barHost.view.backgroundColor = UIColor(Theme.Color.surface)
        sizeBar()
        // 편집 중엔 textView가, 편집 종료 후엔 컨트롤러가 같은 툴바를 액세서리로 제공
        textView.inputAccessoryView = barHost.view
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 진입 시 하단에 툴바를 먼저 띄운 뒤 키보드를 올린다.
        if !textView.isFirstResponder { becomeFirstResponder() }
        textView.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reportHeight()
    }

    /// 현재 폭 기준 텍스트 내용 높이를 바깥(SwiftUI)에 보고 → 메모 영역이 글 길이만큼 늘어남.
    private func reportHeight() {
        let w = textView.bounds.width
        guard w > 0 else { return }
        let h = textView.sizeThatFits(CGSize(width: w, height: .greatestFiniteMagnitude)).height
        onHeightChange?(ceil(h))
    }

    // MARK: 툴바
    private func makeBar() -> AnyView {
        AnyView(
            WriteToolbarRow(
                keyboardIcon: keyboardUp ? "KeyboardDismiss" : "KeyboardRaise",
                onKeyboardButton: { [weak self] in
                    guard let self else { return }
                    self.keyboardUp ? self.lowerKeyboard() : self.raiseKeyboard()
                },
                onPhoto: { [weak self] in self?.onPhoto?() },
                onAsana: { [weak self] in self?.onAsana?() }
            )
            .background(Theme.Color.surface)
        )
    }

    private func sizeBar() {
        let w = UIScreen.main.bounds.width
        let h = barHost.view.systemLayoutSizeFitting(
            CGSize(width: w, height: UIView.layoutFittingCompressedSize.height)
        ).height
        barHost.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        barHost.view.autoresizingMask = .flexibleWidth
    }

    private func refreshBar() { barHost.rootView = makeBar() }

    private func raiseKeyboard() { textView.becomeFirstResponder() }

    private func lowerKeyboard() {
        textView.resignFirstResponder()
        becomeFirstResponder()          // 툴바를 하단에 유지
    }

    // MARK: 상태 동기화
    func setText(_ t: String) {
        if textView.text != t { textView.text = t; reportHeight() }
    }

    // MARK: UITextViewDelegate
    func textViewDidChange(_ tv: UITextView) { onTextChange?(tv.text); reportHeight() }
    func textViewDidBeginEditing(_ tv: UITextView) { keyboardUp = true; refreshBar() }
    func textViewDidEndEditing(_ tv: UITextView) { keyboardUp = false; refreshBar() }
}
