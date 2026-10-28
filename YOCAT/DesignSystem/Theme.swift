//
//  Theme.swift
//  YOCAT
//
//  앱 전역 디자인 토큰.
//  컬러 시스템은 Figma "Color" (116:5515) 기준. 새 컬러는 항상 여기서 뽑아 쓴다.
//   · Brand:   primary(#11AAD7, fills only), secondary(#000000)
//   · Neutral: neutral0(#FFF) … neutral1000(#000) 11단계 (primitive)
//   · Text:    text/textSecondary/textTertiary/textInverse (semantic)
//

import SwiftUI

extension SwiftUI.Color {
    /// 0xRRGGBB 정수로 색 생성
    init(hex: UInt) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {

    // MARK: - 색상 (Figma Color System · 코드 기반 단일 소스)
    enum Color {

        // MARK: Brand
        static let brandPrimary   = SwiftUI.Color(hex: 0x11AAD7)  // color/primary — fills only, black labels
        static let brandSecondary = SwiftUI.Color(hex: 0x000000)  // color/secondary — secondary buttons

        // MARK: Neutral (Primitive)
        static let neutral0    = SwiftUI.Color(hex: 0xFFFFFF)  // 카드/시트 (tinted ground 위)
        static let neutral100  = SwiftUI.Color(hex: 0xF7F6F3)  // 가장 옅은 tint, raised surface
        static let neutral200  = SwiftUI.Color(hex: 0xEFEEE7)  // 기본 페이지 배경
        static let neutral300  = SwiftUI.Color(hex: 0xE8E6DD)  // subtle fill, hover
        static let neutral400  = SwiftUI.Color(hex: 0xD2CFC6)  // 헤어라인/구분선/입력 테두리
        static let neutral500  = SwiftUI.Color(hex: 0xB5B2A6)  // disabled fill
        static let neutral600  = SwiftUI.Color(hex: 0x959183)  // placeholder text (대형만)
        static let neutral700  = SwiftUI.Color(hex: 0x6D6A5F)  // secondary text
        static let neutral800  = SwiftUI.Color(hex: 0x514F48)  // raised panel (dark)
        static let neutral900  = SwiftUI.Color(hex: 0x2E2D29)  // body text / dark ground
        static let neutral1000 = SwiftUI.Color(hex: 0x000000)  // 최대 대비

        // MARK: Semantic — Text
        static let text          = neutral1000  // color/text
        static let textSecondary = neutral700   // color/textSecondary
        static let textTertiary  = neutral600   // color/textTertiary (placeholder/disabled)
        static let textInverse   = neutral0     // color/textInverse

        // MARK: Semantic — Surface / Background
        static let background = neutral200  // 기본 페이지 배경
        static let surface    = neutral0    // 카드/시트
        static let surfaceAlt = neutral300  // subtle fill (원형·칩 등)
        static let border     = neutral400  // 구분선/입력 테두리

        // MARK: 호환 별칭 (기존 코드 참조명)
        static let textPrimary = text
        static let primary     = brandSecondary   // 블랙(고대비) — 기존 primary 의미 유지
        static let accent      = brandPrimary      // 강조색 = 브랜드 프라이머리(#11AAD7)
        static let primarySoft = surfaceAlt
        static let success     = brandPrimary
        static let danger      = SwiftUI.Color(hex: 0xE5484D)
    }

    // MARK: - 간격 스케일
    enum Spacing {
        static let xs:  CGFloat = 4
        static let s:   CGFloat = 8
        static let m:   CGFloat = 12
        static let l:   CGFloat = 16
        static let xl:  CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - 모서리 반경
    enum Radius {
        static let card:   CGFloat = 20
        static let button: CGFloat = 16
        // 칩은 Capsule() 사용
    }

    // MARK: - 타이포 (비라운드 고딕 / SF Pro)
    enum Font {
        static var largeTitle: SwiftUI.Font { .system(.largeTitle, design: .default).weight(.bold) }
        static var title:      SwiftUI.Font { .system(.title2,     design: .default).weight(.semibold) }
        static var headline:   SwiftUI.Font { .system(.headline,   design: .default) }
        static var body:       SwiftUI.Font { .system(.body) }
        static var caption:    SwiftUI.Font { .system(.caption) }
        static var number:     SwiftUI.Font { .system(.title2, design: .default).weight(.bold).monospacedDigit() }
    }
}

extension View {
    /// 플랫 디자인 — 그림자 없음 (호환용 no-op)
    func softShadow() -> some View { self }
}
