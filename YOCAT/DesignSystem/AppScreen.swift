//
//  AppScreen.swift
//  YOCAT
//
//  크림 배경 + SafeArea 를 공통화한 화면 컨테이너.
//

import SwiftUI

struct AppScreen<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()
            content
        }
    }
}
