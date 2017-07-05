# Using Advanced Capture Features

## Video Zooming
- ios7 이전에는 AVcaptrueConnection의 videoScaleAndCropFactor 속성을 통해 카메라 줌을 제한적으로 지원함.
    - videoScaleAndCropFactor 속성은 연결수준 설정이므로 올바르게 반영을 위해서는 AVCaptureVideoPrevieLayer에 대한 적절한 크기조정을 해야했음.
    - 이미지 품질을 감소시킴
- ios7부터 AVcaptureDevice에 직접 줌 요소를 적용할 수 있게 됨
- AVCaptureDevice는 줌 레벨을 제어할 수 있는 videoZoomFacotor 속성을 제공함
    - 카메라 센서로 캡처한 이미지를 중앙에서 자름. 업 스케일링 없이 적당한 줌을 수행할 수 있는 능력을 제공함. 즉 전체 이미지 품질이 보       존됨.
    - 업스케일링 시작 되어야 하는 지점은 AVCaptureFormat에 videoZoomFactorUpscaleThreshold값을 요청하여 확인 가능함.

## Face Detection
- Apple은 Core Image를 이용하여 얼굴탐색 기능을 제공함. (CIDetector, CIFaceFeature 객체) 하지만 이는 실시간 사용에 최적화 되어 있지 않아서 필요한 프레임 속도를 얻지 못함.
- 그래서 Apple은 AVFoundation에 직접 새로운 하드웨어 가속 기능을 도입함. (AVCaptureMetadataOutput)
    - AVCaptureMetadataOutput은 스틸이미지나 동영상을 출력하는 대신 메타 데이터를 출력함.
    - 얼굴 탐지로 작업할 때에는 AVMetadataFaceObject라는 구체적인 하위 클래스 유형을 출력함.
    - AVMetadataFaceObject
        - 얼굴을 설명하는 몇가지 속성을 제공함.
        - 얼굴의 경계를 스칼라 좌표로 주어짐 (왼쪽상단 구선의 0,0에서 카메라의 기본 방향의 오른쪽 하단 구석의 1,1까지 범위)
        - 감지된 얼굴의 roll 및 yaw 각을 정의하는 속성을 제공함. (roll - 어깨쪽으로 사람의 머리가 좌우로 기울여져 있음을 나타냄, yaw - 얼굴이 y축을 중심으로 회전하는 것을 나타냄)
    - AVCaptureMetadataOutput 객체를 구성할 때 metadataObjectTypes 속성을 설정하면 출력하고 싶은 메타 데이터 유형을 지정할수 있으며 성능적으로 최적화 시킬수 있음.

## Building the Face Detection Delegate
- AVCaptureMetadataOutput 개체에 의해 캡처 된 메타 데이터는 자치 공간에 존재함. 이 메타 데이터를 사용하기 위해서는 장치 좌표 공간객체를 뷰 좌표 공간 객체로 변환해야함. (transformedMetadataObjectForMetadataObject 메소드 이용)

## Machine-Readable Code Detection
### 1D Codes
- AVFoundation은 바코드 1d뿐만 아니라 2d도 추가적으로 지원함.

### Building a Barvode Scanner
- 캡처 장치의 자동 초점 기능은 일반적으로 멀리 떨어져 있는 물체를 스캔함.
- ios 7에서 autoFocusRangeRestriction을 사용하여 범위 제한이 가능함.
- AVCaptureMetadataOutput에 metadataObjectTypes 속성을 지정하여 관심있는 타입을 지정이 가능함. (예로 QR코드 등)
- 바코드로 작업할 때는 AVMetadataCaptureOutput객체는 AVMetadataMachineReadableCodeObject 인스턴스임.
- AVMetadataMachineReadableCodeObject객체는 바코드의 실제 데이터 값과 바코드의 지오메티리를 정의 하는 속성을 제공함.

## Building the Code Detection Delegate

