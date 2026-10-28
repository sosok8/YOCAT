# YOCAT — 고양이 요가 일지 🐱🧘

요가 수련을 마친 뒤 그날의 메모와 핵심 자세를 고르면, 그 자세를 취한 고양이 일러스트가 일지 썸네일로 표시되는 감성 미색 iOS 앱.

- **플랫폼:** iOS 17.0+ / iPhone
- **스택:** SwiftUI · SwiftData · Swift Charts · UserNotifications (Apple 프레임워크만, 외부 의존성 0)
- **아키텍처:** SwiftUI + `@Observable` 뷰모델(MVVM), 디자인 토큰(Theme) 중앙화

## 폴더 구조

```
YOCAT/
├─ App/            앱 진입점·루트 탭 (RootTabView)
├─ DesignSystem/   디자인 토큰(Theme) + 공통 컴포넌트
│                  (AppScreen, Card, AppButton, PoseChip, AppTextField,
│                   EmptyStateView, SectionHeader, CatThumbnail)
├─ Models/         Pose 정적 카탈로그, PoseCategory, PoseCatArt, EnergyLevel
├─ Features/       기능별 화면 (Calendar / Goals / Settings)
└─ Assets.xcassets 색상 Color Set + 고양이 일러스트 에셋
```

## 디자인 토큰

색·간격·반경·폰트는 **하드코딩하지 않고** `Theme` 에서만 가져다 쓴다.
색상은 `Assets.xcassets` 의 Color Set으로 정의되어 있고 `Theme.Color.primary` 처럼 접근한다.

## 🐱 고양이 일러스트 추가하는 법 (★ 중요)

고양이 SVG는 **직접 만들어** 에셋 카탈로그에 넣는다. 코드 수정은 필요 없다.

1. `Assets.xcassets` 에 **New Image Set** 추가
2. 이미지 셋 이름을 **`cat_pose_<자세id>`** 로 지정
   - 예: 고양이 자세 → `cat_pose_cat`, 다운독 → `cat_pose_down_dog`
   - 자세 id 목록은 `Models/PoseCatalog.swift` 참고 (cat, cow, down_dog, up_dog, child, warrior2, tree, cobra, pigeon, triangle, lotus, savasana)
3. SVG 파일을 이미지 셋에 드래그
4. 우측 Attributes Inspector에서:
   - **Preserve Vector Data** ✅ 체크
   - **Scales** → **Single Scale** 선택
5. 끝. 해당 자세를 쓰는 모든 화면에 자동 반영된다.

> **폴백:** 에셋이 아직 없으면 앱이 깨지지 않고 발바닥(`pawprint.fill`) + 카테고리 색 배경 플레이스홀더를 보여준다. 즉, 에셋을 하나도 안 넣어도 모든 화면이 정상 동작한다.

## 실행

Xcode에서 `YOCAT.xcodeproj` 열고 iPhone 시뮬레이터 선택 후 ⌘R.
