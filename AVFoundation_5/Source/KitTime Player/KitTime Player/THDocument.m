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

#import "THDocument.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "THChapter.h"
#import "THExportWindowController.h"

#import <QTKit/QTMovieModernizer.h>
#import "NSFileManager+THAdditions.h"
#import "THWindow.h"

@interface THDocument () <THExportWindowControllerDelegate>
@property (weak) IBOutlet AVPlayerView *playerView;

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) THExportWindowController *exportController;

@property (nonatomic, assign) BOOL modernizing;
@end

@implementation THDocument

- (NSString *)windowNibName {
    return @"THDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
    [super windowControllerDidLoadNib:controller];

    if (!self.modernizing) {
        [self setupPlaybackStackWithURL:[self fileURL]];
    } else {
        [(id)controller.window showConvertingView];
    }
    
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSError *error = nil;
    
    if ([QTMovieModernizer requiresModernization:url error:&error]) {
        self.modernizing = YES;
        NSURL *destURL = [self tempURLForURL:url];
        if (!destURL) {
            self.modernizing = NO;
            return NO;
        }
        
        QTMovieModernizer *modernizer = [[QTMovieModernizer alloc] initWithSourceURL:url destinationURL:destURL];
        modernizer.outputFormat = QTMovieModernizerOutputFormat_H264;
        [modernizer modernizeWithCompletionHandler:^{
            if (modernizer.status == QTMovieModernizerStatusCompletedWithSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupPlaybackStackWithURL:destURL];
                    [(id)self.windowForSheet hideConvertingView];
                });
            }
        }];
    }
    
    return YES;
}

- (void)setupPlaybackStackWithURL:(NSURL *)url {
    self.asset = [AVAsset assetWithURL:url];
    NSArray *keys = @[@"commonMetadata", @"availableChapterLocales"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    self.playerView.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.showsSharingServiceButton = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            NSString *title = [self titleForAsset:self.asset];
            if (title) {
                self.windowForSheet.title = title;
            }
            
            self.chapters = [self chaptersForAsset:self.asset];
            
            if (self.chapters.count > 0) {
                [self setupActionMenu];
            }
        }
        
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
}

- (NSString *)titleInMetadata:(NSArray *)metadata {
    // 공용키 공간에서 타이틀을 가져옴.
    NSArray *items = [AVMetadataItem metadataItemsFromArray:metadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
    return [items.firstObject stringValue];
}

- (NSString *)titleForAsset:(AVAsset *)asset {
    NSString *title = [self titleInMetadata:asset.commonMetadata];
    if (title && ![title isEqualToString:@""]) {
        return title;
    }
    return nil;
}

- (NSArray *)chaptersForAsset:(AVAsset *)asset {
    NSArray *languages = [NSLocale preferredLanguages];
    
    // 해당언어에 맞는 메타데이터 그룹을 뽑아옴.
    NSArray *metadataGroups = [asset chapterMetadataGroupsBestMatchingPreferredLanguages:languages];
    NSMutableArray *chapteres = [NSMutableArray array];
    for (int i = 0; i < metadataGroups.count; i++) {
        AVTimedMetadataGroup *group = metadataGroups[i];
        
        CMTime time = group.timeRange.start;
        NSUInteger number = i + 1;
        NSString *title = [self titleInMetadata:group.items];
        
        THChapter *chapter = [THChapter chapterWithTime:time number:number title:title];
        
        [chapteres addObject:chapter];
    }
    
    return chapteres;
}

- (void)setupActionMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Previous Chapter" action:@selector(previousChapter:) keyEquivalent:@""]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Next Chapter" action:@selector(nextChapter:) keyEquivalent:@""]];
    self.playerView.actionPopUpButtonMenu = menu;
}

- (void)previousChapter:(id)sender {
    [self skipToChapter:[self findPreviousChapter]];
}

- (void)nextChapter:(id)sender {
    [self skipToChapter:[self findNextChapter]];
}

- (void)skipToChapter:(THChapter *)chapter {
    [self.playerItem seekToTime:chapter.time completionHandler:^(BOOL finished) {
        [self.playerView flashChapterNumber:chapter.number chapterTitle:chapter.title];
    }];
}

- (THChapter *)findPreviousChapter {
    CMTime playerTime = self.playerItem.currentTime;
    CMTime currentTime = CMTimeSubtract(playerTime, CMTimeMake(3, 1));
    CMTime pastTime = kCMTimeNegativeInfinity;
    
    CMTimeRange timeRange = CMTimeRangeMake(pastTime, currentTime);
    
    return [self findChapterInTimeRange:timeRange reverse:YES];
}

- (THChapter *)findNextChapter {
    CMTime currentTime = self.playerItem.currentTime;
    CMTime futureTime = kCMTimePositiveInfinity;
    
    CMTimeRange timeRange = CMTimeRangeMake(currentTime, futureTime);
    return [self findChapterInTimeRange:timeRange reverse:NO];
}

- (THChapter *)findChapterInTimeRange:(CMTimeRange)timeRange reverse:(BOOL)reverse {
    __block THChapter *matchingChapter = nil;
    NSEnumerationOptions options = reverse ? NSEnumerationReverse : 0;
    [self.chapters enumerateObjectsWithOptions:options usingBlock:^(THChapter *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isInTimeRange:timeRange]) {
            matchingChapter = obj;
            *stop = YES;
        }
    }];
    
    return matchingChapter;
}

- (IBAction)startTrimming:(id)sender {
    [self.playerView beginTrimmingWithCompletionHandler:nil];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    SEL action = [item action];
    if (action == @selector(startTrimming:)) {
        return self.playerView.canBeginTrimming;
    }
    
    return YES;
}

- (IBAction)startExporting:(id)sender {
    [self.playerView.player pause];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [savePanel orderOut:nil];
            
            NSString *preset = AVAssetExportPresetAppleM4V720pHD;
            self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.asset presetName:preset];
            
            CMTime startTime = self.playerItem.reversePlaybackEndTime;
            CMTime endTime = self.playerItem.forwardPlaybackEndTime;
            CMTimeRange timeRange = CMTimeRangeMake(startTime, endTime);
            
            self.exportSession.timeRange = timeRange;
            self.exportSession.outputFileType = [self.exportSession.supportedFileTypes firstObject];
            self.exportSession.outputURL = savePanel.URL;
            
            self.exportController = [[THExportWindowController alloc] init];
            self.exportController.exportSession = self.exportSession;
            self.exportController.delegate = self;
            [self.windowForSheet beginSheet:self.exportController.window completionHandler:nil];
            
            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                [self.windowForSheet endSheet:self.exportController.window];
                self.exportController = nil;
                self.exportSession = nil;
            }];
        }
    }];
}

- (void)exportDidCancel {
    [self.exportSession cancelExport];
}

- (NSURL *)tempURLForURL:(NSURL *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [fileManager temporaryDirectoryWithTemplateString:@"kittime.XXXXXX"];
    
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:[url lastPathComponent]];
        return [NSURL fileURLWithPath:filePath];
    }
    
    return nil;
}

@end
