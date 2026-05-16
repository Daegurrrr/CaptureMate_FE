# CaptureMate_FE
CaptureMate 프론트엔드 레포입니다!

---

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Repository
- **Networking**: URLSession / APIClient
- **Lint**: SwiftLint (Swift Package Plugin)
- **Backend**: FastAPI
- **OCR Server**: PaddleOCR
- **AI Classification**: LLM / KoBERT 기반 분류

---

## Requirements

- Xcode 16+
- iOS 18+
- SwiftLint enabled via Swift Package Plugin

---

## Getting Started

1. 저장소를 clone 합니다.

```bash
git clone <repo-url>
```

2. Xcode에서 프로젝트를 엽니다.
`CaptureMate.xcodeproj`

3. Xcode가 Swift Package Dependencies를 resolve할 때까지 기다립니다.

4. 환경 설정 파일을 준비합니다.
`Config/Secrets.example.xcconfig`를 복사하여
`Secrets.xcconfig` 파일을 생성합니다.

5. 시뮬레이터를 선택하고 Run 합니다.

---

## Project Structure
CaptureMate_FE
├── CaptureMate.xcodeproj       # Xcode project file
├── CaptureMate                 # Main app source code
│
│   ├── App                     # App entry and root view
│   │   ├── CaptureMateApp.swift
│   │   └── RootView.swift
│
│   ├── Core                    # Shared infrastructure
│   │   ├── Network             # APIClient, Endpoint, Network layer
│   │   ├── Extensions          # Swift extensions
│   │   └── Utils               # Utility helpers
│
│   ├── Data                    # Data layer
│   │   ├── DTO                 # API response models
│   │   └── Repository          # Server communication logic
│
│   ├── Features                # Feature-based UI modules
│   │   ├── Home
│   │   │   ├── HomeView.swift
│   │   │   └── HomeViewModel.swift
│   │   ├── CaptureUpload
│   │   ├── Analysis
│   │   └── Settings
│
│   ├── DesignSystem            # Reusable UI components
│   │   ├── Components
│   │   └── Styles
│
│   ├── Resources               # Static resources
│   │   ├── Assets.xcassets
│   │   └── Fonts
│
│   └── Config                  # Environment configuration
│       ├── Dev.xcconfig
│       ├── Prod.xcconfig
│       └── Secrets.example.xcconfig
│
├── CaptureMateTests            # Unit tests
├── CaptureMateUITests          # UI tests
└── README.md

---

## Architecture Overview
The app follows a layered architecture:

View → ViewModel → Repository → APIClient → Backend

- **View (SwiftUI)**: UI components
- **ViewModel**: UI state management
- **Repository**: Business logic and data fetching
- **APIClient**: Networking layer communicating with FastAPI backend

---

## Branch Strategy
- `main`: 배포/기준 브랜치
- `develop`: 개발 기준 브랜치
- `feature/#이슈번호`: 기능 개발 브랜치

---

## Development Flow

feature branch → develop → main

- `main` : production branch
- `develop` : development branch
- `feature/#issue-number` : feature implementation

---

## Conventions
- View에서 API 직접 호출 금지
- 상태 관리는 ViewModel
- API 호출은 Repository / APIClient
- 공통 UI는 DesignSystem에 추가
