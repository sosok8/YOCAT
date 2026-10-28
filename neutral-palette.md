# Greyscale — Neutral 0 → 1000

YOCAT 디자인 시스템의 그레이스케일 팔레트입니다. 순수 회색이 아니라 색상 45~53도의 따뜻한 축을 따르며, 어두워질수록 채도를 낮춰 카키 기운 없이 차분하게 떨어집니다.

- 기준값: `neutral-200` (#EFEEE7), `neutral-300` (#E8E6DD)
- 양 끝: `neutral-0` 순백, `neutral-1000` 순흑
- 채도: 20% → 6%, 명도: 100% → 0%
- 기본 페이지 배경은 `neutral-200`이고, 그보다 밝은 틴트가 필요할 때 `neutral-100`을 씁니다.

## 브랜드 컬러

| 역할 | 변수 | HEX | RGB | HSL | 흰 배경 대비 | 용도 |
|---|---|---|---|---|---|---|
| Primary | `color/primary` | `#11AAD7` | 17 170 215 | 194 85% 45% | 2.71 | 주요 버튼, 활성 상태, 강조 채움 |
| Secondary | `color/secondary` → neutral-1000 | `#000000` | 0 0 0 | 0 0% 0% | 21.0 | 보조 버튼, 강한 대비가 필요한 요소 |

Primary는 채움 색으로 쓰고 텍스트 색으로는 쓰지 않습니다. 흰 배경 위 글자로 쓰면 2.71대 1로 큰 글자 기준인 3대 1에도 못 미칩니다.

Primary 위에 올리는 라벨은 흰색이 아니라 검정 계열을 씁니다.

| 라벨 색 | Primary 배경 위 대비 | 판정 |
|---|---|---|
| `#000000` neutral-1000 | 7.75 | AA 통과 |
| `#2E2D29` neutral-900 | 5.09 | AA 통과 |
| `#FFFFFF` neutral-0 | 2.71 | 불합격 |

Secondary는 `neutral-1000`을 참조하는 별칭이라 팔레트와 항상 같은 값을 유지합니다.

## 스케일

| 토큰 | HEX | RGB | HSL | 흰 배경 대비 | 검정 배경 대비 | 용도 |
|---|---|---|---|---|---|---|
| neutral-0 | `#FFFFFF` | 255 255 255 | 0 0% 100% | 1.00 | 21.0 | 틴트 배경 위의 카드, 시트 |
| neutral-100 | `#F7F6F3` | 247 246 243 | 45 20% 96% | 1.08 | 19.4 | 가장 밝은 틴트, 떠 있는 표면 |
| neutral-200 | `#EFEEE7` | 239 238 231 | 53 20% 92% | 1.16 | 18.1 | 기본 페이지 배경 |
| neutral-300 | `#E8E6DD` | 232 230 221 | 49 19% 89% | 1.25 | 16.8 | 은은한 채움, 호버 상태 |
| neutral-400 | `#D2CFC6` | 210 207 198 | 45 12% 80% | 1.56 | 13.5 | 헤어라인, 구분선, 입력 테두리 |
| neutral-500 | `#B5B2A6` | 181 178 166 | 48 9% 68% | 2.12 | 9.88 | 비활성 채움, 조용한 콜아웃 |
| neutral-600 | `#959183` | 149 145 131 | 47 8% 55% | 3.16 | 6.66 | 플레이스홀더, 큰 글자 전용 |
| neutral-700 | `#6D6A5F` | 109 106 95 | 47 7% 40% | 5.42 | 3.88 | 보조 텍스트, AA 통과 |
| neutral-800 | `#514F48` | 81 79 72 | 47 6% 30% | 8.20 | 2.56 | 다크 모드의 떠 있는 패널 |
| neutral-900 | `#2E2D29` | 46 45 41 | 48 6% 17% | 13.8 | 1.52 | 본문 잉크, 다크 모드 배경 |
| neutral-1000 | `#000000` | 0 0 0 | 0 0% 0% | 21.0 | 1.00 | 최대 대비가 필요할 때만 |

대비는 WCAG 명암비입니다. 본문처럼 작은 글자는 4.5대 1이 필요하므로 흰 배경에서는 `neutral-700`부터 씁니다. `neutral-600`은 18px 이상 또는 14px 굵은 글자에만 허용됩니다.

## 텍스트 컬러

기본 배경인 `neutral-200`(#EFEEE7) 위에서 측정한 값입니다.

| 역할 | 변수 | 참조 | HEX | 대비 | 용도 |
|---|---|---|---|---|---|
| Primary | `color/text` | neutral-1000 | `#000000` | 18.05 | 제목과 본문 |
| Secondary | `color/textSecondary` | neutral-700 | `#6D6A5F` | 4.66 | 보조 문구, 캡션, 메타 정보 |
| Tertiary | `color/textTertiary` | neutral-600 | `#959183` | 2.71 | 플레이스홀더와 비활성 텍스트 전용 |
| Inverse | `color/textInverse` | neutral-0 | `#FFFFFF` | 13.78 | neutral-800 ~ 1000 배경 위의 텍스트 |

네 토큰 모두 프리미티브를 참조하는 별칭입니다. 팔레트 값을 바꾸면 텍스트 컬러도 함께 따라옵니다. Tertiary는 AA 기준 아래이므로 읽어야 하는 문구에는 쓰지 않습니다.

## 조합

**라이트 서피스**
배경 `neutral-200`, 카드 `neutral-0`, 구분선 `neutral-400`, 본문 `neutral-900`, 보조 텍스트 `neutral-700`. 본문 대비는 11.9대 1입니다.

**다크 서피스**
배경 `neutral-900`, 패널 `neutral-800`, 구분선 `neutral-700`, 본문 `neutral-200`, 보조 텍스트 `neutral-500`. 다크 모드에서도 같은 따뜻한 축을 유지해 색이 푸르게 틀어지지 않습니다.

**뮤티드 블록**
배경 `neutral-400`, 텍스트 `neutral-900`, 아웃라인 `neutral-700`. `neutral-400`은 900 잉크를 8.9대 1로 받는 가장 어두운 값입니다.

## 토큰

### CSS

```css
:root {
  --neutral-0:    #FFFFFF;
  --neutral-100:  #F7F6F3;
  --neutral-200:  #EFEEE7;
  --neutral-300:  #E8E6DD;
  --neutral-400:  #D2CFC6;
  --neutral-500:  #B5B2A6;
  --neutral-600:  #959183;
  --neutral-700:  #6D6A5F;
  --neutral-800:  #514F48;
  --neutral-900:  #2E2D29;
  --neutral-1000: #000000;

  --primary:   #11AAD7;
  --secondary: var(--neutral-1000);

  --text-primary:   var(--neutral-1000);
  --text-secondary: var(--neutral-700);
  --text-tertiary:  var(--neutral-600);
  --text-inverse:   var(--neutral-0);
}
```

### Swift

```swift
extension Color {
    static let neutral0    = Color(hex: 0xFFFFFF)
    static let neutral100  = Color(hex: 0xF7F6F3)
    static let neutral200  = Color(hex: 0xEFEEE7)
    static let neutral300  = Color(hex: 0xE8E6DD)
    static let neutral400  = Color(hex: 0xD2CFC6)
    static let neutral500  = Color(hex: 0xB5B2A6)
    static let neutral600  = Color(hex: 0x959183)
    static let neutral700  = Color(hex: 0x6D6A5F)
    static let neutral800  = Color(hex: 0x514F48)
    static let neutral900  = Color(hex: 0x2E2D29)
    static let neutral1000 = Color(hex: 0x000000)

    static let primary   = Color(hex: 0x11AAD7)
    static let secondary = neutral1000

    static let textPrimary   = neutral1000
    static let textSecondary = neutral700
    static let textTertiary  = neutral600
    static let textInverse   = neutral0
}
```

### JSON

```json
{
  "color": {
    "neutral": {
      "0":    { "value": "#FFFFFF" },
      "100":  { "value": "#F7F6F3" },
      "200":  { "value": "#EFEEE7" },
      "300":  { "value": "#E8E6DD" },
      "400":  { "value": "#D2CFC6" },
      "500":  { "value": "#B5B2A6" },
      "600":  { "value": "#959183" },
      "700":  { "value": "#6D6A5F" },
      "800":  { "value": "#514F48" },
      "900":  { "value": "#2E2D29" },
      "1000": { "value": "#000000" }
    },
    "primary":   { "value": "#11AAD7" },
    "secondary": { "value": "{color.neutral.1000}" },
    "text": {
      "primary":   { "value": "{color.neutral.1000}" },
      "secondary": { "value": "{color.neutral.700}" },
      "tertiary":  { "value": "{color.neutral.600}" },
      "inverse":   { "value": "{color.neutral.0}" }
    }
  }
}
```

## Figma

- 파일: YOCAT, [Color System 섹션](https://www.figma.com/design/BhqH5fHNBMWi5leqEDkccT/YOCAT?node-id=116-5515)
- 변수: `YOCAT` 컬렉션, `Light` 모드
  - 프리미티브 `color/neutral/0` ~ `color/neutral/1000`, 스코프는 프레임과 도형 채우기, 텍스트, 선 색
  - 브랜드 `color/primary`, `color/secondary`, 스코프는 프레임과 도형 채우기, 텍스트, 선 색
  - 시맨틱 `color/text`, `color/textSecondary`, `color/textTertiary`, `color/textInverse`, 스코프는 텍스트 채우기
- 문서 표의 색상 칩과 텍스트 샘플은 변수에 바인딩되어 있어 변수 값을 바꾸면 문서도 함께 갱신됩니다.
