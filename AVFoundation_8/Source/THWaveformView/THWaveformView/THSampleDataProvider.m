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

#import "THSampleDataProvider.h"

@implementation THSampleDataProvider

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(THSampleDataCompletionBlock)completionBlock {
    NSString *trakcs = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[trakcs] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:trakcs error:nil];
        
        NSData *sampleData = nil;
        
        if (status == AVKeyValueStatusLoaded) {
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sampleData);
        });
    }];
}

+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    NSError *error = nil;
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error]; // 1
    
    if (!assetReader) {
        return nil;
    }
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject]; // 2
    
    NSDictionary *outputSettions = @{AVFormatIDKey : @(kAudioFormatLinearPCM), // 3
                                     AVLinearPCMIsBigEndianKey: @NO,
                                     AVLinearPCMIsFloatKey: @NO,
                                     AVLinearPCMBitDepthKey: @(16)};
    
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettions]; // 4
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    
    NSMutableData *sampleData = [NSMutableData data];
    
    while (assetReader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer]; // 5
        
        if (sampleBuffer) {
            // 6
            // CMSam
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, sampleBytes); // 7
            
            [sampleData appendBytes:sampleBytes length:length];
            
            // 샘플 버퍼가 처리되면 Invalidate 함수를 사용하여 나중에 사용하지 못하도록 함.
            CMSampleBufferInvalidate(sampleBuffer); // 8
            CFRelease(sampleBuffer);
        }
    }
    
    if (assetReader.status == AVAssetReaderStatusCompleted) { // 9
        return  sampleData;
    } else {
        return nil;
    }
}

@end
