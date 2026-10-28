//
//  AppButton.swift
//  YOCAT
//

import SwiftUI

struct AppButton: View {
    enum Kind { case primary, ghost }

    let title: String
    var kind: Kind = .primary
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.s) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(Theme.Font.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.m)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
                    .stroke(Theme.Color.border, lineWidth: kind == .ghost ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return .white
        case .ghost:   return Theme.Color.textPrimary
        }
    }

    private var background: Color {
        switch kind {
        case .primary: return Theme.Color.primary
        case .ghost:   return Theme.Color.surface
        }
    }
}
