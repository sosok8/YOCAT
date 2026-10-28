//
//  EnergyLevel.swift
//  YOCAT
//
//  수련 후 컨디션. 고양이 표정으로 표현한다.
//

import Foundation

enum EnergyLevel: String, CaseIterable, Codable, Identifiable {
    case low, okay, good, great

    var id: String { rawValue }

    var label: String {
        switch self {
        case .low:   return "힘들었어요"
        case .okay:  return "그저 그래요"
        case .good:  return "좋았어요"
        case .great: return "최고였어요"
        }
    }

    /// 고양이 표정 (플레이스홀더 — 추후 일러스트로 교체 가능)
    var face: String {
        switch self {
        case .low:   return "🙀"
        case .okay:  return "😿"
        case .good:  return "😺"
        case .great: return "😸"
        }
    }
}
