//
//  SPMusicEffect.m
//  Snap
//
//  Created by Alex Perez on 5/4/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPMusicEffect.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"
#import "SPRectOperations.h"

@implementation SPMusicEffect {
    CGFloat _totalPoints;
    CGRect _averageHeadphonesRect;
}

- (NSString *)name {
    return @"Music";
}

//- (NSString *)tagline {
//    return @"CoreImage";
//}

- (NSString *)type {
    return CIDetectorTypeFace;
}

- (void)start {
    _totalPoints = 0.0f;
    _averageHeadphonesRect = CGRectZero;
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
//    CIImage *grayscale = [newImage imageByApplyingFilter:@"CIColorControls" withInputParameters: @{kCIInputSaturationKey : @0.0}];
//    image = [UIImage imageWithCIImage:grayscale];
    
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
        
        _totalPoints += 1.0f;
        
        ///// Hat
        CGFloat hatWidth = faceRect.size.width * 1.4;
        CGFloat hatHeight = faceRect.size.height * 1.2;
        CGPoint topFaceRectCenter = CGPointMake(CGRectGetMidX(faceRect), faceRect.origin.y + faceRect.size.height);
        
        CGFloat hatOriginX = topFaceRectCenter.x - hatWidth/2.0f;
        CGFloat hatOriginY = topFaceRectCenter.y - hatHeight/2.0f - faceRect.size.height * 0.2;
        CGRect hatRect = CGRectMake(hatOriginX, hatOriginY, hatWidth, hatHeight);
        if (CGRectIsEmpty(_averageHeadphonesRect)) {
            _averageHeadphonesRect = hatRect;
        } else {
            _averageHeadphonesRect = SPAverageRect(_averageHeadphonesRect, hatRect);
        }
        [self _drawHeadphonesForFrame:_averageHeadphonesRect];
        
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

- (void)_drawHeadphonesForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:@"Headphones"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

@end
