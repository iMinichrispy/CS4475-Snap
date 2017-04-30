//
//  SPMouthDetection2.m
//  Snap
//
//  Created by Alex Perez on 4/26/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPMouthDetection2.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"

//const CGFloat kRetinaToEyeScaleFactor = 0.5f;
const CGFloat kFaceBoundsToEyeScaleFactor = 4.0f;

@implementation SPMouthDetection2 {
    CGFloat _totalPoints;
    CGRect _averageRect;
}

- (NSString *)name {
    return @"Mouth2";
}

- (void)processImage:(cv::Mat&)image {
    UIImage *featureImage = [self imageForFrame:image];
    cv::Mat newImage = [SPOpenCVHelper cvMatFromUIImage:featureImage];
    newImage.copyTo(image);
}

- (void)start {
    _totalPoints = 0.0f;
    _averageRect = CGRectZero;
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
    
    for (CIFaceFeature *faceFeature in features) {
        CGRect faceRect = [faceFeature bounds];
        CGContextSaveGState(context);
        
        // CI and CG work in different coordinate systems, we should translate to
        // the correct one so we don't get mixed up when calculating the face position.
        CGContextTranslateCTM(context, 0.0, imageRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        if ([faceFeature hasMouthPosition]) {
            CGPoint mouthPosition = [faceFeature mouthPosition];
            
            _totalPoints += 1.0f;
            
            
            CGFloat mouthWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
            CGFloat mouthHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
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
