//
//  PoseCatArt.swift
//  YOCAT
//
//  poseId → 고양이 에셋 이름 매핑 레지스트리.
//  규약: "cat_pose_<poseId>"  (예: cat_pose_down_dog)
//  자세를 추가/교체할 땐 이 규약에 맞춰 에셋만 넣으면 된다.
//

import Foundation

enum PoseCatArt {
    static func assetName(for poseId: String) -> String {
        "cat_pose_\(poseId)"
    }
}
