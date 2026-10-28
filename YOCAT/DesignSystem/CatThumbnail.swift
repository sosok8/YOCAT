//
//  CatThumbnail.swift
//  YOCAT
//
//  ★ 핵심 컴포넌트.
//  자세 id를 받아 고양이 일러스트(cat_pose_<id>)를 렌더링한다.
//  에셋이 아직 없으면 깨지지 않게 발바닥 폴백을 보여준다.
//  투톤 원칙: 배경은 중립(surfaceAlt), 컬러는 일러스트가 담당.
//

import SwiftUI
import UIKit

struct CatThumbnail: View {
    let poseId: String
    var size: CGFloat = 64

    private var corner: CGFloat { size * 0.28 }

    var body: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(Theme.Color.surfaceAlt)
            .frame(width: size, height: size)
            .overlay { artwork }
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(Theme.Color.border, lineWidth: 1)
            )
    }

    @ViewBuilder
    private var artwork: some View {
        let assetName = PoseCatArt.assetName(for: poseId)
        if let image = UIImage(named: assetName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(size * 0.12)
        } else {
            // 폴백: 에셋을 아직 등록하지 않았을 때
            Image(systemName: "pawprint.fill")
                .font(.system(size: size * 0.36))
                .foregroundStyle(Theme.Color.textSecondary)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        CatThumbnail(poseId: "cat")
        CatThumbnail(poseId: "tree")
        CatThumbnail(poseId: "savasana")
    }
    .padding()
    .background(Theme.Color.background)
}
