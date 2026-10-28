//
//  EmptyStateView.swift
//  YOCAT
//
//  빈 상태 / 에러 상태 공통 뷰.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(Theme.Color.textSecondary)

            Text(title)
                .font(Theme.Font.title)
                .foregroundStyle(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                AppButton(title: actionTitle, action: action)
                    .fixedSize()
                    .padding(.top, Theme.Spacing.s)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}
