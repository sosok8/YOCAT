//
//  JournalEntryCard.swift
//  YOCAT
//
//  일지 목록/상세 리스트의 한 줄 카드.
//

import SwiftUI

struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        Card {
            HStack(spacing: Theme.Spacing.m) {
                CatThumbnail(poseId: entry.featuredPoseId, size: 64)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(DateFormatting.dayShort.string(from: entry.date))
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.textSecondary)

                    Text(entry.featuredPose?.nameKo ?? "자세")
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.Color.textPrimary)

                    if !entry.memo.isEmpty {
                        Text(entry.memo)
                            .font(Theme.Font.body)
                            .foregroundStyle(Theme.Color.textSecondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: Theme.Spacing.m) {
                        if let energy = entry.energy {
                            Text(energy.face)
                        }
                        if let dur = entry.durationMinutes {
                            Label("\(dur)분", systemImage: "clock")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Theme.Color.textSecondary)
                        }
                        Label("자세 \(entry.poseIds.count)", systemImage: "figure.yoga")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Color.textSecondary)
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }
        }
    }
}
