//
//  GoalPolicy.swift
//  YOCAT
//
//  이번 달 목표 롤오버 정책 로직. (뷰에서 호출)
//

import Foundation
import SwiftData

enum GoalPolicy {

    // MARK: - 조회 / 판정

    /// 현재 활성 목표 (표시되는 목표). 없으면 nil.
    static func activeGoal(_ goals: [MonthlyGoal]) -> MonthlyGoal? {
        goals.filter { $0.status == .active }
            .max { MonthlyGoal.monthKey($0.startMonth) < MonthlyGoal.monthKey($1.startMonth) }
    }

    /// 롤오버 다이얼로그가 필요한가?
    /// = 활성 목표가 있고, 그 목표의 시작 달보다 지금이 이후 달일 때.
    static func needsRollover(_ goal: MonthlyGoal, now: Date = .now) -> Bool {
        MonthlyGoal.monthKey(now) > MonthlyGoal.monthKey(goal.startMonth)
    }

    // MARK: - 전환 (다이얼로그 응답 → 상태 변경)

    /// ① 달성함 → 기존 목표 아카이브(achieved). 이후 새 목표 작성 유도.
    static func markAchieved(_ goal: MonthlyGoal, context: ModelContext) {
        goal.status = .achieved
        goal.updatedAt = .now
        try? context.save()
    }

    /// ②-예 이번 달도 이어감 → 같은 목표 유지, 시작 달만 이번 달로 갱신(다음 달에 다시 물음).
    static func carryOver(_ goal: MonthlyGoal, now: Date = .now, context: ModelContext) {
        goal.startMonth = MonthlyGoal.monthStart(now)
        goal.carriedOver = true
        goal.updatedAt = .now
        try? context.save()
    }

    /// 새 목표로 교체 → 기존은 실패(또는 달성) 아카이브, 새 active 목표 생성.
    /// (달성 후 새 목표면 archiveAs=.achieved, 미달성 후 새 목표면 .failed)
    @discardableResult
    static func replaceWithNew(
        old: MonthlyGoal?,
        text: String,
        archiveAs: GoalStatus = .failed,
        now: Date = .now,
        context: ModelContext
    ) -> MonthlyGoal {
        if let old {
            old.status = archiveAs
            old.updatedAt = .now
        }
        let new = MonthlyGoal(text: text, startMonth: now)
        context.insert(new)
        try? context.save()
        return new
    }

    /// 첫 목표 설정(기존 없음).
    @discardableResult
    static func setInitial(text: String, now: Date = .now, context: ModelContext) -> MonthlyGoal {
        let g = MonthlyGoal(text: text, startMonth: now)
        context.insert(g)
        try? context.save()
        return g
    }
}
