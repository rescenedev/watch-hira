# 일본어공부 (KanaStudy)

히라가나·가타카나부터 JLPT 단어·여행 회화까지, iPhone과 Apple Watch에서 익히는 일본어 학습 앱.

🔗 **랜딩 페이지: https://rescenedev.github.io/watch-hira/**

## 기능

- **학습 카드**: 세로로 넘기는 플래시카드. 가나 문자를 탭하면 로마자 발음이 표시됩니다.
- **퀴즈**: 가나 문자를 보고 4지선다 로마자 보기 중 정답을 고르는 10문제 퀴즈. 스크립트별 최고 점수가 저장됩니다.
- **학습 범위**: 청음(46자) 기본, 탁음·반탁음(25자) 포함 토글 지원.
- **JLPT·여행 단어**: N3·N5·N4 핵심 단어와 여행 회화를 한자·후리가나·뜻으로.
- **배운 단어 (날짜별)**: 카드를 넘긴 단어가 오늘·어제·날짜별로 쌓입니다. 단어마다 일상회화·여행 예문(가나는 그 글자가 든 예시 단어로 만든 문장)을 함께 보여줍니다. iPhone은 예문, Apple Watch는 단어로 표시됩니다.
- **간격 반복 복습 알림**: 매일 아침 9시, 복습할 단어 하나를 알림으로 보냅니다. 알림을 누르면 배운 단어 화면으로 바로 이동(딥링크)합니다. 배운 단어 목록에서 외운 단어를 스와이프하면 3일 → 1주 → 1달로 다음 알림 간격이 멀어지고, 마지막 단계에서 또 스와이프하면 영구히 사라집니다.
- **발음 듣기**: 탭하면 TTS로 읽어줍니다. 일본어·영어를 자동 감지해 알맞은 음성으로 발음합니다.
- **Anki 가져오기**: `.apkg` 덱을 그대로 불러와 내 단어장으로 (iOS).

## 구조

```
├── project.yml          # XcodeGen 프로젝트 정의
├── App/                 # watchOS SwiftUI 앱
│   ├── KanaStudyApp.swift
│   └── Views/           # MenuView, ScriptHomeView, StudyView, QuizView, QuizResultView
└── KanaCore/            # 플랫폼 독립 Swift Package (데이터 + 퀴즈 엔진)
    ├── Sources/KanaCore/    # Kana, KanaData, QuizEngine
    └── Tests/KanaCoreTests/ # 단위 테스트 20개
```

## 빌드

Xcode 26 이상과 [XcodeGen](https://github.com/yonaskolb/XcodeGen)이 필요합니다.

```sh
xcodegen generate
open KanaStudy.xcodeproj
```

CLI 빌드:

```sh
xcodebuild -project KanaStudy.xcodeproj -scheme KanaStudy \
  -destination 'generic/platform=watchOS Simulator' build
```

## 테스트

코어 로직(KanaCore)은 macOS에서 바로 테스트할 수 있습니다.

```sh
cd KanaCore && swift test
```
