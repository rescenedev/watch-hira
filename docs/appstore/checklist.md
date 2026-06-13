# App Store 제출 체크리스트

## 0. 사전 준비 (필수)
- [ ] **Apple Developer Program 가입 ($99/년)** — 현재 프로젝트는 개인(무료) 팀 `589U6DQJN8`으로 서명 중. 무료 팀으로는 App Store 제출이 불가능하므로 유료 멤버십 가입 후 App Store Connect에서 앱 레코드를 만들어야 합니다.
- [ ] 가입 후 Xcode > Settings > Accounts에서 새 팀 확인, `project.yml`의 `DEVELOPMENT_TEAM` 갱신

## 1. 번들 구조 결정 (제출 전 1회)
현재는 watchOS 앱(`com.zihado.kanastudy`)과 iOS 앱(`com.zihado.kanastudy.ios`)이 **독립 앱 2개**로 분리되어 있습니다. 선택지:

- **옵션 A (추천): iOS 앱에 watch 앱을 내장** — 스토어에 하나의 앱으로 올라가고, iPhone에서 설치하면 Watch에도 함께 설치됩니다. 번들 ID를 `com.zihado.kanastudy` (iOS) / `com.zihado.kanastudy.watchkitapp` (watch)으로 재구성 필요. project.yml 수정은 요청만 하면 바로 해드립니다.
- **옵션 B: watch 단독 앱 + iOS 앱 별도 제출** — 스토어에 2개 앱. 관리가 번거로워 비추천.

## 2. App Store Connect 설정
- [ ] 새 앱 생성: 이름·기본 언어(한국어)·번들 ID·SKU 입력
- [ ] `metadata.md`의 문구 복사: 이름 / 부제 / 프로모션 텍스트 / 설명 / 키워드
- [ ] 카테고리: 교육(기본), 여행(보조)
- [ ] 개인정보: "데이터를 수집하지 않음" + 처리방침 URL 입력
- [ ] 가격: 무료 (또는 원하는 가격)

## 3. 스크린샷 업로드 (`screenshots/` 폴더)
- [ ] iPhone 6.9" (1320×2868): `ios/1_menu.png` ~ `ios/5_quiz.png` — 그대로 업로드 가능
- [ ] Apple Watch (422×514, Ultra): `watch/1_menu.png` ~ `watch/4_quiz.png`
- 참고: 6.9" 한 세트만 올리면 작은 iPhone에는 자동 스케일됩니다.

## 4. 빌드 업로드
```sh
# 유료 팀 설정 후
xcodegen generate
xcodebuild -project KanaStudy.xcodeproj -scheme KanaStudyiOS \
  -destination 'generic/platform=iOS' archive \
  -archivePath build/KanaStudy.xcarchive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath build/KanaStudy.xcarchive \
  -exportOptionsPlist docs/appstore/ExportOptions.plist \
  -exportPath build/export -allowProvisioningUpdates
xcrun altool 대신: Xcode Organizer 또는 `xcrun notarytool`/Transporter로 업로드
```
(아카이브·업로드는 유료 팀 전환 후 요청하시면 자동화해 드립니다)

## 5. 심사 제출
- [ ] 심사 메모(`metadata.md` 하단) 입력: 오프라인 동작, 로그인 불필요
- [ ] 수출 규정: 암호화 사용 안 함 (`ITSAppUsesNonExemptEncryption = NO` — Info.plist에 추가해두면 매번 질문 생략)
- [ ] 제출 → 통상 24~48시간 내 심사

## 알려진 주의사항
- 앱 이름 '가나 학습'이 이미 사용 중이면 'KanaStudy — 히라가나·가타카나' 등으로 변경
- 첫 제출은 메타데이터 리젝이 흔하니 스크린샷과 설명이 실제 기능과 일치하는지 확인 (현재 문구는 모두 실제 기능 기준으로 작성됨)
