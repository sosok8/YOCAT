//
//  DateFormatting.swift
//  YOCAT
//
//  ko_KR 로케일 기준 날짜 포맷 (캐싱).
//

import Foundation

enum DateFormatting {
    static let koLocale = Locale(identifier: "ko_KR")

    private static func make(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = koLocale
        f.dateFormat = format
        return f
    }

    /// 2026년 5월
    static let monthTitle = make("yyyy년 M월")
    /// 5월 31일 토요일
    static let dayLong = make("M월 d일 EEEE")
    /// 5월 31일 (토)
    static let dayShort = make("M월 d일 (E)")
}
