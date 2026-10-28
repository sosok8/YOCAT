//
//  PoseChip.swift
//  YOCAT
//
//  선택 토글되는 칩 (자세 다중선택용).
//

import SwiftUI

struct PoseChip: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Font.caption)
                .fontWeight(.medium)
                .padding(.horizontal, Theme.Spacing.m)
                .padding(.vertical, Theme.Spacing.s)
                .foregroundStyle(isSelected ? Color.white : Theme.Color.textPrimary)
                .background(isSelected ? Theme.Color.primary : Theme.Color.surfaceAlt)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
