# CaptureMate_FE
CaptureMate 프론트엔드 레포입니다!
AI 기반 스크린샷 분석 및 행동 추천 서비스의 iOS 애플리케이션 프로젝트입니다.


## 🧱 기술 스택
| 구분 | 기술 |
|---|---|
| 언어 | Swift |
| UI 프레임워크 | SwiftUI |
| 아키텍처 | MVVM + Repository |
| 네트워킹 | URLSession / APIClient |
| 코드 스타일 관리 | SwiftLint |


## 📱 지원 환경

- Xcode 16+
- iOS 18+
- SwiftLint (Swift Package Plugin)


## 🚀 실행 방법

1. 저장소를 clone 합니다.

```bash
git clone https://github.com/Daegurrrr/CaptureMate_FE
```

2. Xcode에서 프로젝트를 엽니다.
`CaptureMate.xcodeproj`

3. Xcode가 Swift Package Dependencies를 resolve할 때까지 기다립니다.

4. 환경 설정 파일을 준비합니다.
`Config/Secrets.example.xcconfig`를 복사하여
`Secrets.xcconfig` 파일을 생성합니다.

5. 시뮬레이터를 선택하고 Run 합니다.


## 📁 프로젝트 구조
```text
CaptureMate_FE
├── CaptureMate.xcodeproj       # Xcode project file
├── CaptureMate                 # 메인 앱 소스 코드
│
│   ├── App                     # 앱 진입점 및 루트 화면 관리
│   ├── Core                    # 네트워크, 확장 함수, 공통 유틸 등 프로젝트 전반에서 사용하는 공통 인프라
│   ├── Data                    # DTO, Repository 등 데이터 처리 및 서버 통신 관련 레이어
│   ├── Features                # 기능 단위로 분리된 화면 및 비즈니스 로직 모듈
│   ├── DesignSystem            # 재사용 가능한 UI 컴포넌트 및 스타일 관리
│   ├── Resources               # 이미지, 폰트, Asset 등 정적 리소스 관리
│   └── Config                  # 환경 변수 및 빌드 설정 파일 관리
│
├── CaptureMateTests            # Unit tests
├── CaptureMateUITests          # UI tests
└── README.md
```


## ⚙️ 아키텍처
프로젝트는 Layered Architecture 기반으로 구성되어 있습니다.

View → ViewModel → Repository → APIClient → Backend

- **View (SwiftUI)**: UI 구성
- **ViewModel**: 상태 관리 및 UI 로직
- **Repository**: 데이터 처리 및 비즈니스 로직
- **APIClient**: 서버 통신
- **Backend**: OCR/AI/DB 처리
