//
//  YOCATApp.swift
//  YOCAT
//
//  Created by 김소정 on 5/31/26.
//

import SwiftUI
import SwiftData

@main
struct YOCATApp: App {
    @State private var showSplash = true

    init() {
        AppFonts.register()   // 커스텀 폰트(Griun On handwriting) 런타임 등록
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                CalendarHomeView()   // 탭바 제거 — 홈이 루트

                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .modelContainer(for: [JournalEntry.self, MonthlyGoal.self])
    }
}
