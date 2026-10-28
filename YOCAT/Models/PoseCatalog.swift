//
//  PoseCatalog.swift
//  YOCAT
//
//  자세 카탈로그. 번들의 asana-193.json 에서 193종을 로드한다.
//

import Foundation

enum PoseCatalog {
    /// 전체 자세 (수련 아크 순서로 정렬)
    static let all: [Pose] = sorted(load())

    /// 카테고리 배열 순서(수련 흐름: 워밍업 → 피크 → 쿨다운 → 이완)
    /// QP 네발·플랭크 → ST 선 → PR 후굴 → AB 암밸런스 → IN 역자세 → SE 앉은·전굴·비틀기 → SU 누운
    private static let categoryOrder: [String: Int] = [
        "QP": 0, "ST": 1, "PR": 2, "AB": 3, "IN": 4, "SE": 5, "SU": 6,
    ]

    /// 카테고리(아크) → 난이도 오름차순 → base 먼저 → 원본 순번
    private static func sorted(_ poses: [Pose]) -> [Pose] {
        poses.sorted { a, b in
            let ca = categoryOrder[a.categoryCode] ?? 99
            let cb = categoryOrder[b.categoryCode] ?? 99
            if ca != cb { return ca < cb }
            if a.difficulty != b.difficulty { return a.difficulty < b.difficulty }
            if a.isBase != b.isBase { return a.isBase && !b.isBase }
            return a.no < b.no
        }
    }

    /// id(slug)로 자세 조회
    static func pose(for id: String) -> Pose? { byId[id] }

    private static let byId: [String: Pose] =
        Dictionary(all.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

    private static func load() -> [Pose] {
        guard let url = Bundle.main.url(forResource: "asana-193", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            assertionFailure("asana-193.json 을 번들에서 찾지 못함")
            return []
        }
        struct Wrapper: Decodable { let poses: [Pose] }
        return (try? JSONDecoder().decode(Wrapper.self, from: data))?.poses ?? []
    }
}
