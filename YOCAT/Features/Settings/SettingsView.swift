//
//  SettingsView.swift
//  YOCAT
//
//  마이(설정) 탭. MVP: 준비 중 골격.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            AppScreen {
                EmptyStateView(
                    systemImage: "person.crop.circle",
                    title: "마이 페이지 준비 중",
                    message: "알림 설정과 데이터 내보내기/가져오기가\n여기에 들어올 예정이에요."
                )
            }
            .navigationTitle("마이")
        }
    }
}

#Preview {
    SettingsView()
}
