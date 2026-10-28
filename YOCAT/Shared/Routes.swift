//
//  Routes.swift
//  YOCAT
//
//  네비게이션·시트 라우팅 보조 타입.
//

import Foundation

/// 날짜 탭 → Quick-Entry 시트용 (Identifiable)
struct DaySelection: Identifiable {
    let date: Date
    var id: Date { date }
}

/// 작성/편집 시트 설정. Quick-Entry에서 입력한 메모·자세를 인계할 수 있다.
struct EditorConfig: Identifiable {
    let id = UUID()
    var date: Date
    var entry: JournalEntry? = nil
    var prefillMemo: String? = nil
    var prefillPoseIds: [String]? = nil
    var prefillFeaturedPoseId: String? = nil
}
