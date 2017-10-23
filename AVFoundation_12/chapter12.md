# Layering Animated Content
- AVFoundation은 동영상 콘텐츠에 애니메이션 오버레이를 통합하는 매우 효과적인 지원을 제공함 (Core Animation 이용)

## Using Core Animation
- Layers: 화면상의 시각적 콘텐츠(배경색, 불투명도 등) 요소를 관리함. 경계 및 위치와 같은 자체 지오메트리를 정의하며 보다 복잡한 인터페이스를 만들기 위해 레이어 계층 구조로 구성됨.
- Animations: CABasicAnimation을 사용하면 단순한 단일 키 프레임 애니메이션을 제작할 수 있음.

## Using Core Animation with AV Foundation
- 비디오 으용프로그램에 대한 오버레이 효과를 만드는 것은 ios용 실시간 애니메이션을 제작하는 것과 거의 동일함.
- 가장 큰 차이점은 애니메이션을 실행하는데 사용되는 타이밍 모델에 있음.
- 호스트 시간의 경우 시스템 부팅에서 시작하여 앞으로 무한대로 단조롭게 진행됨. 이는 기본 애니메이션 동작에는 적합함. 하지만 비디오 애니메이션은 영화 시작부분에서 시작하여 지속시간까지 실행해야 하므로 호스트 시간은 부적합함.
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_12/Resource/ca1.png"/>

## Playback with AVSynchronizedLayer
- AVFoundation은 AVPlayerItem의 타이밍을 동기화하는 AVSynchronizedLayer라는 CALayer 서브 클래스를 제공함.
- 이 레이어는 콘텐츠를 표시하는데 사용하지 않고 단순히 타이밍을 레이어 하위 트리에 부여하는데 사용됨.
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_12/Resource/ca2.png"/>
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_12/Resource/ca3.png"/>

## Exporting with AVVideoCompositionCoreAnimationTool
- 비디오의 core animation 레이어와 애니메이션을 통합하려면 AVVideoCompositionCoreAnimationTool을 사용함. 이 클래스는 AVVideoComposition에서 core animation 효과를 비디오 합성 후 처리 단계를 통합하는데 사용됨
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_12/Resource/ca4.png"/>

- 오버레이 효과를 만들 때 관찰해야 할 사항
- removedOnCompletion 속성을 NO로 해야함
- beginTime이 0.0인 애니메이션은 보이지 않음.  core animation은 beginTime을 0.0으로 변환하여 현재 호스트 시간인 CACurrentMediaTime()을 영화의 타임 라인에 유효한 시간과 일치시키지 않음. 그러므로 동영상 맨 처음부터 애니메이션을 시작해야 하는 경우 AVCoreAnimationBeginTimeAtZero를 사용해야함.

## 15 Seconds: Adding Animated Titles
- AVComposition과 core animation을 사용하는데 어려움중 하나는 서로 다른 시간 개념을 사용하는 것임. 이를 잘 맞춰주는게 중요함

## Preparing the Composition
## Using Core Animation: Playback
## Using Core Animation: Export
- AVVideoCompositionCoreAnimationTool의 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer : inLayer를 사용하여 애니메이션 및 비디오 레이어를 전달하면 프레임과 애니메이션이 함께 랜더링 됨.
- 비디오 컴포지션의 animationTool 속성으로 설정하여 내보낼때 사용할 수 있음.

