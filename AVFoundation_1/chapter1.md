# Getting Started with AV Foundation

### What Is AV Foundation?
- AV Foundation은 OS X 및 iOS에서 시간 기반 미디어로 작업하기위한 Apple의 고급 Objective-C 프레임 워크다.
- 멀티 코어 하드웨어를 최대한 활용하고 블록과 GCD를 과도하게 사용하여 계산상이 비용이 많이 드는 프로세스를 백그라운드 스레드로 오프로드 시킨다.
- 64 비트 하드웨어를 최대한 활용하여 처음부터 64 비트 기본으로 작성되었다.

### Where Does AV Foundation Fit?
- iOS와 MAC OS는 모두 최신 미디어 응용프로그램을 단순화 하는 AVKit 프레임워크를 제공한다.
- 세세한 부분까지 컨트롤하기 위해선 하위 프레임워크를 이용해야 한다.
- 하위프레임워크
- Core Audio : OS X 및 iOS의 모든 오디오 프로세싱 처리. 고수준 api에서 제공하는 간편한 기능 뿐만 아니라 정교한 오디오 처리 기능을 구현할 수 있는 매우 낮은 수준의 인터페이스를 제공한다.
- Core Video : OS X 및 iOS에서 디지털 비디오를 위한 파이프 라인 모델을 제공.
- Core Media : 오디오 샘플 및 비디오 프레임 작업에 필요한 저수준 데이터 유형 및 인터페이스 및 CMTime 데이터 유형을 기반으로하는 AV Foundation에서 사용하는 타이밍 모델을 제공.
- Core Animation : 애니메이션 제공
- 미디어 플레이어 및 자산 라이브러리와 같은 상위 수준의 프레임 워크와 원활하게 작동하여 제공되는 서비스를 활용할 수 있으며 동시에 고급 요구 사항이 발생할 경우 Core Media 및 Core Audio와 직접 상호 작용할 수 있다.

### Decomposing AV Foundation
- AVFoundation은 100개가 넘는 클래스로 구성되어 이기 때문에 배우는데 있어 가장 큰 어려움은 프레임워크가 제공하는 클래스를 이해하는 것이다.
- 기능단위로 분리해서 한다면 이해하기 쉬워진다.

Audio Playback and Recording
- AVAudioPlayer 및 AVAudioRecorder는 오디오 재생 및 녹음을 응용 프로그램에 통합하는 쉬운 방법을 제공한다.

### Media Inspection
- 사용중인 미디어를 검사 할 수있는 기능을 제공한다. <재생에 사용할 수 있는지 또는 편집하거나 내보낼 수 있는지 여부>
- AVMetadataItem 클래스를 기반으로하는 강력한 메타 데이터 지원을 제공.

### Video Playback
- 로컬 파일 또는 원격 스트림에서 비디오 자산을 재생하고 비디오 내용의 재생 및 표시를 제어 할 수 있다.
- 
### Media Capture
- 스틸 및 비디오 이미지를 캡쳐 등 다양한 api세트를 제공하므로 카메라 장치의 기능을 세밀하게 제어할 수 있다.

### Media Editing
- 미디어 구성 및 편집에 대한 강력한 지원을 제공한다.

### Media Processing
- AVFoundation을 통해 많은 기능을 관리할 수 있지만 때때로 고급 미디어 처리를 수행하기 위해 세부 정보에 엑세스해야하는데 이 경우 AVAssetReader 및 AVAssetWriter 클래스를 사용하여 처리 가능하다.

### Understanding Digital Media
- 우리가 보는 모든 시력과 우리가 듣는 모든 소리는 아날로그 신호로 우리에게 전달된다.
- 아날로그 신호를 디지털 방식으로 저장하고 전송할 수있는 형태로 변환하려면 샘플링이라고하는 아날로그 - 디지털 변환 프로세스를 사용한다.

### Digital Media Sampling
- 미디어를 디지털화 할 때 두 가지 기본 유형의 샘플링이 사용한다.
1. 시간 샘플링 : 시간 경과에 따른 신호의 변화를 캡쳐 <녹음을 할때 피치와 음량의 연속적인 변화를 캡쳐>
2. 공간 샘플링 : 사진이나 다른 시각적 매체를 디지털화 할 때 사용

Understanding Audio Sampling


### Digital Media Compression
- 디지털 미디어의 크기를 줄이기 위해 압축을 사용해야  한다.
- 디지털 미디어를 압축하면 파일 크기가 크게 줄어들지 만 품질은 거의 저하되지 않는다.

