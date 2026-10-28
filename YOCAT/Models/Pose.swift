//
//  Pose.swift
//  YOCAT
//
//  요가 자세 마스터 데이터(정적). 일지는 자세의 id(slug, String)만 저장한다.
//  실제 데이터는 번들의 asana-193.json 에서 로드한다 (PoseCatalog).
//

import Foundation

struct Pose: Identifiable, Hashable, Decodable {
    let no: Int               // JSON 원본 순번 (정렬 안정용)
    let id: String            // slug (예: "tadasana")
    let nameKo: String        // "타다아사나"
    let nameEn: String        // "Mountain Pose"
    let sanskrit: String      // "Tadasana"
    let categoryCode: String  // "ST"
    let categoryKo: String    // "선 자세"
    let difficulty: Int       // 1(기초) ~ 4(고급)
    let isBase: Bool          // 기본 자세 여부(변형 제외)

    enum CodingKeys: String, CodingKey {
        case no
        case id = "slug"
        case nameKo = "name_ko"
        case nameEn = "name_en"
        case sanskrit = "name_sanskrit"
        case categoryCode = "category"
        case categoryKo = "category_ko"
        case difficulty
        case isBase = "is_base"
    }

    /// Assets.xcassets 의 고양이 이미지 이름 (PoseCatArt 규약). 없으면 기본 고양이로 폴백.
    var assetName: String { PoseCatArt.assetName(for: id) }
}
