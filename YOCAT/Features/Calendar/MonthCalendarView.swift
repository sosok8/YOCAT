//
//  MonthCalendarView.swift
//  YOCAT
//
//  월 캘린더 그리드 — Figma Home-default 시안 기준.
//  · 주 시작 = 월요일
//  · 날짜 숫자 없음. 셀은 원(circle) 기반.
//  · day 상태:  none(달 밖·투명) / empty(회색 원) / filled(고양이) / today(회색 원 + plus)
//  · 기록 있는 날은 대표 자세 고양이 썸네일. (실제 자세별 소스 전까지 단일 플레이스홀더)
//

import SwiftUI

struct MonthCalendarView: View {
    let month: Date
    let selectedDay: Date?
    /// 날짜(startOfDay) → 그날의 기록들 (대표는 첫 요소)
    let entriesByDay: [Date: [JournalEntry]]
    let onSelectDay: (Date) -> Void

    private var calendar: Calendar {
        var c = Calendar.current
        c.firstWeekday = 2   // 월요일 시작
        return c
    }
    // 원 크기는 디바이스 폭에 따라 가변(.flexible). 원 좌우 간격 = 4, 줄 간격 = 8.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(daysInGrid.enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(
                        entry: entriesByDay[calendar.startOfDay(for: date)]?.first,
                        isToday: calendar.isDateInToday(date),
                        isSelected: selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        onTap: { onSelectDay(calendar.startOfDay(for: date)) }
                    )
                } else {
                    Color.clear.aspectRatio(1, contentMode: .fit)   // none: 달 밖 빈칸
                }
            }
        }
    }

    /// 그리드용 날짜 배열 (앞뒤 빈칸 nil 포함, 월요일 시작)
    private var daysInGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDay = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<daysInMonth {
            result.append(calendar.date(byAdding: .day, value: offset, to: firstDay))
        }
        while result.count % 7 != 0 { result.append(nil) }   // 마지막 줄 채우기
        return result
    }
}

// MARK: - Day 셀 (원형)

private struct DayCell: View {
    let entry: JournalEntry?
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void

    /// 선택 강조색 (디자인 시스템 brandPrimary · #11AAD7)
    private static let accent = Theme.Color.brandPrimary

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if entry != nil {
                    // filled — 기록 있는 날: 고양이. 선택 시 일러스트를 accent로 틴트.
                    Image("PoseCatDefault")
                        .renderingMode(isSelected ? .template : .original)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Self.accent)
                        .padding(1)
                } else if isToday {
                    // today — 오늘(기록 전): 회색 원 + plus (셀 대비 24/44 비율, Figma 소스)
                    Circle().fill(Theme.Color.surfaceAlt)
                    GeometryReader { g in
                        Image("PlusIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: g.size.width * 24.0 / 44.0)
                            .position(x: g.size.width / 2, y: g.size.height / 2)
                    }
                } else {
                    // empty — 이번 달, 기록 없는 날: 회색 원
                    Circle().fill(Theme.Color.surfaceAlt)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                // 기록 없는 날 선택 시에만 원 스트로크(accent 80%, 1.5)
                if isSelected && entry == nil {
                    Circle().strokeBorder(Self.accent.opacity(0.8), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
