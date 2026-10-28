//
//  SplashView.swift
//  YOCAT
//
//  스플래시 — Figma 디자인(node 1:74) 이미지를 그대로 전체화면에 표시.
//  "Yocat" 워드마크 + 요가 고양이 3마리. 가볍게 페이드인/아웃 후 홈 진입.
//

import SwiftUI

struct SplashView: View {

    var onFinished: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Theme.Color.background
                .ignoresSafeArea()

            Image("SplashScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear(perform: runSequence)
    }

    private func runSequence() {
        // 페이드 인
        withAnimation(.easeOut(duration: 0.4)) {
            opacity = 1
        }
        // 유지 후 페이드 아웃
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.45)) {
                opacity = 0
            }
        }
        // 홈 진입
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
