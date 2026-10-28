//
//  Typography.swift
//  YOCAT
//
//  텍스트 스타일 토큰 — 프로젝트에 등록된 Figma 텍스트 스타일(YOCAT/*) 기준.
//  폰트: "Griun On handwriting" (손글씨체), 전부 Regular.
//
//  ⚠️ 폰트 파일은 아직 프로젝트에 없음 → 현재는 시스템 폰트로 폴백 렌더링.
//     폰트 추가 후 `Theme.appFont(size:)` 한 곳만 .custom("Griun On handwriting", size:)
//     (실제 PostScript명 확인 후)으로 바꾸면 전체 반영됨.
//
//  사용:  Text("...").textStyle(.body)
//
//  등록 스타일:
//   LargeTitle 32 / 41px      Title1 24 / Auto
//   Title2     20 / 28px      Headline 18 / 22px
//   Body       16 / 150%      Caption1 14 / 140%      Caption2 13 / 140%
//

import SwiftUI
import CoreText

/// 커스텀 폰트 런타임 등록. (생성형 Info.plist 프로젝트라 UIAppFonts 대신 CoreText로 등록)
/// 앱 시작 시 `AppFonts.register()` 1회 호출.
enum AppFonts {
    /// 번들에 포함된 폰트 파일명(확장자 제외)
    static let files = ["Griun_OnHandwriting-Rg"]

    static func register() {
        for name in files {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

struct AppTextStyle {
    let size: CGFloat
    /// 행간 배수 (1.0 = Auto/기본)
    let lineHeightMultiple: CGFloat
}

extension AppTextStyle {
    static let largeTitle = AppTextStyle(size: 32, lineHeightMultiple: 41.0 / 32.0)  // 41px
    static let title1     = AppTextStyle(size: 24, lineHeightMultiple: 1.0)          // Auto
    static let title2     = AppTextStyle(size: 20, lineHeightMultiple: 28.0 / 20.0)  // 28px
    static let headline   = AppTextStyle(size: 18, lineHeightMultiple: 22.0 / 18.0)  // 22px
    static let body       = AppTextStyle(size: 16, lineHeightMultiple: 1.50)         // 150%
    static let caption1   = AppTextStyle(size: 14, lineHeightMultiple: 1.40)         // 140%
    static let caption2   = AppTextStyle(size: 13, lineHeightMultiple: 1.40)         // 140%
}

extension Theme {
    /// 앱 폰트 = "Griun On handwriting" (PostScript명 GriunOnhandwriting-Regular).
    /// 미설치 환경에서는 SwiftUI가 시스템 폰트로 자동 폴백.
    static func appFont(size: CGFloat) -> SwiftUI.Font {
        .custom("GriunOnhandwriting-Regular", size: size)
    }
}

extension View {
    /// 등록된 텍스트 스타일 적용 (폰트 + 행간).
    func textStyle(_ style: AppTextStyle) -> some View {
        self
            .font(Theme.appFont(size: style.size))
            .lineSpacing(style.size * (style.lineHeightMultiple - 1))
    }
}

/// center-stroke 효과 텍스트. (SwiftUI Text는 strokeWidth를 렌더하지 않아, 글리프를 8방향 겹쳐 두께를 줌)
struct StrokeText: View {
    let text: String
    var style: AppTextStyle
    var color: Color = Theme.Color.text
    var radius: CGFloat = 0.5      // stroke 반경(pt)

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) / 8.0 * 2.0 * .pi
                Text(text)
                    .textStyle(style)
                    .foregroundStyle(color)
                    .offset(x: CGFloat(cos(angle)) * radius, y: CGFloat(sin(angle)) * radius)
            }
            Text(text)
                .textStyle(style)
                .foregroundStyle(color)
        }
    }
}
