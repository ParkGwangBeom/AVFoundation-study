# Playing and Recording Audio

### Understanding Audio Sessions
- 오디오 세션은 앱과 운영체제 사이에서 중개자 역할을 한다.
- 모든 iOS 응용프로그램은 오디오 세션을 사용하는지 여부에 관계 없이 오디오 세션을 보유한다.
- 오디오 세션 목록
    - 재생은 활성화 도지만 녹음은 허용하지 않음
    - 무음모드로 전환시 재생되는 모든 오디오 음소거
    - 잠금화면 표시시 오디오 음소거
    - 프로그램에서 재생시 배경에서 재생되는 모든 오디오 음소거

### Audio Session Categories
- AVFoundation에서 오디오 동작을 설명하는 7가지 범주
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_2/Resource/AVAudioSession.png"/>

- 좀 더 세부적인 제어가 필요한 경우 옵션 및 모드를 사용하여 일부 범주를 추가적으로 정의 할 수 있다.
    - 옵션 : 응용프로그램이 재생 범주를 사용하여 오디오 출력과 백그라운드에서 오디오 재생을 혼합 할 수 있는지 여부와 같이 범주에서 제공하는 선택적 동작을 활성화 할 수 있다.
    - 모드 : 특별한 유스 케이스에 맞는 동작을 도입하여 카테고리를 추가로 수정할 수 있다.

### Configuring an Audio Session
- 오디오 세션은 응용프로그램이 끝날때까지 수정이 가능하다.
- AVAudioSession은 응용 프로그램의 오디오 세션과 상호 작용할 수 있는 인터페이스를 제공한다.
- 오디오 세션 설정 -> 오디오 세션 활성화

### Audio Playback with AVAudioPlayer
- AVAudioPlayer
    -  이 클래스의 인스턴스는 파일 또는 메모리에서 오디오 데이터를 재생하는 간단한 방법을 제공한다.
    - Core Audio의 C기반 오디오 대기열 서비스 위에 구축되므로 Audio Queue Services에서 재생, 루핑 및 오디오 미러링과 같은 핵심 기능을 제공하며 보다 간단하고 친숙한 인터페이스를 제공한다.

### Creating an AVAudioPlayer
- AVAudioPlayer는 재생할 오디오 메모리 내 버전 또는 로컬 오디오 파일에 대한 NSuRL을 포함하는 NSData를 사용하여 구성이 가능하다.
- ios를 사용하는 경우 URL은 어플리케이션의 샌드박스 내에 위치해야 한다.
- prepareToPlay
    - 유효한 플레이어 인스턴스를 가져와 prepareToPlay 메소드를 호출하는 것이 좋다. 이렇게 할 경우 필요한 오디오 대기열의 버퍼를 미리 로드하기 떄문이다.
    - 위 메소드를 호출하는 것은 선택사항이며 play가 호출될 때 암시적으로 호출되지만 생성시 플레이어를 준비하면 play 메소드를 호출 할 때와 오디오 출력을 청취할 떄의 대기시간이 최소화할 수 있다.

### Controlling Playback
- 플레이어 인터스턴스는 play, stop, pause와 같은 재생을 컨트롤 할 수 있는 메소드가 있다.
- stop과 pause는 외견상 동일한 기능을 하는것 같지만 stop의 경우 prepareToPlay에 의한 설정이 취소가 되지만 puase의 경우 취소되지 않는다.
- 이외 기능
    - 볼륨 수정: 플레이어의 볼륨은 시스템 볼륨과 독립적이다.
    - 플레이어 패닝을 사용하여 사운드 스테레오 필드 배치
    - 재생속도 조정: 재생속도를 0.5 ~ 2.0까지 조정할 수 있다.
    - numberOfLoops: 오디오 반복
    - 오디오 루핑 
    - 오디오 미러링: 재생할 때 플레이어에서 평균 및 최고 출력 수준을 읽을 수 있다.

### Building an Audio Looper
- playAtTime: 지정된 시간에 시작
- enableRate: 재생 속도 제어 여부
- rate: 피치를 변경하지 않고 재생 속도를 제어하는 속성

### Controlling the Individual Tracks
- pan : pan 조정 (-1 ~ 1)

### Configuring the Audio Session
- 어플리케이션에는 Solo Ambient라는 카테고리가 기본 오디오 세션으로 제공된다. <이 경우 옆 스위치를 잠금을 할 경우 오디오가 안나옴>
- AVAudioSessionCategoryPlayback은 앱이 백그라운드에서 오디오가 재생하도록 한다. 
- 백그라운드 재생이 필요할 경우 plist나 프로젝트 설정을 백그라운드 모드로 변경해 줘야 한다.

### Handling Interruptions
- 여러 인터럽션 상황에 대해 처리를 잘해야 한다.
- 인터럽션이 시작되면 오디오재생이 페이드 아웃되고 일시정지된다. 이 상황에 대해서 여러가지 처리가 필요하다 (다시 재생 등…)

