# Reading and Writing Media

- AV Foundation은 재생, 캡처 및 편집 작업과 같은 상위 수준 작업을 수행하는데 필요한 많은 기능을 제공하지만 사용자의 요구를 충족시키지 못할경우 저수준의 기능을 이용해야함.

### Overview
- AVFoundation은 광범위한 기능을 제공함.

### AVAssetReader
- AVAssetReader는 AVAsset의 인스턴스에서 미디어 샘플을 읽는데 사용됨.
- 하나 이상의 AVAssetReaderOutput 객체로 구성되어 copyNextSampleBuffer 메소드를 통해 오디오 샘플 및 비디오 프레임에 대한 접근을 제공함.

```Objective-c
AVAssetReader는 단일 Asset에 포함된 미디어 샘플만 지정 가능함. 동시에 여러 파일 기반 Asset 샘플을 읽어야 하는 경우 AVComposition 클래스를 이용하여 샘플을 구성 할 수 잇음.
```

### AVAssetWriter
- AVAssetReader에 상응하여 미디어를 인코딩하고 기록하는 사용됨.
- AVAssetWriteInput은 오디오 또는 비디오와 같은 특정 미디어 유형을 처리하도록 구성되며 샘플에 첨부 된 샘플은 최종 출력 내에서 개별 AVAssetTrack을 생성함.
- 비디오 샘플을 처리하도록 구성된 AVAssetWriteInput의 경우 작업할 때 AVAssetWriterInputPixelBufferAdaptor라는 어댑터 객체를 자주 사용함.
- 그룹화 하기 위해서는 AVAssetWriteInputGroup을 사용함.
- AVAssetWriter는 실시간 및 오프라인 작업 모두에 사용 가능함.
    - RealTime: 실시간 소스로 작업 할때에는 AVAssetWriterInput은 expectForMediaDataInRealTime 속성을 YES로 설정하여 readyForMoreMediaData값이 적절히 계산 되도록 해야함.  이상적인 인터리빙을 유지하는 것과 달리 샘플을 빨리 작성하는 것이 중요함.
    - Offline: 오프라인 소스에서 미디어를 읽는 경우 샘플을 추가하기 전에 requestMediaDataWhenReadyOnQueue : usingBlock : 메소드를 사용하여 데이터 공급을 제어할 수 있음.

### Reading and Writing Example
```Objective-c
“AVAsset *asset = // Asynchronously loaded video asset
AVAssetTrack *track =
    [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

self.assetReader =
    [[AVAssetReader alloc] initWithAsset:asset error:nil];

NSDictionary *readerOutputSettings = @{
    (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
};

// 비디오 트랙에서 샘플을 읽고 비디오 프레임을 BGRA형식으로 압축 해제하는 객체
AVAssetReaderTrackOutput *trackOutput =
    [[AVAssetReaderTrackOutput alloc] initWithTrack:track
                                        outputSettings:readerOutputSettings];

[self.assetReader addOutput:trackOutput];

// startReading 메소드를 호출하여 읽기 시작함.
[self.assetReader startReading];”
```

```Objective-c
NSURL *outputURL = // Destination output URL

// 출력 url에 새 파일을 원하는 파일 형식과 함께 써야함.
self.assetWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];

NSDictionary *writerOutputSettings = @{
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @1280,
    AVVideoHeightKey: @720,
    AVVideoCompressionPropertiesKey: @{
        AVVideoMaxKeyFrameIntervalKey: @1,
        AVVideoAverageBitRateKey: @10500000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
    }
};

AVAssetWriterInput *writerInput =
    [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                   outputSettings:writerOutputSettings];

[self.assetWriter addInput:writerInput];

[self.assetWriter startWriting];
```

- AVAssetWriter가 AVAssetExportSession을 통해 제공하는 뚜렷한 이점은 출력을 인코딩 할 때 사용하는 압축 설정을 세부적으로 제어 가능하기 떄문임. 이를 통해 키 프레임 간격, 비디오 비트 전송률, h.264 프로파일, 픽셀 종횡비,  clean aperture 등과 같은 설정을 지정할 수 있음.

```Objective-c
// Serial Queue
dispatch_queue_t dispatchQueue =
    dispatch_queue_create("com.tapharmonic.WriterQueue", NULL);

// 쓰기 세션 시작
[self.assetWriter startSessionAtSourceTime:kCMTimeZero];

// writer 입력이 더 많은 샘플을 추가 할 준비가 되면 계속 호출됨
[writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{

    BOOL complete = NO;

    while ([writerInput isReadyForMoreMediaData] && !complete) {

        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];

        if (sampleBuffer) {
            BOOL result = [writerInput appendSampleBuffer:sampleBuffer];
            CFRelease(sampleBuffer);
            complete = !result;
        } else {
            [writerInput markAsFinished];
            complete = YES;
        }
    }

    if (complete) {
        [self.assetWriter finishWritingWithCompletionHandler:^{
            AVAssetWriterStatus status = self.assetWriter.status;
            if (status == AVAssetWriterStatusCompleted) {
                // Handle success case
            } else {
                // Handle failure case
            }
        }];
    }
}];
```
