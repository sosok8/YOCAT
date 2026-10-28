//
//  PoseCategory.swift
//  YOCAT
//

import SwiftUI

enum PoseCategory: String, CaseIterable, Codable {
    case standing, seated, backbend, forwardFold, balance, rest

    var label: String {
        switch self {
        case .standing:    return "선 자세"
        case .seated:      return "앉은 자세"
        case .backbend:    return "후굴"
        case .forwardFold: return "전굴"
        case .balance:     return "균형"
        case .rest:        return "휴식"
        }
    }

    /// 썸네일 배경 틴트 (카테고리별로 미묘하게 다른 따뜻한 톤)
    var tint: Color {
        switch self {
        case .standing:    return Color(red: 0.93, green: 0.85, blue: 0.74) // 샌드
        case .seated:      return Color(red: 0.90, green: 0.86, blue: 0.78) // 라이트 베이지
        case .backbend:    return Color(red: 0.94, green: 0.82, blue: 0.76) // 더스티 로즈
        case .forwardFold: return Color(red: 0.86, green: 0.88, blue: 0.80) // 세이지
        case .balance:     return Color(red: 0.95, green: 0.89, blue: 0.74) // 웜 옐로
        case .rest:        return Color(red: 0.88, green: 0.85, blue: 0.90) // 소프트 라벤더
        }
    }
}
