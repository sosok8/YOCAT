//
//  MyPageView.swift
//  YOCAT
//
//  마이페이지 "내 요가존" (Figma 175-7096).
//  구성(위→아래): 앱바(뒤로·설정) · 상태 문구 · 손그림 요가존(히어로 아사나 + 매트/찻잔/책/인센스) · 구분선 · 통계(수련일지/완료목표).
//
//  · 중앙 히어로 = "직전 수련한 오늘의 아사나" 자리(자세별 에셋 cat_pose_<id>, 없으면 기본 고양이).
//    수련이 뜸하면 상태 문구가 바뀌고, 추후 쉬는 고양이 에셋으로 교체 예정.
//  · 일러스트는 GeometryReader로 Figma 375프레임 좌표 그대로 스케일 배치.
//

import SwiftUI
import SwiftData
import UIKit

/// 홈 → 마이페이지 진입 경로
enum MyPageRoute: Hashable { case myPage }

/// 마이페이지 하위 화면 경로
enum MyPageDest: Hashable { case journal, goals }

/// 수련 빈도 상태 — 상태 문구 / 히어로 일러스트 결정
enum PracticeState {
    case none        // 기록 없음
    case consistent  // 최근 수련 (오늘의 아사나 노출)
    case resting     // 잠시 뜸함
    case away         // 오래 쉼

    var headline: String {
        switch self {
        case .none:       return "첫 수련을\n기록해볼까요?"
        case .consistent: return "꾸준하게\n수련하고 있어요"
        case .resting:    return "잠시\n쉬어가고 있어요"
        case .away:       return "오랜만이에요\n다시 시작해볼까요?"
        }
    }
}

struct MyPageView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query private var goals: [MonthlyGoal]

    @State private var showSettings = false

    // Figma 375 프레임 기준 — 일러스트 밴드(앱바 아래 y100 ~ 통계 시작 y644)
    private let frameW: CGFloat = 375
    private let zoneTop: CGFloat = 100
    private let zoneBottom: CGFloat = 644
    private var zoneH: CGFloat { zoneBottom - zoneTop }   // 544

    private var journalCount: Int { entries.count }
    private var achievedCount: Int { goals.filter { $0.status == .achieved }.count }

    var body: some View {
        VStack(spacing: 0) {
            appBar
            zone
            statsRow
            Spacer(minLength: 0)
        }
        .background(Theme.Color.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) { MyPageSettingsView() }
    }

    // MARK: - 앱바 (뒤로 · 설정)  ※ 중앙 제목 없음(시안 기준)
    private var appBar: some View {
        HStack {
            AppIconButton(icon: .system("chevron.left"), style: .background) { dismiss() }
            Spacer()
            AppIconButton(icon: .asset("SettingIcon"), style: .background) { showSettings = true }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }

    // MARK: - 요가존 (상태 문구 + 손그림 일러스트, Figma 좌표 그대로 스케일)
    private var zone: some View {
        GeometryReader { geo in
            let s = geo.size.width / frameW
            ZStack(alignment: .topLeading) {
                // 상태 문구 (좌 30, top 124 / Griun 20 검정 · stroke 0.25 = 타 페이지 제목과 동일)
                StrokeText(text: practiceState.headline, style: .title2,
                           color: Theme.Color.text, radius: 0.25)
                    .multilineTextAlignment(.leading)
                    .fixedSize()
                    .offset(x: 30 * s, y: (124 - zoneTop) * s)

                // 매트 (뒤)
                img("MyPageMat", 270.833, 47.8206, x: 51.46, y: 355.90, s)

                // 히어로 아사나 (매트 위) — 160 박스 중앙맞춤
                heroImage
                    .resizable().scaledToFit()
                    .frame(width: 160 * s, height: 160 * s)
                    .offset(x: 107 * s, y: (231 - zoneTop) * s)

                // 소품
                img("MyPageCup", 57.6552, 82.7552, x: 34.42, y: 413.44, s)
                img("MyPageBook", 104.547, 53.3407, x: 67.74, y: 490.43, s)
                img("MyPageIncense", 81.0551, 181.61, x: 251.63, y: 417.94, s)

                // 구분선
                img("MyPageDivider", 306.074, 8.34643, x: 34.91, y: 623.82, s)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .aspectRatio(frameW / zoneH, contentMode: .fit)
    }

    private func img(_ name: String, _ w: CGFloat, _ h: CGFloat,
                     x: CGFloat, y: CGFloat, _ s: CGFloat) -> some View {
        Image(name)
            .resizable().scaledToFit()
            .frame(width: w * s, height: h * s)
            .offset(x: x * s, y: (y - zoneTop) * s)
    }

    /// 히어로 일러스트 — 활발하면 직전 수련한 오늘의 아사나(자세별 에셋, 없으면 기본),
    /// 뜸하면(추후) 쉬는 고양이. 지금은 기본 고양이로 폴백.
    private var heroImage: Image {
        if practiceState == .consistent,
           let pid = entries.first?.featuredPoseId,
           let ui = UIImage(named: PoseCatArt.assetName(for: pid)) {
            return Image(uiImage: ui)
        }
        // TODO: .resting / .away 상태용 "쉬는 고양이" 에셋 연결
        return Image("MyPageHero")
    }

    /// 수련 빈도 상태 (마지막 기록으로부터 경과일 기준)
    private var practiceState: PracticeState {
        guard let last = entries.first?.date else { return .none }
        let cal = Calendar.current
        let days = cal.dateComponents([.day],
                                      from: cal.startOfDay(for: last),
                                      to: cal.startOfDay(for: .now)).day ?? 0
        switch days {
        case ..<4:   return .consistent   // 최근 3일 이내
        case 4...10: return .resting      // 잠시 뜸
        default:     return .away         // 오래 쉼
        }
    }

    // MARK: - 통계 (수련 일지 / 완료한 목표)  ※ "내 수련" 타이틀 없음
    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(label: "수련 일지", icon: "StatPencil",
                     iconW: 24.5, iconH: 34.5, value: journalCount, dest: .journal)
            statCard(label: "완료한 목표", icon: "StatFlag",
                     iconW: 21, iconH: 30, value: achievedCount, dest: .goals)
        }
        .padding(.horizontal, 20)
    }

    private func statCard(label: String, icon: String, iconW: CGFloat, iconH: CGFloat,
                          value: Int, dest: MyPageDest) -> some View {
        NavigationLink(value: dest) {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .textStyle(.headline)
                    .foregroundStyle(Theme.Color.text)
                HStack(spacing: 12) {
                    Image(icon)
                        .resizable().scaledToFit()
                        .frame(width: iconW, height: iconH)
                    Text("\(value)")
                        .textStyle(.title2)
                        .foregroundStyle(Theme.Color.text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 120)
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
