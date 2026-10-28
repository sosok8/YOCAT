//
//  AsanaPickerSheet.swift
//  YOCAT
//
//  아사나(자세) 선택 바텀시트 (Figma 58-3349).
//  · 헤더: 검색 버튼 + 카테고리 탭(전체 / 즐겨찾기, 추후 확장)
//  · 3열 그리드: 자세 카드(라디오 · 하트 · 고양이 · 이름)
//  · 자세 탭 → 즉시 선택 + 시트 닫힘 → "오늘의 아사나" 반영
//  · 하트 → 즐겨찾기 토글(영구 저장) → 즐겨찾기 탭에 반영
//

import SwiftUI

struct AsanaPickerSheet: View {
    /// 현재 선택된 자세(라디오 강조용)
    let selectedPoseId: String
    /// 자세 선택 콜백 (선택 후 시트 자동 닫힘)
    var onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("favoriteAsanas") private var favoritesCSV = ""

    @State private var tab: Tab = .all
    @State private var searching = false
    @State private var query = ""

    enum Tab: Hashable { case all, favorites }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            DragHandle()
            header
            grid
        }
        .background(Theme.Color.surface)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - 헤더 (검색 버튼 + 탭  ↔  검색 필드)
    private var header: some View {
        Group {
            if searching {
                searchField
            } else {
                HStack(spacing: 12) {
                    searchButton
                    tabPill("전체", .all)
                    tabPill("즐겨찾기", .favorites)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    // 검색 버튼 (원형 테두리)
    private var searchButton: some View {
        Button { withAnimation { searching = true } } label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color(white: 0.4))
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Theme.Color.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // 탭 pill: 선택 = 어두운 채움 / 미선택 = 회색 테두리
    private func tabPill(_ title: String, _ t: Tab) -> some View {
        let selected = tab == t
        return Button { withAnimation { tab = t } } label: {
            Text(title)
                .textStyle(.headline)
                .foregroundStyle(selected ? .white : Theme.Color.text)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(selected ? Theme.Color.text : Color.clear, in: Capsule())
                .overlay {
                    if !selected { Capsule().stroke(Theme.Color.border, lineWidth: 1) }
                }
        }
        .buttonStyle(.plain)
    }

    // 검색 필드 (탭 자리 교체) — 캡슐 테두리 + 돋보기 + 입력 + X
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundStyle(Color(white: 0.5))
            TextField("어떤 아사나가있나요?", text: $query)
                .textStyle(.body)
                .foregroundStyle(Theme.Color.text)
                .tint(Theme.Color.text)
            Button {
                withAnimation { searching = false; query = "" }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.Color.text)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .overlay(Capsule().stroke(Theme.Color.border, lineWidth: 1))
    }

    // MARK: - 그리드
    private var grid: some View {
        ScrollView {
            if filteredPoses.isEmpty {
                Text(searching ? "검색 결과가 없어요" : "즐겨찾기한 자세가 없어요")
                    .textStyle(.body)
                    .foregroundStyle(Color(white: 0.616))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(filteredPoses) { pose in
                        poseCard(pose)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 24)
            }
        }
    }

    /// 즐겨찾기 하트 강조색 (Figma 11AAD7)
    private static let accent = Theme.Color.brandPrimary
    /// 카드 배경 (Figma F5F5F5)
    private static let cardBg = Color(red: 0xF5 / 255, green: 0xF5 / 255, blue: 0xF5 / 255)

    private func poseCard(_ pose: Pose) -> some View {
        let isFav = favorites.contains(pose.id)
        let isSelected = pose.id == selectedPoseId
        return ZStack(alignment: .topLeading) {
            // 배경 (F5F5F5, 직각)
            Rectangle().fill(Self.cardBg)

            // 이미지 영역(84) + 이름 영역(36) — 세로 오토레이아웃
            VStack(spacing: 0) {
                // 이미지 영역: 64×64 썸네일, 가로 중앙 · 하단 딱붙음
                Color.clear
                    .frame(height: 84)
                    .overlay(alignment: .bottom) {
                        Image("PoseCatDefault")
                            .resizable().scaledToFit()
                            .frame(width: 64, height: 64)
                    }
                // 이름 영역(36)
                Text(pose.nameKo)
                    .textStyle(.caption1)
                    .foregroundStyle(Theme.Color.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
            }

            // 라디오 (좌상단): 미선택 = 빈 원 / 선택 = 어두운 원 + 흰 체크
            Group {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Theme.Color.text)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(Color(white: 0.72))
                }
            }
            .font(.system(size: 22, weight: .regular))
            .padding(8)
            .allowsHitTesting(false)

            // 하트 (우상단) — 즐겨찾기 토글. 켜짐 = 시안색 채움
            Button { toggleFavorite(pose.id) } label: {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isFav ? Self.accent : Color(white: 0.62))
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
        .frame(height: 120)
        .contentShape(Rectangle())
        .onTapGesture { onSelect(pose.id); dismiss() }
    }

    // MARK: - 데이터
    private var filteredPoses: [Pose] {
        let q = query.trimmingCharacters(in: .whitespaces)
        if searching {
            // 검색 모드: 전체 대상
            guard !q.isEmpty else { return PoseCatalog.all }
            return PoseCatalog.all.filter {
                $0.nameKo.localizedCaseInsensitiveContains(q)
                    || $0.nameEn.localizedCaseInsensitiveContains(q)
                    || $0.sanskrit.localizedCaseInsensitiveContains(q)
            }
        }
        // 탭 필터
        return tab == .favorites ? PoseCatalog.all.filter { favorites.contains($0.id) } : PoseCatalog.all
    }

    // MARK: - 즐겨찾기 (UserDefaults 영구 저장)
    private var favorites: Set<String> {
        Set(favoritesCSV.split(separator: ",").map(String.init))
    }
    private func toggleFavorite(_ id: String) {
        var s = favorites
        if s.contains(id) { s.remove(id) } else { s.insert(id) }
        favoritesCSV = s.sorted().joined(separator: ",")
    }
}
