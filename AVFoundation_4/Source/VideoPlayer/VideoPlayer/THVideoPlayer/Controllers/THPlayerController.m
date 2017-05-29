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

#import "THPlayerController.h"
#import "THThumbnail.h"
#import <AVFoundation/AVFoundation.h>
#import "THTransport.h"
#import "THPlayerView.h"
#import "AVAsset+THAdditions.h"
#import "UIAlertView+THAdditions.h"
#import "THNotifications.h"

// AVPlayerItem's status property
#define STATUS_KEYPATH @"status"

// Refresh interval for timed observations of AVPlayer
#define REFRESH_INTERVAL 0.5f

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;


@interface THPlayerController () <THTransportDelegate>

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (strong, nonatomic) THPlayerView *playerView;
@property (nonatomic, weak) id <THTransport> transport;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id itemEndObserver;
@property (nonatomic, assign) float lastPlayerbackRate;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation THPlayerController

#pragma mark - Setup

- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        _asset = [AVAsset assetWithURL:assetURL];
        [self prepareToPlay];
    }
    return self;
}

- (void)prepareToPlay {
    NSArray *keys = @[@"tracks", @"duration", @"commonMetadata", @"availableMediaCharacteristicsWithMediaSelectionOptions"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    
    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView = [[THPlayerView alloc] initWithPlayer:self.player];
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                [self.transport setTitle:self.asset.title];
                
                [self.player play];
                
                [self generateThumbnails];
                
                [self loadMediaOptions];
            } else {
                // error
            }
        });
    }
}

#pragma mark - Time Observers

- (void)addPlayerItemTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    __weak THPlayerController *weakSelf = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
    };
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];
}

- (void)addItemEndObserverForPlayerItem {
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak THPlayerController *weakSelf = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];
        }];
    };
    
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name object:self.playerItem queue:queue usingBlock:callback];
}

- (void)dealloc {
    if (self.itemEndObserver) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self.itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
}

#pragma mark - THTransportDelegate Methods

- (void)play {
    [self.player play];
}

- (void)pause {
    self.lastPlayerbackRate = self.player.rate;
    [self.player pause];
}

- (void)stop {
    [self.player setRate:0.0f];
    [self.transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)scrubbingDidStart {
    self.lastPlayerbackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver]; //??
    self.timeObserver = nil;
}

- (void)scrubbedToTime:(NSTimeInterval)time {
    [self.playerItem cancelPendingSeeks]; // 위 메소드는 자주불리기 때문에 보류중인 탐색을 취소시켜줌. 검색작업이 누적되지 않도록함.
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)scrubbingDidEnd {
    [self addPlayerItemTimeObserver];
    if (self.lastPlayerbackRate > 0.0f) {
        [self.player play];
    }
}


#pragma mark - Thumbnail Generation

- (void)generateThumbnails {
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    
    self.imageGenerator.maximumSize = CGSizeMake(200, 0);
    
    CMTime duration = self.asset.duration;
    NSMutableArray *times = [NSMutableArray array];
    CMTimeValue increment = duration.value;
    CMTimeValue currentValue = 2.0 * duration.timescale;
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }
    
    __block NSUInteger imageCount = times.count;
    __block NSMutableArray *images = [NSMutableArray array];
    
    AVAssetImageGeneratorCompletionHandler handler;
    
    handler = ^(CMTime requestedTime,
                CGImageRef imageRef,
                CMTime actualTime,
                AVAssetImageGeneratorResult result,
                NSError *error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            id thumbnail = [THThumbnail thumbnailWithImage:image time:actualTime];
            [images addObject:thumbnail];
        } else {
            // error
        }
        
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *name = THThumbnailsGeneratedNotification;
                [[NSNotificationCenter defaultCenter] postNotificationName:name object:images];
            });
        }
    };
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}


- (void)loadMediaOptions {
    NSString *mc = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group = [self.asset mediaSelectionGroupForMediaCharacteristic:mc];
    if (group) {
        NSMutableArray *subtitmes = [NSMutableArray array];
        for (AVMediaSelectionOption *option in group.options) {
            [subtitmes addObject:option.displayName];
        }
        [self.transport setSubtitles:subtitmes];
    } else {
        [self.transport setSubtitles:nil];
    }
}

- (void)subtitleSelected:(NSString *)subtitle {
    NSString *mc = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group = [self.asset mediaSelectionGroupForMediaCharacteristic:mc];
    BOOL selected = NO;
    for (AVMediaSelectionOption *option in group.options) {
        if ([option.displayName isEqualToString:subtitle]) {
            //선택한 옵션을 활성화
            [self.playerItem selectMediaOption:option inMediaSelectionGroup:group];
            selected = YES;
        }
    }
    
    if (!selected) {
        [self.playerItem selectMediaOption:nil inMediaSelectionGroup:group];
    }
}


#pragma mark - Housekeeping

- (UIView *)view {
    return self.playerView;
}

@end
