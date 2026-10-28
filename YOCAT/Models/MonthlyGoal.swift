//
//  MonthlyGoal.swift
//  YOCAT
//
//  이번 달 목표 (SwiftData). 달마다 1개.
//
//  정책:
//   · 목표는 순수 텍스트.
//   · "새 달 첫 진입" 시 지난 목표가 아직 평가되지 않았으면 롤오버 다이얼로그.
//       ① 달성했나요?  예 → 새 목표 작성
//                      아니오 → ② 이번 달도 이 목표를 가져갈까요?
//                                  예 → 그대로 유지 / 아니오 → 새 목표 작성
//   · 여러 달 건너뛰어도 마지막 목표가 계속 표시되고, 다음 진입 때 딱 한 번 물음.
//   · 달성/미달성 기록은 아카이브로 남긴다(히스토리, 화면은 추후).
//

import Foundation
import SwiftData

enum GoalStatus: String, Codable {
    case active     // 진행중 (현재 표시되는 목표)
    case achieved   // 달성하고 아카이브됨
    case failed     // 미달성으로 아카이브됨(새 목표로 교체)
}

@Model
final class MonthlyGoal {
    var id: UUID
    var text: String
    /// 목표 대표 자세(일러스트). nil이면 기본 고양이.
    var poseId: String?
    /// 이 목표가 활성화된 달 (월 시작일로 정규화). 롤오버 판정 기준.
    var startMonth: Date
    var statusRaw: String
    /// 지난 목표를 이어받았는지
    var carriedOver: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        poseId: String? = nil,
        startMonth: Date,
        status: GoalStatus = .active,
        carriedOver: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.text = text
        self.poseId = poseId
        self.startMonth = MonthlyGoal.monthStart(startMonth)
        self.statusRaw = status.rawValue
        self.carriedOver = carriedOver
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    /// 월 시작일(1일 00:00)로 정규화
    static func monthStart(_ date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }

    /// 비교용 월 키 (year*12 + month)
    static func monthKey(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.year, .month], from: date)
        return (c.year ?? 0) * 12 + (c.month ?? 0)
    }
}
