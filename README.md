# 책갈피 (Bookmark)

친구와 책 읽기 진행률을 공유하는 iOS 앱

<br>

## 📖 소개
책갈피는 친구들과 함께 독서 진행률을 공유하고, 오늘 읽은 내용을 한 줄로 기록하는 심플한 독서 앱입니다.

<br>

## 📱 주요 기능
- 책 검색 및 추가 (카카오 책 검색 API)
- 읽은 페이지 스크롤로 입력 → 퍼센트 자동 계산
- 친구 코드로 추가 → 친구 진행률 공유
- 그날 읽은 내용 한 줄 기록
- 위젯으로 나 + 친구 진행률 확인

<br>

## 🛠 기술 스택
| 분류 | 기술 |
|---|---|
| UI | SwiftUI |
| 아키텍처 | TCA |
| 비동기 | Combine, Swift Concurrency |
| 로컬 저장 | SwiftData |
| 서버 | Firebase (Auth, Firestore) |
| 위젯 | WidgetKit |
| 온보딩 | TipKit |
| 로그인 | Apple Login, Kakao Login |
| 프로젝트 관리 | Tuist |
| 최소 버전 | iOS 17+ |
| Swift 버전 | Swift 6 |

<br>

## 📁 프로젝트 구조
```
Bookmark/
├── Sources/
│   ├── App/
│   ├── Feature/
│   │   ├── Home/
│   │   ├── Search/
│   │   ├── Friends/
│   │   └── Settings/
│   ├── Core/
│   │   ├── Models/
│   │   ├── Network/
│   │   └── Storage/
│   └── Widget/
├── Resources/
├── Project.swift
└── Tuist/
```

<br>

## 🚀 시작하기
```bash
# Tuist 설치
mise install tuist

# 프로젝트 생성
tuist generate
```

<br>

## 📸 스크린샷
추후 업데이트 예정
