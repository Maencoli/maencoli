# Maencoli

책을 읽으며 페이지를 촬영하고, 인식된 텍스트에서 문장을 선택해 하이라이트로 저장하는 iOS 앱 MVP입니다.
Swift/SwiftUI 네이티브로 작성했으며, 데이터는 기기 로컬(SwiftData)에만 저장됩니다.

## 빌드 방법 (macOS + Xcode 필요)

이 코드는 Xcode/Swift 컴파일러가 없는 Linux 환경에서 작성되어, **아직 실제 빌드로 검증되지 않았습니다.**
Xcode에서 처음 열었을 때 사소한 문법 오류가 있을 수 있으니, 먼저 빌드해서 에러를 확인해주세요.

1. Xcode 15 이상 설치
2. [XcodeGen](https://github.com/yonaskolb/XcodeGen) 설치: `brew install xcodegen`
3. 프로젝트 루트에서 `xcodegen generate` 실행 → `Maencoli.xcodeproj` 생성
4. `Maencoli.xcodeproj` 열기
5. `Maencoli/Resources/Info.plist`의 `AladinTTBKey` 값을 [알라딘 Open API](https://www.aladin.co.kr/ttb/wblog_manager.aspx)에서 발급받은 키로 채우기 (없으면 도서 검색 기능만 비활성화되고 나머지는 정상 동작)
6. `Maencoli/Resources/Assets.xcassets/AppIcon.appiconset`에 1024x1024 앱 아이콘 추가 (현재는 빈 슬롯)
7. 카메라 기능은 시뮬레이터에서 테스트할 수 없으므로 **실기기**에서 실행 권장 (시뮬레이터에서는 자동으로 포토 라이브러리로 대체됩니다)

## 구조

```
Maencoli/
  App/            앱 진입점 (SwiftData ModelContainer 구성)
  Models/         Book, Highlight (SwiftData @Model)
  Support/        ISO week 계산, 책등 두께 계산, 사진 파일 저장
  Services/       Vision OCR 래퍼, 알라딘 도서 검색 API 클라이언트
  Views/
    Shelf/        홈 화면 책장 (책등 두께/줄바꿈 배치)
    BookDetail/   책 상세, 주간(ISO week) 미분류 하이라이트 상세
    BookPicker/   책 검색/직접 추가 공용 플로우
    Capture/      촬영 -> OCR -> 하이라이트 선택 -> 책 연결 플로우
```

## MVP 스펙 매핑

| 스펙 | 구현 |
|---|---|
| 2. 페이지 촬영 | `CameraCaptureView` (카메라 우선, 시뮬레이터는 포토 라이브러리로 폴백) |
| 3. 텍스트 인식/선택 하이라이트 | `TextRecognitionService`(Vision OCR) + `SelectableTextView`(UITextView 네이티브 드래그 선택) |
| 3.1 페이지 번호 자동 인식 | `TextRecognitionService.guessPageNumber` — 상/하단 여백에 위치한 짧은 숫자 줄을 탐지 |
| 3.2/3.3 페이지 번호 수동 입력/수정 | 촬영 직후 `HighlightSelectionView`, 저장 후에는 `HighlightRow`에서 수정 가능 |
| 4. 책별로 하이라이트 연결 | `Highlight.book` 관계, `AssignBookView` |
| 4.1 책 검색/직접 추가 | `AladinSearchView`(알라딘 API), `ManualBookEntryView` |
| 홈 책장 UI (책 두께 반영) | `SpineWidthCalculator` + `ShelfRowBuilder`(줄바꿈 배치) |
| 제목 미지정 시 주단위(ISO week) 그룹 | `ISOWeekHelper` + `WeekGroupDetailView`, "책으로 병합" 버튼으로 나중에 실제 책과 연결 |

## 알려진 한계 / 다음 단계

- **빌드 미검증**: 위에서 언급한 대로 Xcode에서 처음 열었을 때 빌드 에러가 있을 수 있습니다.
- **알라딘 API 응답 스키마**: `subInfo.itemPage`(페이지 수) 필드명은 실제 API 응답으로 검증하지 못했습니다. TTBKey 발급 후 실제 응답을 보고 `AladinBookService.swift`를 조정해주세요.
- **책등 시각 디자인**: 현재는 단색 그라데이션 + 회전 텍스트로 표현한 placeholder입니다. 실제 책 표지/질감 디자인은 추후 작업이 필요합니다.
- **책장 "확장" 로직**: 스펙의 "작은 책장 → 큰 책장" 전환은 현재 여러 줄로 자연스럽게 늘어나는 방식으로 단순화했습니다. 실제 책장 이미지 에셋을 쓰는 디자인으로 발전시킬 수 있습니다.
- **동기화**: 현재는 기기 로컬 저장(SwiftData)만 지원합니다. 기기 변경 시 데이터가 이전되지 않으니, iCloud(CloudKit) 동기화는 다음 단계로 고려해주세요.
- **Android 확장**: 지금은 Swift/SwiftUI 네이티브로 시작했습니다. Android는 Kotlin으로 별도 앱을 만들되, `Models`/`Services`/`Support`에 정리된 데이터 모델과 비즈니스 로직(스펙 매핑 표 참고)을 그대로 포팅 기준으로 삼으면 됩니다.
- **접근성/다크모드/공유(내보내기)/하이라이트 검색**: MVP 범위 밖으로 우선 제외했습니다.
