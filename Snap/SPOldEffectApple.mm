//
//  SPOldEffectApple.m
//  Snap
//
//  Created by Alex Perez on 5/3/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPOldEffectApple.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"
#import "SPRectOperations.h"

const CGFloat kFaceBoundsToEyeScaleFactor = 4.0f;

@implementation SPOldEffectApple {
    CGFloat _totalPoints;
    CGRect _averageMustacheRect;
    CGRect _averageMonocleRect;
    CGRect _averageHatRect;
}

- (NSString *)name {
    return @"Old";
}

- (NSString *)tagline {
    return @"CoreImage";
}

- (NSString *)type {
    return CIDetectorTypeFace;
}

- (void)start {
    _totalPoints = 0.0f;
    _averageMustacheRect = CGRectZero;
    _averageMonocleRect = CGRectZero;
    _averageHatRect = CGRectZero;
}

- (void)processImage:(cv::Mat&)image {
    UIImage *featureImage = [self imageForFrame:image];
    cv::Mat newImage = [SPOpenCVHelper cvMatFromUIImage:featureImage];
    newImage.copyTo(image);
}

- (UIImage *)imageForFrame:(const cv::Mat&)frame {
    UIImage *image = [super imageForFrame:frame];
    
    // Get features from the image
    CIImage *newImage = [CIImage imageWithCGImage:image.CGImage];
    CIImage *grayscale = [newImage imageByApplyingFilter:@"CIColorControls" withInputParameters: @{kCIInputSaturationKey : @0.0}];
    image = [UIImage imageWithCIImage:grayscale];
    
    NSArray<CIFeature *> *features = [self.detector featuresInImage:newImage];
    
    UIGraphicsBeginImageContext(image.size);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    //Draws this in the upper left coordinate system
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (CIFaceFeature *faceFeature in features) {
        CGRect faceRect = [faceFeature bounds];
        
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, 0.0, imageRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        if ([faceFeature hasMouthPosition]) {
            CGPoint mouthPosition = [faceFeature mouthPosition];
            
            _totalPoints += 1.0f;
            
            
            ////// Mustache
            CGFloat mouthWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
            CGFloat mouthHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
            CGFloat mouthOriginX = mouthPosition.x - mouthHeight/2.0f;
            CGFloat mouthOriginY = mouthPosition.y - mouthHeight/2.0f;
            CGRect mouthRect = CGRectMake(mouthOriginX, mouthOriginY, mouthWidth, mouthHeight);
            if (CGRectIsEmpty(_averageMustacheRect)) {
                _averageMustacheRect = mouthRect;
            } else {
                _averageMustacheRect = SPAverageRect(_averageMustacheRect, mouthRect);
            }
            [self _drawMustacheForFrame:_averageMustacheRect];
            
            ///// Hat
            CGFloat hatWidth = faceRect.size.width * 1.5;
            CGFloat hatHeight = faceRect.size.height * 0.7;
            CGPoint topFaceRectCenter = CGPointMake(CGRectGetMidX(faceRect), faceRect.origin.y + faceRect.size.height);
            
            CGFloat hatOriginX = topFaceRectCenter.x - hatWidth/2.0f;
            CGFloat hatOriginY = topFaceRectCenter.y - hatHeight/2.0f + faceRect.size.height * 0.2;
            CGRect hatRect = CGRectMake(hatOriginX, hatOriginY, hatWidth, hatHeight);
            if (CGRectIsEmpty(_averageHatRect)) {
                _averageHatRect = hatRect;
            } else {
                _averageHatRect = SPAverageRect(_averageHatRect, hatRect);
            }
            [self _drawHatForFrame:_averageHatRect];
        }
        
        if ([faceFeature hasRightEyePosition]) {
            CGPoint rightEyePosition = [faceFeature rightEyePosition];
            CGFloat monocoleWidth = faceRect.size.width * 0.4;
            CGFloat monocoleHeight = faceRect.size.height * 0.6;
            
            CGFloat mouthOriginX = rightEyePosition.x - monocoleWidth/2.2f;
            CGFloat mouthOriginY = rightEyePosition.y - monocoleHeight/1.3f;
            CGRect monocleRect = CGRectMake(mouthOriginX, mouthOriginY, monocoleWidth, monocoleHeight);
            if (CGRectIsEmpty(_averageMonocleRect)) {
                _averageMonocleRect = monocleRect;
            } else {
                _averageMonocleRect = SPAverageRect(_averageMonocleRect, monocleRect);
            }
            [self _drawMonocleForFrame:_averageMonocleRect];
        }
        
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

- (void)_drawMustacheForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    rect.origin.x -= 50;
    rect.size.width *= 3;
    
    UIImage *image = [UIImage imageNamed:@"Mustache"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

- (void)_drawHatForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:@"TopHat"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

- (void)_drawMonocleForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:@"Monocle"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

@end
