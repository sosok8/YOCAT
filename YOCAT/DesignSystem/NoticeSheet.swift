//
//  NoticeSheet.swift
//  YOCAT
//
//  하단 알림 다이얼로그 (Figma bottom sheet-notice, 138:10507).
//   · 흰 카드, 상단 코너 30, full-width 하단 부착, 드롭섀도(0,0,15 · black 8%)
//   · (옵션)일러스트 64 + 제목(20) + 본문(18) + 버튼(아니오/네, rounded 20, 52h)
//   · 표시: NoticeOverlay(딤 배경 + 페이드 0.5s ease-out)
//

import SwiftUI

struct NoticeSheet: View {
    var iconAsset: String? = nil       // 상단 일러스트(에셋명), 옵션
    let title: String
    var message: String? = nil
    var secondaryTitle: String? = nil  // 아니오 (옵션)
    var onSecondary: () -> Void = {}
    let primaryTitle: String           // 네
    var onPrimary: () -> Void = {}

    // 디자인 시스템 토큰
    private static let bodyColor = Theme.Color.neutral900   // #2E2D29 (본문)
    private static let secBg = Theme.Color.neutral100       // #F7F6F3 (아니오 배경)
    private static let secText = Theme.Color.textTertiary   // #959183 (아니오 텍스트)
    private static let priBg = Theme.Color.neutral900       // #2E2D29 (네 배경)

    var body: some View {
        VStack(spacing: 0) {
            // text version — pt 32, px 32, pb 12, gap 12
            VStack(spacing: 12) {
                if let iconAsset {
                    Image(iconAsset)
                        .resizable().scaledToFit()
                        .frame(width: 41, height: 55)      // image-here 64box 내 실제 41×55
                        .padding(.vertical, 8)
                }
                StrokeText(text: title, style: .title2, color: Theme.Color.text, radius: 0.25)
                    .frame(maxWidth: .infinity)
                if let message {
                    Text(message)
                        .textStyle(.headline)              // 18 (Headline)
                        .foregroundStyle(Self.bodyColor)   // #25201e
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)
            .padding(.bottom, 12)

            // button-area — pt 12, px 20, pb 8, gap 8
            HStack(spacing: 8) {
                if let secondaryTitle {
                    button(secondaryTitle, bg: Self.secBg, fg: Self.secText, action: onSecondary)
                }
                button(primaryTitle, bg: Self.priBg, fg: .white, action: onPrimary)
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .ignoresSafeArea(edges: .bottom)          // 하단 인디케이터까지 흰 배경
        }
    }

    private func button(_ title: String, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .textStyle(.headline)                     // 18 (Button1)
                .foregroundStyle(fg)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(bg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// 다이얼로그를 딤 배경 위 하단에 띄우는 오버레이. `isPresented`가 true일 때 페이드로 표시.
struct NoticeOverlay<Content: View>: View {
    let isPresented: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                content()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.5), value: isPresented)
    }
}
