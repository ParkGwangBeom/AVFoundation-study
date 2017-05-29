# Playing Video

## AVPlayer
- AVPlayer는 시간이 지정된 오디오-동영상을 재생하는데 사용되는 컨트롤러 개체 <재생 및 타이밍을 관리>
- HTTP 라이브 스트리밍, 다운로드 된 미디어 재생을 지원
- AVPlayer는 비시각적 요소이다. 비디오 출력을 사용자 인터페이스 대상으로 보내려면 AVPlayerLayer라는 클래스를 사용한다.

## AVPlayerLayer
- AVPlayerLayer는 CALayer 클래스를 확장하고 비디오 내용을 화면에 랜더링 하는데 사용됨
- 커스터마이징 가능한 부분은 VideoGravity이다. 레이어의 경계 내에서 비디오를 늘리거나 크기를 조절 할 수 있다. <AVLayerVideoGravityResizeAspect, AVLayerVideoGravityResizeAspectFill, AVLayerVideoGravityResize>

## AVPlayerItem
- AVAsset은 정적측면(메타 데이터 등)을 나타내기 때문에 재생에 적합하지 않음. 그러므로 관련 트랙을 재생하기 위해서는 AVPlayerItem 및 AVPlayerItemTrack 클래스에서 제공하는 동적 요소를 구성해야 함.
- AVPlayerItem은 미디어의 동적인 관점을 모델링하고 AVPlayer가 재생하는 자산의 프리젠테이션 상태를 전달함. <seekToTime:, currentTiem, presentationSize 등 속성 및 메소드가 있음.>
- AVPlayerItem은 하나 이상의 트랙으로 구성되며 AVPlayerItemTrack 클래스로 모델링 됨.
- AVPlayerItem에서 발견된 트랙은 AVAsset안에 있는 AVAssetTrack과 일치함.

## Playback Recipe
- AVPlayerItem을 통해서 playerLayer를 만들고 item자체를 통해서 layer를 통제한다. ??
- AVPlayerItem에는 status 속성이 존재함. KVO를 통해 속성을 관찰
- AVPlayerItemStatusUnknown에서 시작. (미디어가 로드되지 않았고 재생을 위해 대기열에 추가되지 않았음)
- AVPlayerItemStatusReadyToPlay가 되야 재생이 가능함.
- 
## Working with Time
- 부동 소수점 유형으로 시간을 표현하는 것은 부동 소수점 연산이 근본적으로 부정확성을 초래할 수 있음.
- AVFoundation은 CMTime이라는 데이터 구조를 기반으로 시간을 표현함.

## CMTime
- CMTime은 시간 값, 즉 분수 값의 합리적인 표현을 제공하는 구조체임.
```
typedef struct {
  CMTimeValue value;
    CMTimeScale timescale;
    CMTimeFlags flags;
    CMTimeEpoch epoch;
} CMTime;

let halfSecond = CMTimeMake(1, 2) // 0.5초
let fiveSeconds = CMTimeMake(5, 1) // 5초
```

## Building a Video Player
## Creating the Video Controller
- AVPlayerItem에 initWithAsset: automaticallyLoadedAssetKeys:를 사용하게 되면 asset의 속성들을 자동으로 로드할 수 있다.

## Observing Status Changes
- AVFoundation에서 avplayer에 옵저빙을 할 경우 상태값의 변경을 알리기 위해 어떠한 쓰레드에서 할지 모르므로 메인스레드를 사용하도록 명시 해줘야 함.

## Time Observation
- AVPlayer에서 KVO를 이용하여 시간변경을 관찰하는 것은 유용하지 않음. <너무 빈번하게 일어나므로 정밀함이 필요함.>

