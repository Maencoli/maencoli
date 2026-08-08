# Maencoli

책을 읽으며 페이지를 촬영하고, 인식된 텍스트에서 문장을 선택해 하이라이트로 저장하는 iOS 앱 MVP입니다.
Swift/SwiftUI 네이티브로 작성했으며, 데이터는 기기 로컬(SwiftData)에만 저장됩니다.

## 데이터는 어디에 저장되나요?

[SwiftData](https://developer.apple.com/documentation/swiftdata)를 사용합니다 — 앱 샌드박스 안의 로컬 SQLite 파일에 저장되며,
앱을 껐다 켜거나 기기를 재부팅해도 그대로 유지됩니다. 앱을 완전히 삭제하기 전까지는 남아있어요.
**iCloud 동기화는 아직 없어서** 기기를 바꾸면 데이터가 넘어가지 않습니다 — 필요해지면 CloudKit 동기화를 다음 단계로 추가하면 됩니다.
사진은 촬영 세션 동안만 메모리에 있다가(디스크에 쓴 적이 없음) 화면을 나가면 그냥 사라집니다 — 저장/취소 어느 쪽이든 사진 자체는 남지 않습니다.

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
  App/            앱 진입점 (SwiftData ModelContainer 구성: Book, Highlight, Note)
  Models/         Book, Highlight, Note (SwiftData @Model)
  Support/        ISO week 계산, 책등 두께 계산
  Services/       Vision OCR 래퍼, 알라딘 도서 검색 API 클라이언트
  Views/
    Shelf/        홈 화면 책장 (책등 두께/줄바꿈 배치, 새 하이라이트 진입점)
    BookDetail/   책 상세, 주간(ISO week) 미분류 하이라이트 상세, 하이라이트/메모 카드 + 편집 시트
    BookPicker/   책 검색/직접 추가 공용 피커 (BookPickerView)
    Capture/      촬영/직접입력/메모만/책만 등록 — 4가지 추가 플로우
    Shared/        여러 플로우가 공유하는 BookChipView
```

## 데이터 모델

```
Book ──< Highlight ──< Note >── (book 또는 highlight 중 하나 이상에 항상 속함)
  └──────────────────────< Note (book에 직접 붙는 독립 메모)
```

- `Highlight.book`은 `nil`일 수 있습니다 — 아직 책을 정하지 않은 하이라이트는 저장된 주(ISO week)로 묶여 홈 화면에 "가짜 책"으로 표시됩니다(`WeekGroupDetailView`).
- **메모(`Note`)는 반드시 책 또는 하이라이트에 속합니다.** 하이라이트 하나에 메모를 여러 개 달 수 있고, 각각 따로 수정/삭제할 수 있습니다. "메모만 남기기"는 책 상세 화면에서만 열리고, 책을 고르기 전에는 저장할 수 없습니다(주간 그룹으로도 빠지지 않음).
- 책과 연결된 하이라이트를 삭제하면 딸린 메모는 그 책의 독립 메모로 남습니다(`Highlight.detachNotesBeforeDeletion`). 아직 책과 연결되지 않은 하이라이트를 삭제하면, 메모가 의지할 부모가 없어지므로 메모도 함께 삭제됩니다 — 삭제 확인창에 어느 경우인지 안내됩니다.

## 하이라이트/메모/책 추가하기 — 4가지 경로

"새 하이라이트" 진입점(홈 화면 하단 위젯, 또는 책 상세의 + 버튼)을 누르면 상황에 따라 다른 선택지가 뜹니다.

| 진입 위치 | 선택지 |
|---|---|
| 홈 화면 | 📷 사진으로 추가 · ⌨️ 직접 입력하기 · 📚 책만 등록하기 |
| 책 상세 화면 | 📷 사진으로 추가 · ⌨️ 직접 입력하기 · ✎ 메모만 남기기 |

- **사진으로 추가** (`CaptureFlowView`): 촬영 → Vision OCR → 문장을 드래그로 선택해 하이라이트로 추가(여러 개 가능, 각각 메모 가능) → 책 선택(선택 안 하면 이번 주 기록으로) → 저장. 저장 버튼은 하이라이트가 1개 이상 담겨야 활성화되고, 몇 개를 어디에 저장하는지 힌트가 항상 보입니다.
- **직접 입력하기** (`ManualEntryView`): 사진 없이 문장 하나 + 메모 + 페이지를 직접 입력.
- **메모만 남기기** (`MemoOnlyEntryView`): 책 상세에서만 진입 가능, 책이 정해져야만 저장 버튼이 켜집니다.
- **책만 등록하기** (`BookOnlyEntryView`): 하이라이트/메모 없이 책 정보(제목/저자/페이지수)만 저장해 책장에 꽂아둡니다. 홈에서만 뜨고, 책 상세에서는 숨겨집니다(이미 책이 정해져 있으니).

취소 처리: 담아둔 내용이 없으면 바로 나가고, 하나라도 있으면 "지금까지 담은 내용이 사라져요" 확인창이 뜹니다. 시스템 카메라의 자체 "취소" 버튼도 같은 규칙을 탑니다(`imagePickerControllerDidCancel`).

## MVP 스펙 매핑

| 스펙 | 구현 |
|---|---|
| 2. 페이지 촬영 | `CameraCaptureView` (카메라 우선, 시뮬레이터는 포토 라이브러리로 폴백) |
| 3. 텍스트 인식/선택 하이라이트 | `TextRecognitionService`(Vision OCR) + `SelectableTextView`(UITextView 네이티브 드래그 선택) |
| 3.1 페이지 번호 자동 인식 | `TextRecognitionService.guessPageNumber` — 상/하단 여백에 위치한 짧은 숫자 줄을 탐지 |
| 3.2/3.3 페이지 번호 수동 입력/수정 | 촬영 직후 `HighlightSelectionView`, 저장 후에는 `EditHighlightSheet`에서 수정 가능 |
| 4. 책별로 하이라이트 연결 | `Highlight.book` 관계, 각 진입 화면의 `BookChipView` → `BookPickerView` |
| 4.1 책 검색/직접 추가 | `AladinSearchView`(알라딘 API), `BookPickerView`의 인라인 "새 책 추가" |
| 홈 책장 UI (책 두께 반영) | `SpineWidthCalculator` + `ShelfRowBuilder`(줄바꿈 배치) |
| 제목 미지정 시 주단위(ISO week) 그룹 | `ISOWeekHelper` + `WeekGroupDetailView`, "책으로 연결하기" 버튼으로 나중에 실제 책과 연결 |

## 알려진 한계 / 다음 단계

- **빌드 미검증**: 위에서 언급한 대로 Xcode에서 처음 열었을 때 빌드 에러가 있을 수 있습니다.
- **알라딘 API 응답 스키마**: `subInfo.itemPage`(페이지 수) 필드명은 실제 API 응답으로 검증하지 못했습니다. TTBKey 발급 후 실제 응답을 보고 `AladinBookService.swift`를 조정해주세요.
- **책등 시각 디자인**: 현재는 그라데이션 + 회전 텍스트 placeholder입니다. 책등 색상 팔레트는 참고 이미지에 맞춰 채도 높은 색으로 맞췄고(`ShelfItem.SpineColor`), 실제 표지/질감 디자인은 추후 작업이 필요합니다.
- **홈 화면 진입 위젯**: "펜과 노트" 컨셉을 SF Symbol(`square.and.pencil`) 기반 카드로 단순화했습니다(`AddHighlightWidget`). 커스텀 일러스트로 발전시킬 수 있습니다.
- **책장 "확장" 로직**: 스펙의 "작은 책장 → 큰 책장" 전환은 현재 여러 줄로 자연스럽게 늘어나는 방식으로 단순화했습니다.
- **동기화**: 현재는 기기 로컬 저장(SwiftData)만 지원합니다. iCloud(CloudKit) 동기화는 다음 단계로 고려해주세요.
- **Android 확장**: Swift/SwiftUI 네이티브로 시작했습니다. Android는 Kotlin으로 별도 앱을 만들되, `Models`/`Services`/`Support`의 데이터 모델과 비즈니스 로직(스펙 매핑 표 참고)을 포팅 기준으로 삼으면 됩니다.
- **접근성/다크모드/공유(내보내기)/하이라이트 검색**: MVP 범위 밖으로 우선 제외했습니다.
