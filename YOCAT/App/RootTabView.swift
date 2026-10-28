//
//  RootTabView.swift
//  YOCAT
//
//  하단 3탭: 캘린더 / 목표 / 마이
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            CalendarHomeView()
                .tabItem { Label("캘린더", systemImage: "calendar") }

            GoalsView()
                .tabItem { Label("목표", systemImage: "target") }

            SettingsView()
                .tabItem { Label("마이", systemImage: "person.crop.circle") }
        }
        .tint(Theme.Color.primary)
        .task {
            #if DEBUG
            SampleData.seedIfNeeded(context)
            #endif
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
