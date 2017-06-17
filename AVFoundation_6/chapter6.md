# Capturing Media
- AVKit은 기본 운영체제 플레이어의 모양과 일치하는 AVFoundtaion 기반 비디오 플레이어를 만드는 프로세스를 단순화 함.

## Capture Overview
- 코어 캡쳐 클래스는 ios와 osx에서 일관됨. 하지만 ios의 경우 샌드박스 제한으로 인해 AVCaptureScreenInput 클래스를 제공하지 않음.

## Capture Session
- 입출력이 연결된 가상 ‘patch bay’역할을 함. (카메라 및 마이크와 같은 물리적 장치에서 하나 이상의 출력 대상으로의 데이터 흐름을 제어)
- 세션기간동안 필요에 따라 캡처 환경을 재구성할 수 있음.
- 캡처된 데이터의 형식과 품질을 제어하는 세션 사전 설정을 사용하여 추가로 구성할 수 있음.

## Capture Devices
- AVCaptureDevice는 카메라, 마이크와 같은 물리적 장치에 인터페이스와 카메라의 초점, 노출, 화이트 밸런스 및 플래시 등의 제어기능을 제공함
- AVCaptureDevice는 시스템의 캡처 장치와 엑세스하는데 사용되는 다양한 클래스 메소드를 제공함
```Swift
// ios의 경우 후면 카메라를 반환
// mac의 경우 facetime 카메라를 반환
let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
```

## Capture Device Inputs
- 캡처장치로 작업을 수행하기 위해서는 캡쳐세션에 입력으로 추가해야함
- 캡처 장치를 AVCaptureSession에 직접 추가할 수 없으므로 AVCaptureDeviceInput의 인스턴스테 래핑해야함
- AVCaptureDeviceInput은 케이블 역할을 함
```Swift
let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
```

## Capture Outputs
- AVFoundation은 AVCaptureOutput을 확장하는 여러 클래스를 제공함.
- AVCaptureStillImageOutput, AVCaptureMovieFileOutput, AVCaptureAudioDataOutput, AVCaptureVideoDataOutput

## Capture Connections
- 캡쳐 세션은 지정된 캡쳐 장치 입력에 따라 아웃풋으로 나올 미디어 유형을 결정하고 해당 유형의 미디어를 수락하는 출력을 캡처하도록 연결을 자동으로 형성함
- 캡처 세션에서 입력 및 출력 개체의 특정 쌍 사이의 연결

## Capture Preview
- AVCaptureVideoPreviewLayer는 캡처된 비디오 데이터의 실시간 미리보기를 제공하는 core animation calayer의 하위 클래스임
- AVPlayerLayer와 비슷한 역할을 하지만 카메라 캡처의 필요에 맞게 조정됨
- 비디오 중력 개념을 지원함

## Simple Recipe
```Swift
let session = AVCaptureSession()

let cameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
let cameraInput = try? AVCaptureDeviceInput(device: cameraDevice)

if session.canAddInput(cameraInput) {
   session.addInput(cameraInput)
}

let imageOutput = AVCaptureStillImageOutput()

if session.canAddOutput(imageOutput) {
   session.addOutput(imageOutput)
}

session.startRunning()
```

## Building a Camera App
- 캡처 api는 실제 기기에서만 테스트 가능함

## Creating the Preview View
- captureDevicePointForPoint: 메소드는 터치 포인트를 화면 좌표에서 카메라 좌표로 변환해줌

## Coordinate Space Translations
- AVFoundation의 캡처 api로 작업할 때에는 화면좌표와 캡처 장치 좌표의 차이점을 잘 이해해야함
- 캡처 장치 좌표의 경우 왼쪽 위 (0,0)에서 오른쪽 아래 (1,1)까지 범위를 가짐
- AVCaptureVideoPreviewLayer는 두 좌표 공간 사이를 변환하는 두가지 방법을 제공함
- captureDevicePointOfInterestForPoint: CGPoint를 가져와 장치 좌표 공간에서 변환된 CGPoint를 반환
- pointForCaptureDevicePointOfInterest: 장치 좌표 point를 가져와 좌표 공간의 point를 반환함

