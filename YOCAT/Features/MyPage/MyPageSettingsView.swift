//
//  SettingsView.swift
//  YOCAT
//
//  설정 — 뼈대(스켈레톤). 기능은 추후 연결.
//  항목: 수련 리마인더 · 데이터 내보내기 · 앱 정보.
//

import SwiftUI

struct MyPageSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return v
    }

    var body: some View {
        VStack(spacing: 0) {
            appBar
            VStack(spacing: 0) {
                row("수련 리마인더", trailing: "준비 중")
                divider
                row("데이터 내보내기", trailing: "준비 중")
                divider
                row("앱 정보", trailing: "v\(appVersion)")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            Spacer()
        }
        .background(Theme.Color.background.ignoresSafeArea())
    }

    private var appBar: some View {
        ZStack {
            Text("설정")
                .textStyle(.title2)
                .foregroundStyle(Theme.Color.text)
            HStack {
                AppIconButton(icon: .system("chevron.left"), style: .background) { dismiss() }
                Spacer()
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }

    private func row(_ title: String, trailing: String) -> some View {
        HStack {
            Text(title)
                .textStyle(.headline)
                .foregroundStyle(Theme.Color.text)
            Spacer()
            Text(trailing)
                .textStyle(.caption1)
                .foregroundStyle(Theme.Color.textTertiary)
        }
        .frame(height: 56)
        .contentShape(Rectangle())
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.Color.border)
            .frame(height: 1)
    }
}
