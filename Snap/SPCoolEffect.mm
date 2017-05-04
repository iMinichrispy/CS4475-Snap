//
//  SPCoolEffect.m
//  Snap
//
//  Created by Alex Perez on 5/3/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCoolEffect.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"
#import "SPRectOperations.h"

//const CGFloat kRetinaToEyeScaleFactor = 0.5f;
const CGFloat kFaceBoundsToEyeScaleFactor = 3.0f;

@implementation SPCoolEffect {
    CGFloat _totalPoints;
    CGRect _averageSunglassesRect;
    CGRect _averageHatRect;
    CGRect _averageNecklaceRect;
}

- (NSString *)name {
    return @"Cool";
}

- (NSString *)tagline {
    return @"CoreImage";
}

- (void)processImage:(cv::Mat&)image {
    UIImage *featureImage = [self imageForFrame:image];
    cv::Mat newImage = [SPOpenCVHelper cvMatFromUIImage:featureImage];
    newImage.copyTo(image);
}

- (void)start {
    _totalPoints = 0.0f;
    _averageSunglassesRect = CGRectZero;
    _averageHatRect = CGRectZero;
    _averageNecklaceRect = CGRectZero;
}

- (UIImage *)imageForFrame:(const cv::Mat&)frame {
    UIImage *image = [super imageForFrame:frame];
    
    // Get features from the image
    CIImage* newImage = [CIImage imageWithCGImage:image.CGImage];
    
    NSArray *features = [self.detector featuresInImage:newImage];
    
    UIGraphicsBeginImageContext(image.size);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    //Draws this in the upper left coordinate system
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CIFaceFeature *faceFeatureOuter;
    CIFaceFeature *leftEyeFeature;
    CIFaceFeature *rightEyeFeature;
    for (CIFaceFeature *faceFeature in features) {
        faceFeatureOuter = faceFeature;
//        CGRect faceRect = [faceFeature bounds];
        CGContextSaveGState(context);
        
        // CI and CG work in different coordinate systems, we should translate to
        // the correct one so we don't get mixed up when calculating the face position.
        CGContextTranslateCTM(context, 0.0, imageRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        if ([faceFeature hasLeftEyePosition]) {
            leftEyeFeature = faceFeature;
        }
        
        if ([faceFeature hasRightEyePosition]) {
            rightEyeFeature = faceFeature;
        }
        
        CGContextRestoreGState(context);
    }
    
    if (rightEyeFeature && leftEyeFeature) {
        CGRect faceRect = [faceFeatureOuter bounds];
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, 0.0, imageRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
//        CGFloat eyeWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
//        CGFloat eyeHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
        
        CGPoint leftEyePosition = [faceFeatureOuter leftEyePosition];
        CGPoint rightEyePosition = [faceFeatureOuter rightEyePosition];
        
        CGFloat centerX = (leftEyePosition.x + rightEyePosition.x) / 2.0f;
        CGFloat centerY = (leftEyePosition.y + rightEyePosition.y) / 2.0f;
        CGPoint centerEyePosition = CGPointMake(centerX, centerY);
        
        CGFloat sunglassesWidth = faceRect.size.width;
        CGFloat sunglassesHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
        
        
        _totalPoints += 1.0f;
        
        ///// Sunglasses
        CGFloat mouthOriginX = centerEyePosition.x - sunglassesWidth/2.0f;
        CGFloat mouthOriginY = centerEyePosition.y - sunglassesHeight/2.0f;
        CGFloat rotation = M_PI / 3;
        CGRect sunglassesRect = CGRectMake(mouthOriginX, mouthOriginY, sunglassesWidth, sunglassesHeight);
        if (CGRectIsEmpty(_averageSunglassesRect)) {
            _averageSunglassesRect = sunglassesRect;
        } else {
            _averageSunglassesRect = SPAverageRect(_averageSunglassesRect, sunglassesRect);
        }
        [self _drawSunglassesForFrame:_averageSunglassesRect rotation:rotation];
        
        
        ///// Hat
        CGFloat hatWidth = faceRect.size.width * 1.6;
        CGFloat hatHeight = faceRect.size.height * 0.7;
        CGPoint topFaceRectCenter = CGPointMake(CGRectGetMidX(faceRect), faceRect.origin.y + faceRect.size.height);
        
        CGFloat hatOriginX = topFaceRectCenter.x - hatWidth/2.8f;
        CGFloat hatOriginY = topFaceRectCenter.y - hatHeight/2.0f + faceRect.size.height * 0.2;
        CGRect hatRect = CGRectMake(hatOriginX, hatOriginY, hatWidth, hatHeight);
        if (CGRectIsEmpty(_averageHatRect)) {
            _averageHatRect = hatRect;
        } else {
            _averageHatRect = SPAverageRect(_averageHatRect, hatRect);
        }
        [self _drawHatForFrame:_averageHatRect];
        
        ///// Necklace
        CGFloat necklaceWidth = faceRect.size.width * 1.5;
        CGFloat necklaceHeight = faceRect.size.height;
        CGPoint bottomFaceRectCenter = CGPointMake(CGRectGetMidX(faceRect), faceRect.origin.y);
        
        CGFloat necklaceOriginX = bottomFaceRectCenter.x - necklaceWidth/2.0f;
        CGFloat necklaceOriginY = bottomFaceRectCenter.y - necklaceHeight;
        CGRect necklaceRect = CGRectMake(necklaceOriginX, necklaceOriginY, necklaceWidth, necklaceHeight);
        if (CGRectIsEmpty(_averageNecklaceRect)) {
            _averageNecklaceRect = necklaceRect;
        } else {
            _averageNecklaceRect = SPAverageRect(_averageNecklaceRect, necklaceRect);
        }
        [self _drawNecklaceForFrame:_averageNecklaceRect];
        
        
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

- (void)_drawSunglassesForFrame:(CGRect)rect rotation:(CGFloat)rotation
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
//    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
//    CGContextRotateCTM(context, rotation);
//    CGContextTranslateCTM(context, rect.size.width * -0.5, rect.size.height * -0.5);

    
    UIImage *image = [UIImage imageNamed:@"Sunglasses"];
    CGContextDrawImage(context, rect, [image CGImage]);
//    CGContextDrawImage(context, (CGRect){ CGPointZero, rect.size }, [image CGImage]);
    
    CGContextRestoreGState(context);
}

- (void)_drawHatForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:@"Hat"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

- (void)_drawNecklaceForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:@"Money"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

@end