## Creating the Capture Controller
## Setting Up the Capture Session
## Starting and Stopping the Session
- 세션의 startRunning, stopRunning의 경우 동기호출이므로 주의해야함.

## Handling Privacy Requirements
- ios 8부터는 접근에 대한 항목을 명시해 줘야함. 얼럿창이 떴을 때 허용안함을 누를경우 접근이 되지 않음. 이럴 경우 설정에 가서 허용하도록 바꿀것을 권고하는 얼럿창을 띄워줘야 함.

## Switching Cameras
- 앞면 카메라와 뒷면 카메라를 전환하려면 캡처 세션을 다시 구성해야함.
- AVCaptureSession은 즉성에서 재구성이 가능하므로 세션을 중지하고 다시 시작하는 비용을 들이지 않아도 됨.
- 세션의 모든 변경사항은 beginConfiguration 및 commitConfiguration 메소드 쌍을 사용하여 단일 변경으로 작성해야함.

## Configuring Capture Devices
- AVCaptureDevice는 ios장비의 카메라를 제어할 수 있도록 도와줌
- 카메라의 초점, 노출 및 화이트 밸런스 등을 조정할 수 있음
- ios의 경우 전면카메라와 후면 카메라에서 지원하는 기능이 다름. 그러므로 먼저 카메라가 기능을 지원하는지 여부를 체크해야함.
```Swift
let device = AVCaptureDevice()
if device.isFocusModeSupported(.autoFocus) {
   if try? device.lockForConfiguration() {
      device.focusMode = .autoFocus
      device.unlockForConfiguration()
   }
}
```
- 아이폰 장치는 시스템에서 공유되므로 장치를 변경하기 전에 독립적인 잠금장치가 필요함. 구성 변경에 따라 잠금여부를 결정하지 않는 경우 다른 응용프로그램에 악영향을 미칠수 있음 (AVAudioSession처럼)

## Adjusting Focus and Exposure
- AVCaputerDevice는 focus와 exposure 설정을 도와줌.
- focusMode, exposureMode 등

## Adjusting the Flash and Torch Modes
- AVCaptureDevice를 사용하면 플래시 및 토치 모드를 수정할 수 있음.
- flashMode, tourchMode 속성은 아래 세가지 값중 하나로 설정 가능
- AVCapture(Torch|Flash)ModeOn : 항상 켜짐
- AVCapture(Flash|Torch)ModeOff : 항상 꺼짐
- AVCapture(Flash|Torch)ModeAuto : 조명 상태에 따라 자동으로 켜고 끔

## Capturing Still Images
- AVCaptureConnection은 세션을 생성하고 캡처 장치 입력을 추가하고 출력을 캡처하면 세션은 자동으로 연결을 형성하여 필요에 따라 신호 흐름을 라우팅함.???? 커넥션 역할이 뭐지…
- AVCaptureConnect의 Orientation 속성에 비디오 방향을 설정해 줄 수 있음.

## Writing to the Assets Library
- Assets Library 프레임워크는 iOS 사진 앱에서 관리하는 사용자의 사진 및 비디오 라이브러리에 접근 할 수 있게 해줌.
- 사용자가 응용프로그램에 접근하기 위해서 프로그램 액세스를 명시적으로 허용해야함.
```Swift
let status = ALAssetsLibrary.authorizationStatus()
if status == .denied {
   // 허용안함
} else {
   // 허용함
}
```

## Capturing Videos
- enablesVideoStabilizationWhenAvailable 사용시 녹화된 비디오 품질을 크게 향상 시킬수 있음. (비디오 미리보기 화면에는 표시 안됨)
- 부드러운 초점 모드를 사용할 경우 초점을 맞추는 속도가 느려짐. 일반적으로 카메라는 샷을 패닝할 때 자도으로 초점을 잡으려고 하는데 이는 펄싱 효과를 유발할 수 있음. 초점을 부드럽게 하면 이러한 초점 작업이 발생하는 속도가 느려지고 더 자연스러운 비디오를 제공함.
- 비디오를 캡처할 경우 비디오가 기록될수 있는지 여부를 체크해야함. (videoAtPathIsCompatibleWithSavedPhotosAlbum 메소드)


