//
//  SectionHeader.swift
//  YOCAT
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Font.headline)
                .foregroundStyle(Theme.Color.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.primary)
            }
        }
    }
}
