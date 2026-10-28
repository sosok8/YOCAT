//
//  CompletedGoalsView.swift
//  YOCAT
//
//  완료한 목표 — status == .achieved 인 월 목표 아카이브 목록.
//  각 행: 대표 자세 고양이 · 목표 텍스트 · 달성한 달.
//

import SwiftUI
import SwiftData

struct CompletedGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MonthlyGoal.startMonth, order: .reverse) private var goals: [MonthlyGoal]

    private var achieved: [MonthlyGoal] { goals.filter { $0.status == .achieved } }

    var body: some View {
        VStack(spacing: 0) {
            appBar
            if achieved.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(achieved) { goal in
                            GoalRow(goal: goal)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Theme.Color.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var appBar: some View {
        ZStack {
            Text("완료한 목표")
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
            Text("아직 완료한 목표가 없어요")
                .textStyle(.body)
                .foregroundStyle(Theme.Color.textTertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct GoalRow: View {
    let goal: MonthlyGoal

    private var monthText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f.string(from: goal.startMonth)
    }

    private var poseImage: Image {
        if let pid = goal.poseId,
           let ui = UIImage(named: PoseCatArt.assetName(for: pid)) {
            return Image(uiImage: ui)
        }
        return Image("PoseCatDefault")
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            poseImage
                .resizable().scaledToFit()
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.text.isEmpty ? "목표" : goal.text)
                    .textStyle(.headline)
                    .foregroundStyle(Theme.Color.text)
                    .lineLimit(2)
                Text(monthText)
                    .textStyle(.caption1)
                    .foregroundStyle(Theme.Color.textTertiary)
            }
            Spacer(minLength: 0)
            // 달성 표시
            Image("StatFlag")
                .resizable().scaledToFit()
                .frame(width: 18, height: 26)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
