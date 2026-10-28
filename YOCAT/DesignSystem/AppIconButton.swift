//
//  AppIconButton.swift
//  YOCAT
//
//  재사용 아이콘 버튼 컴포넌트.
//  스타일:
//   · .background — 원형 버튼. iOS 26+에서는 애플 네이티브 Liquid Glass(.glass),
//                    그 미만에서는 흰 원 폴백. (프로젝트 표준)
//   · .normal     — 배경 없는 아이콘.
//  상태:  isEnabled(active/disable)   옵션: pushBadge(알림 점)
//  커스터마이즈: frameSize / iconSize / iconColor
//
//  아이콘 소스: SF Symbol(.system, tint 적용) 또는 에셋(.asset, 원본 색 사용).
//

import SwiftUI

struct AppIconButton: View {

    enum Icon {
        case system(String)   // SF Symbol
        case asset(String)    // Assets.xcassets 라인아트 (원본 색)
    }

    enum Style { case normal, background }

    let icon: Icon
    var style: Style = .background
    var frameSize: CGFloat = 44
    var iconSize: CGFloat = 24
    var iconColor: Color = Theme.Color.text
    var disabledColor: Color = Theme.Color.textSecondary
    var isEnabled: Bool = true
    var pushBadge: Bool = false
    let action: () -> Void

    private var resolvedColor: Color { isEnabled ? iconColor : disabledColor }

    var body: some View {
        Group {
            if style == .background {
                backgroundButton
            } else {
                Button(action: action) { iconView.frame(width: iconSize, height: iconSize) }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled)
                    .overlay(alignment: .topTrailing) { badge }
            }
        }
    }

    // MARK: - Background 스타일 (네이티브 글래스 / 폴백 흰 원)
    @ViewBuilder
    private var backgroundButton: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                iconView.frame(width: iconSize, height: iconSize)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .tint(iconColor)
            .disabled(!isEnabled)
            .overlay(alignment: .topTrailing) { badge }
        } else {
            Button(action: action) {
                ZStack {
                    Circle().fill(Theme.Color.surface).frame(width: frameSize, height: frameSize)
                    iconView.frame(width: iconSize, height: iconSize)
                }
                .frame(width: frameSize, height: frameSize)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .overlay(alignment: .topTrailing) { badge }
        }
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: iconSize * 0.9, weight: .semibold))
                .foregroundStyle(resolvedColor)
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .opacity(isEnabled ? 1 : 0.35)
        }
    }

    @ViewBuilder
    private var badge: some View {
        if pushBadge {
            Circle()
                .fill(Color(red: 0.90, green: 0.26, blue: 0.21))
                .frame(width: 8, height: 8)
                .offset(x: 2, y: -2)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        AppIconButton(icon: .asset("ThreadIcon"), action: {})
        AppIconButton(icon: .system("plus"), action: {})
        AppIconButton(icon: .system("bell"), pushBadge: true, action: {})
        AppIconButton(icon: .system("bell"), isEnabled: false, action: {})
    }
    .padding()
    .background(Theme.Color.background)
}