## Using High Frame Rate Capture ////////////
- 애플은 높은 프레임 속도의 캡처를 지원함.
    - Capture: 비디오 안정화 기능과 함께 60프레임에서 720p 비디오 캡처를 지원함. 오래된 프레임에서 높은 프레임 속도의 컨텐츠가 원활하게 재생되도록 도와줌.
    - Playback: AVPlayerItem에는 재생 속도를 줄이거나 늘릴 때 사용되는 알고리즘을 설정할 수 있는 audioTimePitchAlgorithm 속성이 있음.
    - Editing: 프레임워크의 편집기능은 변경 가능한 컴포지션 내에서 확장 된 편집을 완벽하게 지원함.
    - Export: AVFoundation은 원래 프레임 rate를 유지하는 능력을 제공함.

## High Frame Rate Capture Overview
- 높은 프레임 속도 캡처 기능을 사용하는 것은 간단하지 않음. 프레임 속도와 크기의 모든 조합을 고려해야 하기 때문. ios7에서는 병렬 구성 메커니즘을 통해 이 기능을 사용 할 수 있음.

## Enabling High Frame Rate Capture
- 높은 프레임 속도 캡처를 사용하려면 캡처 장치에서 사용할 수 있는 형식을 살펴보고 지원되는 최고 AVCaptureDeviceFormat 및 최고 AVFrameRateRange를 찾아야 함.

## Processing Video
- AVCaptureVideoDataOutput은 비디오 데이터의 형식, 타이밍 밑 메타데이터를 완벽하게 제어할 수 있음.
```
Note
- AVFoundation은 AVCaptureVideoDataOutput 뿐만 아니라 오디오 데이터 작업을 위한 저수준 캡처 출력을 제공함. 이것은 다음장에서 확인가능함.
```
- AVCaptureVideoDataOutput은 AVMetadataObject 인스턴스를 출력하는 대신 AVCaptureVideoDataOutputSampleBufferDelegate를 통해 비디오 데이터가 포함된 객체를 출력함.
- AVCaptureVideoDataOutputSampleBufferDelegate
    - captureOutput:didOutputSampleBuffer:fromConnection: 새 비디오 프레임이 작성될 때마다 호출됨. 데이터는 비디오 데이터 출력의 videoSettings 속성 구성을 기반으로 디코딩되거나 다시 인코딩 됨.
    - captureOutput:didDropSampleBuffer:fromConnection: 비디오 프레임이 늦을 때마다 호출됨. 늦어지는 가장 일반적인 이유는 didOutputSampleBuffer: 호출에서 너무 많은 처리 시간이 걸리기 떄문.

## Understanding CMSampleBuffer
- CMSampleBuffer는 기본 샘플 데이터에 대한 래퍼 역할을 하며 데이터를 해석하고 처리하는데 필요한 추가 메타 데이터와 함께 형식 및 타이밍 정보를 제공함.

### Sample Data
- CMSampleBufferGetImageBuffer 함수를 사용하여 CMSampleBufferRef에서 기본 CVPixelBuffer를 가져올수 있음. CVPixelBuffer는 주 메모리에 픽셀 데이터를 저장하여 내용을 조작할 수 있는 기회를 제공함.

### Format Descriptions
- CMSampleBuffer는 CMFormatDescription이라는 개체로 샘플에 대한 형식 정보에 대한 접근을 제공함.

### Timing
- CMSampleBuffer는 미디어 샘플에 대한 타이밍 정보를 제공함.
- 타이밍 정보는 CMSampleBufferGetPresentationTimeStamp / CMSampleBufferGetDecodeTimeStamp 함수를 사용하여 추출함.

### Metadata Attachments

## Using AVCaptureVideoDataOutput
- OpenGL ES로 작업할 경우 BGRA를 사용하여 샘플링 하는게 좋음. 형식 변환의 경우 성능 저하를 초래할 수 있기 때문.


