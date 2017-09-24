# Mixing Audio

## Mixing Audio
- AVAudioMix: 컴포지션의 오디오 트랙에 사용자 지정 오디오 처리를 적요한느데 사용됨.
// 이미지
- AVAudioMix에 수행되는 프로세싱의 특성은 AVAudioMixInputParameters라는 객체의 매게변수 모음에 의해 정의됨.
- AVAudioMix, AVAudioMiaxInputParameters는 변경불가 객체이므로 AVPlayerItem 및 AVAssetExportSession과 같은 클라이언트에 데이터를 제공하는데 적합함.
- 커스텀 오디오 믹스를 만들 필요가 있으 경우 변경 가능한 AVMutableAudioMix, AVMutableAudioMixInputParaters를 사용함.

## Automating Volume Changes
- 여러 오디오 트랙이 있는 경우 각각의 볼륨 공간을 차지하기 위해 경쟁하므로 오디오가 잘 들리지 않을수 있음. 이는 오디오 믹싱을 통해 해결이 가능함.
- AVFoundation은 볼륨이 0.0에서 1.0 사이의 정규화된 스케일에서 부동 소수점 값으로 정의되는 간단한 모델을 사용함. 여기에서 0.0은 무음, 1.0은 전체 볼륨임. 오디오 트랙의 기본 볼륨은 1.0으로 설정되지만 AVMutableAudioMixInputParameters를 통하여 수정이 가능함.
- AVMutableAudioMixInputParameters를 통하여 볼륨을 변경하는 2가지 방법
    - setVolume:atTime: 지정된 시간에 즉시 볼륨을 조정할 수 있음. 이는 오디오 트랙의 지속시간 동안 또는 다른 볼륨 조정이 발생할때까지 일정하게 유지됨.
    - setVolumeRampFromStartVolume:toEndVolume:timeRange: 지정된 시간 범위에서 볼륨을 한 값에서 다른 값으로 부드럽게 램핑 할 수 있음. 시간 범위가 만료되면 지정된 볼륨으로 즉시 점프하고 toEndVolume으로 지정된 값으로 유지됨.
// 이미지
// 이미지
(자연스럽게 변하는 구간은 setVolumeRampFromStartVolume:toEndVolume:timeRange:, 바로 변하는 구간은 setVolume:atTime:)

## Mixing Audio in the 15 Seconds App
예제…



