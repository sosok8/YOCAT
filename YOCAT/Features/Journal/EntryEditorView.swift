//
//  EntryEditorView.swift
//  YOCAT
//
//  일지 작성/편집 시트 (전체). 대표 자세를 고르면 미리보기 고양이가
//  부드러운 페이드/스케일 전환으로 바뀐다.
//  진입 경로: ① Quick-Entry "상세 작성 →"  ② 리스트/상세에서 편집
//

import SwiftUI
import SwiftData

struct EntryEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm: EntryEditorViewModel

    init(config: EditorConfig) {
        _vm = State(initialValue: EntryEditorViewModel(config: config))
    }

    var body: some View {
        NavigationStack {
            AppScreen {
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        catPreview
                        poseSection
                        if !vm.selectedPoseIds.isEmpty { featuredSection }
                        energySection
                        memoSection
                        durationSection
                    }
                    .padding(Theme.Spacing.l)
                }
            }
            .navigationTitle(vm.isEditing ? "기록 수정" : "오늘 기록하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }.tint(Theme.Color.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if vm.save(into: context) { dismiss() }
                    }
                    .tint(Theme.Color.text)
                    .disabled(!vm.canSave)
                }
            }
        }
    }

    // MARK: - 미리보기 고양이 (★ 전환 애니메이션)
    private var catPreview: some View {
        VStack(spacing: Theme.Spacing.m) {
            ZStack {
                if let fid = vm.featuredPoseId {
                    CatThumbnail(poseId: fid, size: 140)
                        .id(fid)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Theme.Color.surfaceAlt)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "pawprint")
                                .font(.system(size: 44))
                                .foregroundStyle(Theme.Color.textSecondary)
                        )
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.72), value: vm.featuredPoseId)

            Text(vm.featuredPoseId.flatMap { PoseCatalog.pose(for: $0)?.nameKo } ?? "대표 자세를 골라주세요")
                .font(Theme.Font.headline)
                .foregroundStyle(vm.featuredPoseId == nil ? Theme.Color.textSecondary : Theme.Color.text)
        }
    }

    // MARK: - 자세 다중선택
    private var poseSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader(title: "오늘 한 자세")
            FlowLayout(spacing: Theme.Spacing.s) {
                ForEach(PoseCatalog.all) { pose in
                    PoseChip(
                        title: pose.nameKo,
                        isSelected: vm.selectedPoseIds.contains(pose.id)
                    ) {
                        withAnimation { vm.togglePose(pose.id) }
                    }
                }
            }
        }
    }

    // MARK: - 대표 자세 선택
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader(title: "대표 자세 (썸네일)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.m) {
                    ForEach(vm.selectedPoseIds, id: \.self) { id in
                        Button {
                            withAnimation { vm.setFeatured(id) }
                        } label: {
                            VStack(spacing: Theme.Spacing.xs) {
                                CatThumbnail(poseId: id, size: 56)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 56 * 0.28, style: .continuous)
                                            .stroke(Theme.Color.text, lineWidth: vm.featuredPoseId == id ? 3 : 0)
                                    )
                                Text(PoseCatalog.pose(for: id)?.nameKo ?? id)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.Color.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - 컨디션
    private var energySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader(title: "오늘 컨디션")
            HStack(spacing: Theme.Spacing.s) {
                ForEach(EnergyLevel.allCases) { level in
                    Button {
                        withAnimation { vm.energy = (vm.energy == level ? nil : level) }
                    } label: {
                        VStack(spacing: Theme.Spacing.xs) {
                            Text(level.face).font(.system(size: 28))
                            Text(level.label)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.s)
                        .background(vm.energy == level ? Theme.Color.surfaceAlt : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 메모
    private var memoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader(title: "메모")
            AppTextField(placeholder: "오늘 수련은 어땠나요?", text: $vm.memo, axis: .vertical)
                .frame(minHeight: 88, alignment: .top)
        }
    }

    // MARK: - 수련 시간
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader(title: "수련 시간 (분)")
            AppTextField(placeholder: "예: 30", text: $vm.durationText, keyboard: .numberPad)
        }
    }
}
