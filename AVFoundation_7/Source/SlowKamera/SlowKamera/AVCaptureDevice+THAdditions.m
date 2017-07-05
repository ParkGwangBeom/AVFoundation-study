//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AVCaptureDevice+THAdditions.h"
#import "THError.h"

@interface THQualityOfService : NSObject
@property (nonatomic, strong, readonly) AVCaptureDeviceFormat *format;
@property (nonatomic, strong, readonly) AVFrameRateRange *frameRateRange;
@property (nonatomic, readonly) BOOL isHighFrameRate;
@end

@implementation THQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format frameRateRange:(AVFrameRateRange *)frameRateRange {
    return [[self alloc] initWithFormat:format frameRateRange:frameRateRange];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                frameRateRange:(AVFrameRateRange *)frameRateRange {
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = frameRateRange;
    }
    return self;
}

- (BOOL)isHighFrameRate {
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end

@implementation AVCaptureDevice (THAdditions)

- (BOOL)supportsHighFrameRateCapture {
    if (![self hasMediaType:AVMediaTypeVideo]) {
        return NO;
    }
    return [self findHighestQualityOfService].isHighFrameRate;
}

- (THQualityOfService *)findHighestQualityOfService {
    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in self.formats) {
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;
            
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) {
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }
    
    return [THQualityOfService qosWithFormat:maxFormat frameRateRange:maxFrameRateRange];
}

- (BOOL)enableMaxFrameRateCapture:(NSError **)error {
    THQualityOfService *qos = [self findHighestQualityOfService];
    
    if (!qos.isHighFrameRate) {
        if (error) {
            NSString *message = @"device does not support high FPS capture";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
            NSUInteger code = THCameraErrorHighFrameRateCaptureNotSupported;
            *error = [NSError errorWithDomain:THCameraErrorDomain code:code userInfo:userInfo];
        }
        
        return NO;
    }
    
    if ([self lockForConfiguration:error]) {
        CMTime minframeDuration = qos.frameRateRange.minFrameDuration;
        self.activeFormat = qos.format;
        self.activeVideoMinFrameDuration = minframeDuration;
        self.activeVideoMaxFrameDuration = minframeDuration;
        
        [self unlockForConfiguration];
        return YES;
    }

    return NO;
}

@end
