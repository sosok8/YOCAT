//
//  JournalThreadView.swift
//  YOCAT
//
//  수련 일지 — 전체 기록을 세로 스레드(타임라인)로 보여준다.
//  각 노드 = 한 기록(날짜 · 대표 자세 · 메모 미리보기). 탭 → 상세(EntryDetailView).
//

import SwiftUI
import SwiftData

struct JournalThreadView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    var body: some View {
        VStack(spacing: 0) {
            appBar
            if entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                            ThreadRow(entry: entry, isLast: idx == entries.count - 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Theme.Color.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - 앱바
    private var appBar: some View {
        ZStack {
            Text("수련 일지")
                .textStyle(.title2)
                .foregroundStyle(Theme.Color.text)
            HStack {
                AppIconButton(icon: .system("chevron.left"), style: .background) { dismiss() }
                Spacer()
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("아직 수련 일지가 없어요")
                .textStyle(.body)
                .foregroundStyle(Theme.Color.textTertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// 스레드 한 줄 — 좌측 레일(점+연결선) + 우측 내용.
private struct ThreadRow: View {
    let entry: JournalEntry
    let isLast: Bool

    private var dateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f.string(from: entry.date)
    }
    private var photoCount: Int { entry.photos.count }

    var body: some View {
        NavigationLink(value: entry) {
            HStack(alignment: .top, spacing: 14) {
                // 레일: 노드 점 + 연결선
                VStack(spacing: 0) {
                    Circle()
                        .fill(Theme.Color.text)
                        .frame(width: 9, height: 9)
                    if !isLast {
                        Rectangle()
                            .fill(Theme.Color.border)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .padding(.top, 5)   // 날짜 첫 줄에 점 정렬

                // 내용
                VStack(alignment: .leading, spacing: 6) {
                    Text(dateText)
                        .textStyle(.caption1)
                        .foregroundStyle(Theme.Color.textTertiary)
                    if let pose = entry.featuredPose?.nameKo {
                        Text(pose)
                            .textStyle(.headline)
                            .foregroundStyle(Theme.Color.text)
                    }
                    if !entry.memo.isEmpty {
                        Text(entry.memo)
                            .textStyle(.body)
                            .foregroundStyle(Theme.Color.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    if photoCount > 0 {
                        Label("사진 \(photoCount)", systemImage: "photo")
                            .textStyle(.caption2)
                            .foregroundStyle(Theme.Color.textTertiary)
                    }
                }
                .padding(.bottom, isLast ? 0 : 28)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
