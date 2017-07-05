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

#import "THPreviewView.h"

@interface THPreviewView ()
@property (nonatomic, strong) NSMutableDictionary *codeLayers;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation THPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _codeLayers = [NSMutableDictionary dictionary];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (AVCaptureSession*)session {
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)didDetectCodes:(NSArray *)codes {
    NSArray *transformedCodes = [self transformedCodesFromCodes:codes];
    
    NSMutableArray *lostcodes = [self.codeLayers.allKeys mutableCopy];
    
    for (AVMetadataMachineReadableCodeObject *code in transformedCodes) {
        NSString *stringValue = code.stringValue;
        if (stringValue) {
            [lostcodes removeObject:stringValue];
        } else {
            continue;
        }
        
        NSArray *layers = self.codeLayers[stringValue];
        
        if (!layers) {
            layers = @[[self makeBoundsLayer], [self makeCornersLayer]];
            
            self.codeLayers[stringValue] = layers;
            [self.previewLayer addSublayer:layers.firstObject];
            [self.previewLayer addSublayer:layers.lastObject];
        }
        
        CAShapeLayer *boundsLayer = layers[0];
        boundsLayer.path = [self bezierPathForBounds:code.bounds].CGPath;
        
        CAShapeLayer *cornersLayer = layers[1];
        cornersLayer.path = [self bezierPathForCorners:code.corners].CGPath;
    }
    
    for (NSString *stringValue in lostcodes) {
        for (CALayer *layer in self.codeLayers[stringValue]) {
            [layer removeFromSuperlayer];
        }
        
        [self.codeLayers removeObjectForKey:stringValue];
    }
}

- (NSArray *)transformedCodesFromCodes:(NSArray *)codes {
    NSMutableArray *transformedCodes = [NSMutableArray array];
    for (AVMetadataObject *code in codes) {
        AVMetadataObject *transformedcode = [self.previewLayer transformedMetadataObjectForMetadataObject:code];
        [transformedCodes addObject:transformedcode];
    }
    return transformedCodes;
}

- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRect:bounds];
}

- (CAShapeLayer *)makeBoundsLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4;
    return shapeLayer;
}

- (CAShapeLayer *)makeCornersLayer {
    CAShapeLayer *cornerLayer = [CAShapeLayer layer];
    cornerLayer.lineWidth = 2;
    cornerLayer.strokeColor = [UIColor blueColor].CGColor;
    cornerLayer.fillColor = [UIColor grayColor].CGColor;
    return cornerLayer;
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i++) {
        CGPoint point = [self pointForCorner:corners[i]];
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    [path closePath];
    return path;
}

- (CGPoint)pointForCorner:(NSDictionary *)corner {
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}

@end
