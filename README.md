# 일본어공부 (KanaStudy)

히라가나·가타카나부터 JLPT 단어·여행 회화까지, iPhone과 Apple Watch에서 익히는 일본어 학습 앱.

🔗 **랜딩 페이지: https://rescenedev.github.io/watch-hira/**

## 기능

- **학습 카드**: 세로로 넘기는 플래시카드. 가나 문자를 탭하면 로마자 발음이 표시됩니다.
- **퀴즈**: 가나 문자를 보고 4지선다 로마자 보기 중 정답을 고르는 10문제 퀴즈. 스크립트별 최고 점수가 저장됩니다.
- **학습 범위**: 청음(46자) 기본, 탁음·반탁음(25자) 포함 토글 지원.

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
