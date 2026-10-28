//
//  EntryDetailView.swift
//  YOCAT
//
//  일지 단건 상세 (Figma 106-6780).
//  · 앱바: 뒤로 · 편집(연필) · 삭제(휴지통)
//  · 본문: 날짜 · 대표 자세 + 자세명 · 메모 전문 · 첨부 사진(150×150 가로 스크롤)
//  · 편집 → 작성화면(WriteView) 편집 모드 / 삭제 → 확인 다이얼로그
//

import SwiftUI
import SwiftData
import UIKit

struct EntryDetailView: View {
    let entry: JournalEntry

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    private var cal: Calendar { Calendar.current }
    private var dayNumber: Int { cal.component(.day, from: entry.date) }
    private var weekday: String {
        ["일", "월", "화", "수", "목", "금", "토"][cal.component(.weekday, from: entry.date) - 1]
    }

    var body: some View {
        VStack(spacing: 0) {
            appBar

            ScrollView {
                VStack(spacing: 0) {
                    // 날짜 (중앙)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        StrokeText(text: "\(dayNumber)", style: .largeTitle, radius: 0.5)
                        Text(weekday)
                            .textStyle(.title2)
                            .foregroundStyle(Color(white: 0.616))
                    }
                    .padding(.top, 8)

                    // 대표 자세 + 자세명
                    VStack(spacing: 16) {
                        Image("PoseCatDefault")
                            .resizable().scaledToFit()
                            .frame(width: 120, height: 120)
                        if let name = entry.featuredPose?.nameKo {
                            Text(name)
                                .textStyle(.body)
                                .foregroundStyle(Theme.Color.text)
                        }
                    }
                    .padding(.top, 10)

                    // 메모 전문
                    if !entry.memo.isEmpty {
                        Text(entry.memo)
                            .textStyle(.body)
                            .foregroundStyle(Theme.Color.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                    }

                    // 첨부 사진 (150×150, 라운드 20, 가로 스크롤)
                    if !entry.photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(entry.photos.enumerated()), id: \.offset) { _, data in
                                    if let ui = UIImage(data: data) {
                                        Image(uiImage: ui)
                                            .resizable().scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 40)     // 메모 텍스트 ↔ 사진 간격 40
                    }
                }
                .padding(.bottom, 100)        // 본문 하단 여백 100
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Color.surface.ignoresSafeArea())
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showEdit) {
            WriteView(date: entry.date, entry: entry) { showEdit = false }
        }
        .alert("기록을 삭제할까요?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                context.delete(entry)
                try? context.save()
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제하면 복구할 수 없어요.")
        }
    }

    // MARK: - 앱바 (뒤로 · 편집 · 삭제) — 모두 글래스 원형 AppIconButton
    private var appBar: some View {
        HStack {
            AppIconButton(icon: .system("chevron.left"), style: .background) { dismiss() }
            Spacer()
            HStack(spacing: 8) {
                AppIconButton(icon: .asset("EditIcon"), style: .background) {
                    showEdit = true
                }
                AppIconButton(icon: .asset("DeleteIcon"), style: .background, iconColor: .red) {
                    showDeleteAlert = true
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }
}
