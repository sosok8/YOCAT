//
//  EntryEditorViewModel.swift
//  YOCAT
//
//  일지 작성/편집 폼 상태 + 저장 로직 (뷰와 분리).
//

import Foundation
import SwiftData
import Observation

@Observable
final class EntryEditorViewModel {
    var date: Date
    var memo: String = ""
    var durationText: String = ""
    var energy: EnergyLevel?
    var selectedPoseIds: [String] = []
    var featuredPoseId: String?

    private let existing: JournalEntry?

    init(config: EditorConfig) {
        self.existing = config.entry
        if let entry = config.entry {
            self.date = entry.date
            self.memo = entry.memo
            self.durationText = entry.durationMinutes.map(String.init) ?? ""
            self.energy = entry.energy
            self.selectedPoseIds = entry.poseIds
            self.featuredPoseId = entry.featuredPoseId
        } else {
            // 신규: Quick-Entry에서 인계받은 값 반영
            self.date = config.date
            self.memo = config.prefillMemo ?? ""
            self.selectedPoseIds = config.prefillPoseIds ?? []
            self.featuredPoseId = config.prefillFeaturedPoseId ?? config.prefillPoseIds?.first
        }
    }

    var isEditing: Bool { existing != nil }

    /// 저장 가능 조건: 대표 자세가 선택돼야 썸네일을 만들 수 있다.
    var canSave: Bool { featuredPoseId != nil }

    func togglePose(_ id: String) {
        if let idx = selectedPoseIds.firstIndex(of: id) {
            selectedPoseIds.remove(at: idx)
            if featuredPoseId == id { featuredPoseId = selectedPoseIds.first }
        } else {
            selectedPoseIds.append(id)
            if featuredPoseId == nil { featuredPoseId = id }
        }
    }

    func setFeatured(_ id: String) {
        if !selectedPoseIds.contains(id) { selectedPoseIds.append(id) }
        featuredPoseId = id
    }

    private var parsedDuration: Int? {
        let trimmed = durationText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let value = Int(trimmed), value > 0 else { return nil }
        return value
    }

    @discardableResult
    func save(into context: ModelContext) -> Bool {
        guard let featuredPoseId else { return false }
        if let existing {
            existing.date = date
            existing.memo = memo
            existing.durationMinutes = parsedDuration
            existing.energy = energy
            existing.poseIds = selectedPoseIds
            existing.featuredPoseId = featuredPoseId
            existing.updatedAt = .now
        } else {
            let entry = JournalEntry(
                date: date,
                memo: memo,
                durationMinutes: parsedDuration,
                energy: energy,
                poseIds: selectedPoseIds,
                featuredPoseId: featuredPoseId
            )
            context.insert(entry)
        }
        return true
    }
}
