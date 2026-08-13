# CaptureMate_FE

CaptureMate iOS 프론트엔드 레포입니다.

CaptureMate는 사용자가 저장해둔 캡쳐 이미지를 자동으로 감지하고, AI 분석을 통해 캡쳐의 의도를 분류한 뒤 장소 보기, 상품 보기, 캘린더 저장 등 바로 실행 가능한 추천 액션을 제공하는 앱입니다.


## 🧱 기술 스택

| 구분 | 기술 |
|---|---|
| Language | Swift |
| UI | SwiftUI |
| Architecture | MVVM |
| Local DB | SwiftData |
| Network | URLSession / APIClient |
| Calendar | EventKit |
| Permission | Photos / Notification / Calendar |


## 📱 지원 환경

- Xcode 16+
- iOS 18+
- Swift 5+


## 🚀 실행 방법

1. 저장소를 clone 합니다.

```bash
git clone https://github.com/Daegurrrr/CaptureMate_FE
```

2. Xcode에서 프로젝트를 엽니다.

```text
`CaptureMate.xcodeproj`
```

3. 백엔드 서버를 실행합니다.

기본 API 주소는 아래 파일에서 관리합니다.
```text
CaptureMate/Core/Constants/APIConstants.swift
```

현재 기본값:

```swift
static let baseURL = "http://localhost:8000"
```

시뮬레이터가 아닌 실제 기기에서 테스트할 경우 `localhost` 대신 Mac의 로컬 IP 주소로 변경해야 합니다.

4. Xcode에서 시뮬레이터 또는 실제 기기를 선택하고 Run 합니다.


## 🔄 주요 플로우

```text
앱 실행
→ 온보딩
→ 사진/알림 권한 요청
→ 캡쳐 이미지 감지
→ POST /classify
   - 이미지 전달
   - 백엔드 내부 OCR 수행
   - OCR 텍스트 + 이미지 기반 멀티모달 분류
→ POST /gemini
   - OCR 텍스트 + 카테고리 전달
   - 카테고리별 상세 분석 결과 수신
→ SwiftData에 분석 결과 저장
→ 홈/카테고리/상세 화면에서 추천 액션 제공
```


## ✨ 주요 기능

- 앱 최초 실행 시 스플래시 및 온보딩 제공
- 사진 라이브러리에서 캡쳐 이미지 감지
- 백엔드 AI API를 통한 OCR 및 카테고리 분류
- Gemini 분석 결과를 SwiftData에 저장
- 카테고리별 캡쳐 목록 제공
- 캡쳐 상세 화면에서 분석 결과 표시
- 장소 분석 결과:
  - 지도 미리보기
  - 여러 장소 핀 표시
  - 장소별 선택 및 장소 보기
- 쇼핑 분석 결과:
  - 여러 상품 선택
  - 상품 보기 / 브랜드 보기 링크 제공
- 일정 분석 결과:
  - 여러 일정 선택
  - 캘린더 보기 버튼으로 iOS 캘린더 저장
- 홈 화면 추천 액션 제공
- 추천 액션 실행 후 목록에서 제거


## 📁 프로젝트 구조

```text
CaptureMate_FE
├── CaptureMate.xcodeproj
├── CaptureMate
│   ├── App
│   │   ├── CaptureMateApp.swift
│   │   ├── AppDelegate.swift
│   │   ├── Root
│   │   └── State
│   │
│   ├── Core
│   │   ├── Calendar
│   │   ├── Constants
│   │   ├── Network
│   │   ├── Notifications
│   │   └── Permissions
│   │
│   ├── Domain
│   │   └── Models
│   │
│   ├── Features
│   │   ├── Onboarding
│   │   ├── PhotoUpload
│   │   ├── Main
│   │   ├── Category
│   │   └── My
│   │
│   ├── Resources
│   │   └── Assets.xcassets
│   │
│   └── Info.plist
│
├── CaptureMateTests
├── CaptureMateUITests
└── README.md
```


## 🔐 권한

앱에서 사용하는 주요 권한은 다음과 같습니다.

| 권한 | 사용 목적 |
|---|---|
| Photos | 캡쳐 이미지 감지 및 표시 |
| Notifications | 새 캡쳐 감지 알림 |
| Calendars | 일정 분석 결과를 iOS 캘린더에 저장 |

캘린더 권한이 거부된 경우, 앱에서 설정 화면으로 이동할 수 있도록 처리되어 있습니다.


## 🗂️ 로컬 저장 데이터

분석 결과는 SwiftData를 통해 앱 내부 DB에 저장됩니다.

주요 저장 정보:

- localIdentifier
- OCR 텍스트
- 카테고리
- confidence
- Gemini 분석 결과
- 추천 액션 생성에 필요한 데이터
