//
//  AppTextField.swift
//  YOCAT
//

import SwiftUI
import UIKit

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text, axis: axis)
            .keyboardType(keyboard)
            .font(Theme.Font.body)
            .foregroundStyle(Theme.Color.textPrimary)
            .padding(Theme.Spacing.m)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
                    .stroke(Theme.Color.border, lineWidth: 1)
            )
    }
}
