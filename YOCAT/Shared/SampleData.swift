//
//  SampleData.swift
//  YOCAT
//
//  개발 중 화면 확인용 샘플 데이터 (DEBUG 전용).
//  실제 출시 빌드에는 포함되지 않는다.
//

#if DEBUG
import Foundation
import SwiftData

enum SampleData {
    /// 저장된 기록이 하나도 없을 때만 샘플을 채운다.
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<JournalEntry>())) ?? 0
        guard existing == 0 else { return }

        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        func day(_ offset: Int) -> Date { cal.date(byAdding: .day, value: offset, to: today) ?? today }

        let samples: [JournalEntry] = [
            JournalEntry(date: day(-2), memo: "어깨에 힘을 빼고 천천히. 하루 종일 굳었던 곳이 풀렸다.",
                         durationMinutes: 30, energy: .good,  poseIds: ["cat", "cow", "child"], featuredPoseId: "cat"),
            JournalEntry(date: day(-1), memo: "한 발로 서는 게 아직 흔들리지만 호흡에 집중하니 단단해졌다.",
                         durationMinutes: 45, energy: .great, poseIds: ["tree", "warrior2"], featuredPoseId: "tree"),
            JournalEntry(date: day(-3), memo: "마무리 송장 자세에서 가장 마음이 편안했다.",
                         durationMinutes: 20, energy: .okay,  poseIds: ["down_dog", "savasana"], featuredPoseId: "savasana"),
        ]
        samples.forEach { context.insert($0) }
    }
}
#endif