### Periodic Time Observation
- 가장 일반적으로 정기적으로 시간을 알리는 것이다.
- AVPlayer의 addPeriodicTimeObserverForInterval: queue: usingBlock: 메소드를 사용.
    - interval: 알림을 받아야 하는 주기적인 시간간격
    - queue: 알림을 게시해야 하는 시리얼 큐 (콘커런트 큐를 사용할 경우 예상치 못한 동작이 발생)
    - block: 지정한 시간마다 불리는 콜백

### Boundary Time Observation
- AVPlayer는 또한 플레이어의 타임 라인에서 다양한 경계 지점을 탐색 할 수 있도록 시간을 관찰하는보다 전문화 된 방법을 제공. 예를 들어 25% 50%등에 마커를 정의 할 수 있음.
- addBoundaryTimeObserverForTimes : queue : usingBlock : 메소드를 사용.
    - times: 알림을 받고자 하는 경계지점을 정의 하는 CMTime값의 array
    - queue: nil일 경우 메인큐, 기본적으로 시리얼 큐를 사용
    - block: 경계지점을 통과할때마다 불릴 콜백 블록

## Item End Observer
- AVPlayerItem은 재생이 완료 되었을 경우 AVPlayerItemDidPlayToEndTimeNotification이라는 알림을 게시함.

## Transport Delegate Callbacks
- AVPlayerItem의 cancelPendingSeeks 메소드는 seek하는 작업이 누적되지 않도록 보류중인 것을 캔슬시켜줌.

## Creating a Visual Scrubber
- AVAssetImageGenerator 클래스는 AVAsset의 비디오 트랙에서 이미지를 추출하는데 사용할 수 있음.
- AVAssetImageGenerator 비디오 asset에서 이미지를 검색하는 두가지 방법
- copyCGImageAtTime:actualTime:error: 지정된 시간에 이미지를 캡쳐 (단일 이미지를 캡쳐하여 비디오 목록에 비디오 축소판으로 표시하려는 경우 유용)
- generateCGImagesAsynchronouslyForTimes:completionHandler: 지정된 시간동안 일련의 이미지를 생성. 한번의 호출로 여러 이미지 모음을 효율적으로 생성할 수 있음.
- AVAssetImageGenerator 로컬 및 다운로드된 에셋에 이미지를 생성할수 있지만 http live stream으로 부터 받은 이미지는 생성 불가. ???
- 이미지를 생성 할때에 기본적으로 원래 크기로 캡쳐됨. maximumSize를 설정할 경우 이미지가 자동으로 필요한 크기로 설정되므로 성능향상을 가져올수 있음. 높이 설정을 0으로 할 경우 가로 세로 비율에 따라 맞게 설정이 됨.
- AVAssetImageGeneratorCompletionHandler
    - requestedTime: 이미지를 생성하기 위해 호출에서 지정한 시간 배열의 값에 해당
    - imageRef
    - actualTime: 이미지가 실제로 생성된 시간. (요청한 시간과 다를수 있음.) 이미지 생성 전에 AVAssetImageGenerator 인스턴스에서 requestedTimeToleranceBefore 및 requestedTimeToleranceAfter 값을 설정하여 requestedTime과 actualTime이 얼마나 근접하게 일치 하는지를 조정할 수 있음.
    - result: 성공 및 실패

## Showing Subtitles
- AV Foundation은 자막이나 자막 표시에 대한 강력한 지원을 제공함. (AVMediaSelectionGroup 및 AVMediaSelectionOption 클래스를 사용)
- AVMediaSelectionOption은 AVAsset내의 대체 미디어 프리젠테이션(비디오, 오디오, 텍스트 등)을 나타냄.

## Airplay
- AVPlayer는 allowsExternalPlayback 속성으로 AirPlay재생을 활성화, 비활성화 할수 있음. (기본속성은 YES임)

## Providing a Route Picker
- MPVolumeView는 시스템적인 볼륨을 조정할수 있도록 함.
- 경로 선택기 버튼은 사용자가 유효한 AirPlay 대상을 가지고 있으며 Wi-Fi가 활성화 된 경우에만 표시됨.


