//
//  SPFaceFeaturesDetectionApple.m
//  Snap
//
//  Created by Alex Perez on 4/26/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPFaceFeaturesDetectionApple.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"

const CGFloat kRetinaToEyeScaleFactor = 0.5f;
const CGFloat kFaceBoundsToEyeScaleFactor = 4.0f;
const CGFloat kFaceBoundsToMouthScaleFactor = 4.0f;

@implementation SPFaceFeaturesDetectionApple {
    CGFloat _totalPoints;
    CGRect _averageRect;
}

- (NSString *)name {
    return @"Features";
}

- (NSString *)tagline {
    return @"CoreImage";
}

- (NSString *)type {
    return CIDetectorTypeFace;
}

- (void)start {
    _totalPoints = 0.0f;
    _averageRect = CGRectZero;
}

- (void)processImage:(cv::Mat&)image {
    UIImage *featureImage = [self imageForFrame:image];
    cv::Mat newImage = [SPOpenCVHelper cvMatFromUIImage:featureImage];
    newImage.copyTo(image);
}

- (UIImage *)imageForFrame:(const cv::Mat&)frame {
    UIImage *image = [super imageForFrame:frame];
    
    // Get features from the image
    CIImage* newImage = [CIImage imageWithCGImage:image.CGImage];
    
    NSArray<CIFeature *> *features = [self.detector featuresInImage:newImage];
    
    UIGraphicsBeginImageContext(image.size);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    //Draws this in the upper left coordinate system
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (CIFaceFeature *faceFeature in features) {
        CGRect faceRect = [faceFeature bounds];
        faceRect.origin.y = image.size.height - faceRect.origin.y - faceRect.size.height;
        
        CGContextSaveGState(context);
        
        CGContextSetLineWidth(context, 5.0f);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextStrokeRect(context, faceRect);
        
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
        
        if ([faceFeature hasMouthPosition]) {
            CGPoint mouthPosition = [faceFeature mouthPosition];
            
            _totalPoints += 1.0f;
            
            
            CGFloat mouthWidth = faceRect.size.width / kFaceBoundsToMouthScaleFactor;
            CGFloat mouthHeight = faceRect.size.height / kFaceBoundsToMouthScaleFactor;
            CGFloat mouthOriginX = mouthPosition.x - mouthHeight/2.0f;
            CGFloat mouthOriginY = mouthPosition.y - mouthHeight/2.0f;
            CGRect mouthRect = CGRectMake(mouthOriginX,
                                          mouthOriginY,
                                          mouthWidth,
                                          mouthHeight);
            
            
            if (CGRectIsEmpty(_averageRect)) {
                _averageRect = mouthRect;
            } else {
                CGFloat averageX = (_averageRect.origin.x + mouthOriginX) / 2.0f;
                CGFloat averageY = (_averageRect.origin.y + mouthOriginY) / 2.0f;
                CGFloat averageWidth = (_averageRect.size.width + mouthWidth) / 2.0f;
                CGFloat averageHeight = (_averageRect.size.height + mouthHeight) / 2.0f;
                
                _averageRect = CGRectMake(averageX, averageY, averageWidth, averageHeight);
            }
            
            [self _drawMustacheForFrame:_averageRect];
            //            [self _drawMustacheForFrame:mouthRect];
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
    
    x = 0;//arc4random_uniform((rect.size.width - eyeSizeWidth));
    y = 0;//arc4random_uniform((rect.size.height - eyeSizeHeight));
    x += rect.origin.x + eyeSizeWidth / 2 + 8;
    y += rect.origin.y + eyeSizeHeight / 2 + 8;
    
    CGFloat eyeSize = MIN(eyeSizeWidth, eyeSizeHeight);
    CGRect eyeBallRect = CGRectMake(x, y, eyeSize, eyeSize);
    CGContextAddEllipseInRect(context, eyeBallRect);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillPath(context);
}

- (void)_drawMustacheForFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextAddEllipseInRect(context, rect);
    //    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    //    CGContextFillPath(context);
    //
    //    CGFloat x, y, eyeSizeWidth, eyeSizeHeight;
    //    eyeSizeWidth = rect.size.width * kRetinaToEyeScaleFactor;
    //    eyeSizeHeight = rect.size.height * kRetinaToEyeScaleFactor;
    //
    //    x = arc4random_uniform((rect.size.width - eyeSizeWidth));
    //    y = arc4random_uniform((rect.size.height - eyeSizeHeight));
    //    x += rect.origin.x;
    //    y += rect.origin.y;
    //
    //    CGFloat eyeSize = MIN(eyeSizeWidth, eyeSizeHeight);
    //    CGRect eyeBallRect = CGRectMake(x, y, eyeSize, eyeSize);
    //    CGContextAddEllipseInRect(context, eyeBallRect);
    //    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    //    CGContextFillPath(context);
    
    //    CGFloat x, y, eyeSizeWidth, eyeSizeHeight;
    //    eyeSizeWidth = rect.size.width * kRetinaToEyeScaleFactor;
    //    eyeSizeHeight = rect.size.height * kRetinaToEyeScaleFactor;
    
    rect.origin.x -= 50;
    rect.size.width *= 3;
    //    rect.size.height;
    
    UIImage *image = [UIImage imageNamed:@"Mustache"];
    CGContextDrawImage(context, rect, [image CGImage]);
}

@end