### Audio Session Notifications
- AVAudioSessionInterruptionNotification은 각 인터럽션 상황에 대해 노티로 사실을 통지해준다.
- AVAudioSessionInterruptionType enum 값들을 통해 시작되었거나 종료되었을 때 상황에 대해 조치를 취할 수 있다.
- AVAudioSessionInterruptionOptions는 오디오 세션이 활성화 되고 재생이 다시 시작할 수 있는지 여부 등의 값이 포함되어 있다.

### Responding to Route Changes
- AVAudioPlayer의 적용 범위를 마무리하기 전에 해결해야 할 항목은 앱이 경로 변경에 올바르게 응답하는지 확인하는 것이다. 경로 변경은 오디오 입출력이 iOS 장치에 추가되거나 제거 될때마다 발생한다. <해드폰 세트를 꽂거나 usb마이크를 분리하는 경우>
- 위와 같은 이벤트가 발생하면 오디오 입출력 경로가 변경되고 AVAudioSession은 수신기의 변경 내용을 설명하는 알림을 브로드 캐스트 한다.
- 변경시 알림을 받기 위해선 AVAudioSessionRouteChangeNotification을 등록 하여.상황에 맞게 처리한다. <프로젝트에 노티피케이션 관련 설명 주석으로>
- 경로 변경을 처리하고 중단에 적절하게 대응하는 것은 미디어 애플리케이션을 구축 할 때 항상 고려해야 할 중요한 사항이다. 이러한 시나리오를 올바르게 처리하기 위한 약간의 노력은 사용자가 좋아할 만한 경험을 제공하는 데 많은 도움이 된다.

### Audio Recording with AVAudioRecorder
- AVAudioRecorder 클래스를 사용하여 오디오 녹음 기능을 쉽게 추가 할 수 있다.
- AVAudioRecorder는 Audio Queue Services를 기반으로 제작되었으며 간편한 인터페이스를 제공한다.

### Creating an AVAudioRecorder
- AVAudioRecorder를 만드는데 필요한 세가지 데이터
    - 오디오 스트림이 기록 될 파일을 식별하는 URL
    - 녹음 세션을 구성하는데 필요한 key, value를 포함 dictionary
- prepareToRecord를 호출하면 좋은점
    - AVPlayer와 유사하게 기본 Audio Queue의 필요한 초기화를 수행
    - URL 인수로 지정된 위치에 파일을 추가로 만드므로 녹음이 시작될 때 대기 시간을 최소화 할 수 있음.

### Audio Format
- AVFormatIDKey 키는 기록할 오디오 형식을 정의.
    - kAudioFormatLinearPCM : 용량이 크고 고품질
    - kAudioFormatMPEG4AAC : 작은파일이지만 고품질
    - kAudioFormatAppleLossless
    - kAudioFormatAppleIMA4 : 작은파일이지만 고품질
    - kAudioFormatiLBC
    - kAudioFormatULaw
- 지정한 오디오 형식은 URL 인수에 정의된 파일 형식과 호환되어야 한다.

### Sample Rate
- AVSampleRateKey는 레코더의 샘플링 속도를 정의 하는데 사용된다. 
- 샘플링 속도는 들어오는 아날로그 오디오 신호의 초당 취해진 샘플 수를 정의한다. 
- 샘플링 속도는 오디오 녹음의 품질과 파일의 크기에 중요한 열할을 한다. <샘플링 속도가 클수록 고품질이며 용량이 크다>

### Number of Channels
- AVNumberOfChannelsKey는 녹음된 오디오 채널 수를 정의하는데 사용된다.
- 기본값 1은 모노 녹음, 2는 스테레오 녹음이 된다.
- 외부 하드웨어로 녹음하지 않는 한, 일반적으로 모노 녹음을 해야 함.

### Format-Specific Keys

### Controlling Recording
- AVAudioRecorder는 무한 녹음, 특정 시점에 녹음, 특정 기간동안 녹음 등의 여러 녹음 방법을 제공한다.

### Building a Voice Memo App

### Audio Session Configuration
- ios7부터는 운영체제에서 사용자가 마이크를 사요하기 전에 명시적으로 권한을 부여해야 한다.
- 사용자가 권한을 허용하지 않았을 경우 녹음이 되지 않는다.

### Recorder Implementation
- AVAudioRecorderDelegate은 레코딩이 완료되었을 때 알림을 받을 수 있는 방법을 정의한다.

### Enabling Audio Metering
- 오디오 미러링은 AVAudioRecorder, AVAudioPlayr에서 사용할 수 잇는 가장 강력하고 유용한 기능이다.
- averagePowerForChannel, peakPowerForChannel 두 방법 모두 요청 된 전력 레벨을 나타내는 갑을 데시벨 단위로 반환 한다.
- 미러링하여 데시벨 값을 읽기 위해서는 레코더의 meteringEnabled속성을 true로 해줘야 한다.
