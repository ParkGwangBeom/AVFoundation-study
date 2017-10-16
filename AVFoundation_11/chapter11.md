# Building Video Transitions

## Overview
- AVFoundation에서는 애니메이션 비디오 전환 기술에 대한 강력한 지원을 제공함
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_11/Resource/im1.png"/>

### AVVideoComposition
- 비디오 전환 api의 중심 클래스
- 비디오의 구성에 따라 AVPlayer 또는 AVAssetImageGenerator와 같은 클라이언트 객체가 처리 할 때 AVComposition의 표현이 결정됨
```
Note
AVVideoComposition은 AVComposition의 서브 클래스가 아니며 관련이 없음. 재생, 내보내기 등을 처리 할 때 자산의 비디오 트랙의 비디오 합성 동작을 제어하기 위해서만 사용됨
```

### AVVideoCompositionInstruction
- AVVideoComposition은 AVVideoCompositionInstruction이라는 객체 형식으로 제공되는 지침 모음으로 구성됨
- 컴포지션의 타임 라인 내에서 어떤 형태의 합성이 발생해야하는 시간 범위를 제공함
- 정확한 특성은 layerInstructions의 컬렉션에 의해 정의됨
- layerInstructions의 배열 순서는 비디오 레이어의 z축 순서를 정의함

### AVVideoCompositionLayerInstruction
- 주어진 비디오 트랙에 적용된 불투명도, 변형 및 자르기 효과를 정의하는데 사용됨
- 특정 시점 또는 시간범위에서 값을 수정하는 메소드를 제공함. 예를 들어 시간 범위에 따라 디졸브 및 페이드와 같은 애니메이션 전환 효과를 만들 수 있음

## Conceptual Steps

### 1 Stagger the Video Layout

<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_11/Resource/im2.png"/>
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_11/Resource/im3.png"/>

### 2 Define Overlapping Regions
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_11/Resource/im4.png"/>

### 3 Calculate Pass-Through and Transition Time Ranges
<img src="https://github.com/ParkGwangBeom/AVFoundation-study/blob/master/AVFoundation_11/Resource/im5.png"/>
- 컴포지션의 시간 범위를 정하기 위해 두가지 유형의 시간 범위를 계산해야함
- Pass-Through: 이 시간 범위 동안 한 트랙의 전체 프레임이 다른 프레임과 블렌딩 없이 전달되도록 해야함
- Transition: 비디오 세그먼트가 겹쳐지고 타임 라인에서 전환 효과가 적용될 영역을 표시하는 컴포지션의 시간 범위를 정의함
- Pass-Through, Transition을 계산하는데 유의사항
- 계산하는 시간 범위에 틈이나 겹침이 없어야 함
- 계산함에 있어서 총 시간을 고려해야함. 컴포지션에 추가 트랙이 있는 경우 해당 트랙을 비디오 타임 라인에 맞추거나 마지막 시간 범위를 기간에 맞게 조정해야함
- 유의사항을 지키지 않으면 컴포지션은 계속 재생되지만 비디오 내용은 랜더링되지 않음 (이 문제를 잘 진단하도록 Apple에서는 AVCompostionDebugViewer를 제공함. AVVideoCompostion 및 AVAudioMix 객체를 시각화하여 문제를 쉽게 식별하도록 도와줌)

### 4 Build Composition and Layer Instructions
- 통과, 전화에 관한 AVMutableVideoCompositionInstruction를 만들고 AVMutableVideoCompositionLayerInstruction를 생성하여 layerInstructions에 설정 해줌.

### 5 Build and Configure the AVVideoComposition
- instructions: AVCompositionInstruction을 설정함. 수행할 합성의 시간 범위 및 특성을 컴포지션에 설정함
- renderSize: 컴포지션을 렌더링해야하는 크기, 제공되는 값은 720p 동영상의 경우 1280x720, 1080p 경우 1920x1080과 같이 컴포지션 내에 포함된 동영상의 자연크기와 일치해야함
- frameDuration: 유효 프레임 속도를 설정하는데 사용됨. 프레임 지속시간은 프레임속도의 역수임. 즉 30FPS의 프레임 속도를 설정하기 위해서는 1/30 th의 프레임 지속시간을 설정해야함
- renderScale: 비디오 컴포지션에 적용되는 배율

## Building Video Compositions the Auto-Magic Way
- AVVideoComposition을 만드는 더 쉬운 방법은 videoCompositionWithPropertiesOfAsset: 초기화 메소드를 사용하는 것임. 이 메소드는 다음 구성을 사용하여 AVVideoComposition을 만듬
- 이 메소드는 유용하지만 모든 경우에 적합한 솔루션은 아님. 컴포지션의 시간 범위와 지침을 세부적으로 제어해야하는 경우가 예임.

## 15 Seconds: Adding Video Transitions
- 예제

## Applying Transition Effects
### Dissolve Transition
### Push Transition
### Wipe Transition

