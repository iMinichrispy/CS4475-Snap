//
//  SPEyeDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEyeDetection.h"

#import <UIKit/UIKit.h>

const CGFloat kRetinaToEyeScaleFactor = 0.5f;
const CGFloat kFaceBoundsToEyeScaleFactor = 4.0f;

@implementation SPEyeDetection

- (NSString *)name {
    return @"Eyes";
}

- (UIImage *)effect:(SPEffect *)effect imageForImage:(UIImage *)image {
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    // Get features from the image
    CIImage* newImage = [CIImage imageWithCGImage:image.CGImage];
    
    NSArray *features = [detector featuresInImage:newImage];
    
    UIGraphicsBeginImageContext(image.size);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    //Draws this in the upper left coordinate system
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (CIFaceFeature *faceFeature in features) {
        CGRect faceRect = [faceFeature bounds];
        CGContextSaveGState(context);
        
        // CI and CG work in different coordinate systems, we should translate to
        // the correct one so we don't get mixed up when calculating the face position.
        CGContextTranslateCTM(context, 0.0, imageRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        if ([faceFeature hasLeftEyePosition]) {
            CGPoint leftEyePosition = [faceFeature leftEyePosition];
            CGFloat eyeWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
            CGFloat eyeHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
            CGRect eyeRect = CGRectMake(leftEyePosition.x - eyeWidth/2.0f,
                                        leftEyePosition.y - eyeHeight/2.0f,
                                        eyeWidth,
                                        eyeHeight);
            [self _drawEyeBallForFrame:eyeRect];
        }
        
        if ([faceFeature hasRightEyePosition]) {
            CGPoint leftEyePosition = [faceFeature rightEyePosition];
            CGFloat eyeWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
            CGFloat eyeHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
            CGRect eyeRect = CGRectMake(leftEyePosition.x - eyeWidth / 2.0f,
                                        leftEyePosition.y - eyeHeight / 2.0f,
                                        eyeWidth,
                                        eyeHeight);
            [self _drawEyeBallForFrame:eyeRect];
        }
        
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

- (void)_drawEyeBallForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    
    CGFloat x, y, eyeSizeWidth, eyeSizeHeight;
    eyeSizeWidth = rect.size.width * kRetinaToEyeScaleFactor;
    eyeSizeHeight = rect.size.height * kRetinaToEyeScaleFactor;
    
    x = arc4random_uniform((rect.size.width - eyeSizeWidth));
    y = arc4random_uniform((rect.size.height - eyeSizeHeight));
    x += rect.origin.x;
    y += rect.origin.y;
    
    CGFloat eyeSize = MIN(eyeSizeWidth, eyeSizeHeight);
    CGRect eyeBallRect = CGRectMake(x, y, eyeSize, eyeSize);
    CGContextAddEllipseInRect(context, eyeBallRect);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillPath(context);
}

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image {
    
}

@end