### Chroma Subsampling
- 비디오 데이터는 일반적으로 Y'CbCr이라는 컬러 모델을 사용하여 인코딩되며 일반적으로 YUV라고 한다.
- Y’CbCr 또는 YUV는 픽셀의 루마 채널 Y (밝기)와 채도 (색상) 채널 UV를 분리한다.
- 눈은 색보다 밝기에 훨신 민감하기 때문에 이미지 품질을 유지하면서 각 픽셀에 저장된 색 정보의 양을 줄일 수 있다. 색상 데이터를 줄이기 위해 사용되는 프로세스를 채도 서브 샘플링이라 한다.
- 채도 하위 샘플링
- J : 일부 참조 블록 내에 포함 된 픽셀 수
- a : 첫 번째 행의 모든 ​​J 픽셀에 대해 저장되는 색차 픽셀 수
- b : 두 번째 행의 모든 ​​J 픽셀에 대해 저장되는 추가 픽셀 수

### Codec Compression
- 대부분의 오디오 및 비디오는 인코더 / 디코더의 약자 인 코덱을 사용하여 압축된다. <코덱은 압축 알고리즘을 이용하여 오디오 또는 비디오 데이터를 인코딩, 디코딩 한다.>
- 코덱은 손실, 무손실이 있다.
- 무손실 코덱 : 압축을 풀 때 완벽하게 재구성 할 수 있는 방식으로 미디어를 압축하므로 편집 용도 나 제작 용도, 보관 목적에 이상적이다.
- 손실 코덱 : 압축 프로세스 중 일부 데이터를 잃는다.

### Video Codecs
- AVFoundation은 Apple이 오늘날 미디어와 가장 관련 있다고 생각하는 한정된 코덱세트를 지원한다.

### H.264
- 비디오 카메라에 널리 사용되며 웹에서 비디오 스트리밍에 사용되는 주요 형식.
- 더 낮은 비트율로 크게 향상된 이미지 품질을 제공하므로 스트리밍 및 모바일 장치 및 비디오 카메라에 이상적이다.
- H.264 압축 방식
- Spatially : 개별 비디오 프레임을 압축하며 인트라 프레임 압축이라고 함.
- Temporally : 비디오 프레임 그룹 전체에서 중복을 압축. 이를 프레임 간 압축이라고 함.
- GOP 세가지 유형 프레임
- I-frames : 독립형 또는 키 프레임이며 전체 이미지를 만드는데 필요한 모든 데이터가 들어있다. 모든 GOP에는 하나의 I 프레임이 있다. 크기면에서는 가장 크지만 압축을 해제하는데 가장 빠르다.
- P-frames : P 프레임은 가장 가까운 선행 P프레임 또는 I 프레임의 데이터를 참조 할 수 있다. <참조 프레임>
- B-frames : 정보 앞 뒤에 프레임 정보를 기반으로 인코딩 된다. 공간이 거의 필요하지 않지만 주변 프레임에 의존하기 때문에 압축을 해제하는데 오래 걸린다.
- 인코딩 프로세스 중에 사용된 알고리즘을 결정하는 인코딩 프로파일을 추가로 지원한다.
- Baseline : 모바일 장치 용 미디어를 인코딩 할 때 일반적으로 사용됨. 가장 효율적인 압축을 제공하므로 파일 크기가 커지지 만 B 프레임을 지원하지 않기 때문에 계산량이 가장 적다.
- Main : 많은 알고리즘이 사용되기 때문에 계산이 많지만 압축률은 높다.
- High : 가장 집중적임.

### Apple ProRes
- AV Foundation은 Apple ProRes 코덱 두 가지를 지원
- Apple ProRes 코덱은 프레임 독립적이며 I 프레임 만 사용되므로 편집하기에 더 적합

### Audio Codecs
- AVFoundation은 Core Audio 프레임 워크에서 지원하는 모든 오디오 코덱을 지원한다.

### AAC
- AAC는 H.264와 유사한 오디오 스트리밍 및 다운로드에 사용되는 주요 형식이다.

### Container Formats
- 일반적으로 미디어 파일 유형을 파일 형식으로 지칭하지만 정확한 정의는 컨테이너 형식이다.
- 컨테이너 형식은 메타 파일 형식으로 간주된다. <QuickTime 파일에는 비디오, 오디오, 자막 및 장 정보와 같은 다양한 미디어 유형이 포함될 수 있으며 보유하고 있는 각 미디어의 세부 정보를 설명하는 메타 데이터가 들어 있다.>
- AVFoundation은 이러한 유형의 데이터를 읽고 쓰는 클래스도 제공한다.
- AVFoundation에서 작업 할 때 두 가지 기본 컨테이너 형식
- QuickTime : 더 큰 QuickTime 아키텍처의 일부로 정의 된 Apple의 독자적인 형식
- MPEG-4 : MPEG-4 (MP4) 컨테이너 형식을 정의. MP4 컨테이너에 대해 정의 된 공식 파일 확장자는 .mp4이지만 다양한 변형 확장이 사용됨.

### Hello AV Foundation
- AVSpeechSynthesizer를 이용하여 음성 발화 기능 만들기.

































