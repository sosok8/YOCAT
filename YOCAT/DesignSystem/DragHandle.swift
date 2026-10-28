//
//  DragHandle.swift
//  YOCAT
//
//  바텀시트/카드 상단의 드래그 핸들 (프로젝트 표준).
//  감싸는 영역 28 · 바 36×4 (중앙 정렬). 어디서나 이 컴포넌트를 사용한다.
//

import SwiftUI

struct DragHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Color(white: 0.85))
            .frame(width: 36, height: 4)
            .frame(maxWidth: .infinity)
            .frame(height: 28)
    }
}

#Preview {
    DragHandle().background(Theme.Color.surface)
}
