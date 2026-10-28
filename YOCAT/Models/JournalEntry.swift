//
//  JournalEntry.swift
//  YOCAT
//
//  수련 일지 (SwiftData). 단일 진실 공급원.
//
//  본문(content)은 **블록 배열**을 정본(source of truth)으로 저장한다.
//   · 현재 화면(A): [ .text(메모), .images(사진들) ] 형태만 생성
//   · 미래(B, 인라인): [ .text, .images, .text, .images … ] 자유 순서
//  → 지금 저장 구조를 블록으로 못 박아두면, 나중에 인라인으로 바꿔도
//    데이터 마이그레이션 없이 화면(UI)만 교체하면 된다.
//  기존 코드 호환을 위해 memo/photos는 content에서 파생되는 접근자로 제공한다.
//

import Foundation
import SwiftData

/// 본문 블록 — 텍스트 또는 사진 그룹(한 번의 첨부 = 한 그룹).
enum ContentBlock: Codable, Equatable {
    case text(String)
    case images([Data])
}

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    /// 본문 블록 배열(JSON). 대용량(사진 포함)이라 외부 저장.
    @Attribute(.externalStorage) var contentData: Data
    var durationMinutes: Int?
    /// EnergyLevel.rawValue 저장 (옵셔널 enum 직접 저장 회피)
    var energyRaw: String?
    var poseIds: [String]
    var featuredPoseId: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        memo: String = "",
        durationMinutes: Int? = nil,
        energy: EnergyLevel? = nil,
        poseIds: [String] = [],
        featuredPoseId: String,
        photos: [Data] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.energyRaw = energy?.rawValue
        self.poseIds = poseIds
        self.featuredPoseId = featuredPoseId
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // 초기 본문(A 형태): 텍스트 블록 + 사진 그룹
        var blocks: [ContentBlock] = []
        if !memo.isEmpty { blocks.append(.text(memo)) }
        if !photos.isEmpty { blocks.append(.images(photos)) }
        self.contentData = Self.encode(blocks)
    }

    // MARK: - 본문(content) 정본

    var content: [ContentBlock] {
        get { (try? JSONDecoder().decode([ContentBlock].self, from: contentData)) ?? [] }
        set { contentData = Self.encode(newValue) }
    }

    private static func encode(_ blocks: [ContentBlock]) -> Data {
        (try? JSONEncoder().encode(blocks)) ?? Data()
    }

    // MARK: - 하위호환 파생 접근자 (카드/상세 미리보기·기존 편집 코드용)

    /// 모든 텍스트 블록을 이어붙인 문자열. set 시 A 형태(텍스트 맨 앞)로 재구성.
    var memo: String {
        get {
            content.compactMap { if case .text(let t) = $0 { return t } else { return nil } }
                .joined(separator: "\n")
        }
        set {
            var blocks = content.filter { if case .images = $0 { return true } else { return false } }
            if !newValue.isEmpty { blocks.insert(.text(newValue), at: 0) }
            content = blocks
        }
    }

    /// 모든 사진 블록을 평탄화. set 시 A 형태(사진 맨 뒤)로 재구성.
    var photos: [Data] {
        get {
            content.flatMap { if case .images(let ps) = $0 { return ps } else { return [] } }
        }
        set {
            var blocks = content.filter { if case .text = $0 { return true } else { return false } }
            if !newValue.isEmpty { blocks.append(.images(newValue)) }
            content = blocks
        }
    }

    /// 컨디션 (rawValue ↔ enum)
    var energy: EnergyLevel? {
        get { energyRaw.flatMap(EnergyLevel.init(rawValue:)) }
        set { energyRaw = newValue?.rawValue }
    }

    /// 대표 자세 정보
    var featuredPose: Pose? { PoseCatalog.pose(for: featuredPoseId) }
}
