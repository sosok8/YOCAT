//
//  GoalsView.swift
//  YOCAT
//
//  목표 탭. MVP: 준비 중 골격.
//

import SwiftUI

struct GoalsView: View {
    var body: some View {
        NavigationStack {
            AppScreen {
                EmptyStateView(
                    systemImage: "target",
                    title: "목표는 곧 준비돼요",
                    message: "수련 횟수·자세 집중·연속 일수 목표를\n여기서 관리할 수 있게 될 거예요."
                )
            }
            .navigationTitle("목표")
        }
    }
}

#Preview {
    GoalsView()
}
