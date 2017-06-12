# Using AV Kit
- AVKit은 기본 운영체제 플레이어의 모양과 일치하는 AVFoundtaion 기반 비디오 플레이어를 만드는 프로세스를 단순화 함.

## AV Kit for iOS
- MPMoviePlayerController
- 표준 재생 제어 기능을 제공, 삽입하거나 전체 화면으로 표시가 할 수 있으며 AirPlay, Apple TV로 오디오 및 비디오 컨텐츠 스트리밍을 제공함
- 단점 : AVFoundation위에 구축되었지만 이러한 토대를 숨김. AVPlayer 및 AVPlayerItem에서 제공하는 일부 기능을 사용할 수 없게됨. AVKit은 이러한 단점을 보완함.
- AVPlayerViewController
- AVPlayer 인스턴스의 재생을 표시하고 제어하는데 사용되는 UIViewController의 하위 클래스임. 다음과 같은 속성이 존재.
- 속성
- player: AVPlayer 인스턴스가 미디어 컨텐츠를 재생하는데 사용
- showsPlaybackControls: 재생 컨트롤을 표시하거나 숨길지 여부
- videoGravity: 비디오 중력을 설정
- readyForDisplay: 비디오 내용이 준비되어 표시 준비가 되었는지 여부
- MPMoviePlayerController와 달리 controlsStyle 속성을 제공하지 않음. 대신 동적으로 업데이트 되는 동적 재생 컨트롤을 제공함.

## AV Kit for Mac OS X
- AVPlayerView
- AVPlayer 인스턴스의 재생을 표시하고 제어하는데 사용. 
- 현지화, 상태 복원, 전체 화면 재생, 고해상도 디스플레이 및 접근성 등의 기능을 제공

## Control Styles
- AVPlayerView는 사용자가 선택할 수 있는 다양한 컨트롤 스타일을 제공함.

### Intline
- AVPlayerView에서 사용되는 기본 스타일
- 표준 재생, 스크러빙 및 볼륨 컨트롤, 미디어에 데이터가 있을 때 표시되는 동적 챕터 및 자막 메뉴 제공함.

### Floating
- 표준 재생, 스크러빙 및 볼륨 컨트롤, 미디어에 데이터가 있을 때 표시되는 동적 챕터 및 자막 메뉴 제공함.

### Minimal
- 원형 진행률 표시기와 함께 재생 또는 일시 정지 단추 중 하나를 표시.
- 최소한의 제어만으로 짧은 비디오를 재생할 때에 적합.

### None
- 기본적으로 스타일이 없음. 
- 컨트롤이 제공되지 않고 단순히 비디오내용만 표시됨.

```
Note
HTTP라이브 스트리밍 비디오를 재생하는 경우 AVPlayerView는 컨트롤 스타일에 따라 스트리밍 재생에 적합한 대체 컨트롤을 자동으로 표시함.
Floating, Inline 스타일만 showSharingServiceButton 속성을 통해 공유 서비스 메뉴를 표시할 수 있음.
```

## Going Further
## Working with Chapters
- floating 또는 inline 스타일을 사용하는 경우 AVPlayerView는 파일에 장 데이터가 있을 때마다 장 메뉴를 자동으로 표시함.
- 다른 스타일의 경우 AVtimedMetadataGroup 클래스를 이용하여 작업을 해야함.
- 시간이 지정된 메타데이터를 검색할 수 있는 방법
- chapterMetadataGroupsWithTitleLocale:containingItemsWithCommonKeys:
- chapterMetadataGroupsBestMatchingPreferredLanguages:

## Enabling Trimming
- 트리밍 하기 전에 항상 플레이어 뷰의 canBeginTrimming 속성을 쿼리해야함.
- canBeginTrimming 이 NO를 반환하는 경우
- 트리밍 인터페이스가 이미 제공되고 있는 경우
- 자산에서 명시적으로 트리밍을 허용하지 않는 경우
- AVAsset자체는 수정이 불가능하기 때문에 AVPlayerItem의 두 속성을 수정한다.
- 트림 컨트롤의 왼쪽은 reversePlaybackEndTime 속성을 설정
- 트림의 오른쪽은 forwardPlaybackEndTime을 설정

## Exporting
- 트리밍 작업 결과를 저장하기 위해서는 AVAssetExportSession을 사용함.

## Movie Modernization
- AVFoundation은 레거시 기능을 지원하지 않고 대신 미래에 가장 적합한 코덱 및 트랙 유형이라고 생각하는 것에 초점을 맞춤.
- QTKit프레임워크에 QTMovieModernizer라는 클래스를 이용하여 AVFoundation에서 지원하는 형식으로 마이그레이션 가능함.
- QTMovieModernizer의 requiresModernization : error : 메소드는 미디어 변환이 필요할지 여부를 결정 해줌. <동기식 호출>
- modernizeWithCompletionHandler : 메소드는 마이그레이션을 시작함.
