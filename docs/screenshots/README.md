# App Store 스크린샷

업로드 순서대로 번호를 매겼습니다. (App Store Connect: 기기별 최소 1장, 최대 10장)

## iPhone (`ios/`)
- 규격 **1320 × 2868** = iPhone 6.9" (iPhone 16/17 Pro Max). App Store가 작은 기기용으로 자동 축소.
- 01 메뉴·진도 / 02 배운 단어·예문 / 03 공부하기 / 04 JLPT 단어 / 05 퀴즈

## Apple Watch (`watch/`)
- 규격 **422 × 514** (Apple Watch Ultra 3, 49mm 네이티브).
- 01 메뉴 / 02 학습 카드 / 03 배운 단어 / 04 외웠어요 스와이프 / 05 보관함
- ⚠️ App Store Connect가 특정 워치 규격(예: Ultra 410×502)을 요구하면,
  해당 시뮬레이터에서 다시 캡처하거나 그 크기로 맞춰 리사이즈할 것.

캡처 방법: `xcrun simctl io <udid> screenshot out.png` (시뮬레이터 네이티브 해상도).
