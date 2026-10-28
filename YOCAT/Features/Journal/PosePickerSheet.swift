//
//  PosePickerSheet.swift
//  YOCAT
//
//  대표 자세 1개 선택 시트. 고르는 즉시 고양이 미리보기가 바뀐다.
//

import SwiftUI

struct PosePickerSheet: View {
    @Binding var selectedPoseId: String?
    @Environment(\.dismiss) private var dismiss
    @State private var temp: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.m), count: 3)

    init(selectedPoseId: Binding<String?>) {
        _selectedPoseId = selectedPoseId
        _temp = State(initialValue: selectedPoseId.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            AppScreen {
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        preview
                        LazyVGrid(columns: columns, spacing: Theme.Spacing.l) {
                            ForEach(PoseCatalog.all) { pose in
                                Button {
                                    withAnimation { temp = pose.id }
                                } label: {
                                    VStack(spacing: Theme.Spacing.xs) {
                                        CatThumbnail(poseId: pose.id, size: 72)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 72 * 0.28, style: .continuous)
                                                    .stroke(Theme.Color.text, lineWidth: temp == pose.id ? 3 : 0)
                                            )
                                        Text(pose.nameKo)
                                            .font(.system(size: 11))
                                            .foregroundStyle(Theme.Color.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Theme.Spacing.l)
                }
            }
            .navigationTitle("자세 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }.tint(Theme.Color.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("선택") {
                        selectedPoseId = temp
                        dismiss()
                    }
                    .tint(Theme.Color.text)
                    .disabled(temp == nil)
                }
            }
        }
    }

    private var preview: some View {
        VStack(spacing: Theme.Spacing.m) {
            ZStack {
                if let t = temp {
                    CatThumbnail(poseId: t, size: 130)
                        .id(t)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Theme.Color.surfaceAlt)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Image(systemName: "pawprint")
                                .font(.system(size: 42))
                                .foregroundStyle(Theme.Color.textSecondary)
                        )
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.72), value: temp)

            Text(temp.flatMap { PoseCatalog.pose(for: $0)?.nameKo } ?? "자세를 골라주세요")
                .font(Theme.Font.headline)
                .foregroundStyle(temp == nil ? Theme.Color.textSecondary : Theme.Color.text)
        }
    }
}
