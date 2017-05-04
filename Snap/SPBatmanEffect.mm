//
//  SPBatmanEffect.m
//  Snap
//
//  Created by Alex Perez on 5/4/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPBatmanEffect.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"
#import "SPRectOperations.h"


@implementation SPBatmanEffect {
    CGFloat _totalPoints;
    CGRect _averageSunglassesRect;
    CGRect _averageHatRect;
    CGRect _averageNecklaceRect;
}

- (NSString *)name {
    return @"Batman";
}

- (NSString *)tagline {
    return @"CoreImage";
}

- (void)processImage:(cv::Mat&)image {
    UIImage *featureImage = [self imageForFrame:image];
    cv::Mat newImage = [SPOpenCVHelper cvMatFromUIImage:featureImage];
//    cvtColor(image, image, CV_BGR2GRAY);
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
        CGFloat sunglassesHeight = faceRect.size.height * 1.3f;
        
        
        _totalPoints += 1.0f;
        
        ///// Sunglasses
        CGFloat mouthOriginX = centerEyePosition.x - sunglassesWidth/2.0f;
        CGFloat mouthOriginY = centerEyePosition.y - sunglassesHeight/2.0f + faceRect.size.height * 0.2;
        CGFloat rotation = M_PI / 3;
        CGRect sunglassesRect = CGRectMake(mouthOriginX, mouthOriginY, sunglassesWidth, sunglassesHeight);
        if (CGRectIsEmpty(_averageSunglassesRect)) {
            _averageSunglassesRect = sunglassesRect;
        } else {
            _averageSunglassesRect = SPAverageRect(_averageSunglassesRect, sunglassesRect);
        }
        [self _drawSunglassesForFrame:_averageSunglassesRect rotation:rotation];        
        
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
    
    
    UIImage *image = [UIImage imageNamed:@"Batman"];
    CGContextDrawImage(context, rect, [image CGImage]);
    //    CGContextDrawImage(context, (CGRect){ CGPointZero, rect.size }, [image CGImage]);
    
    CGContextRestoreGState(context);
}

@end
