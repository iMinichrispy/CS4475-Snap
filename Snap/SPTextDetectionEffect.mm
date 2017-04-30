//
//  SPTextDetectionEffect.m
//  Snap
//
//  Created by Alex Perez on 4/27/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPTextDetectionEffect.h"

#import "SPOpenCVHelper.h"

@implementation SPTextDetectionEffect

- (NSString *)name {
    return @"Text";
}

- (NSString *)type {
    return CIDetectorTypeText;
}

- (NSString *)accuracy {
    return CIDetectorAccuracyHigh;
}

- (BOOL)retunsSubFeatures {
    return YES;
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
    
//    CGFloat scale = imageView.frame.size.width / image.extent.width;
    for (CITextFeature *textFeature in features) {
//        feature.drawRectOnView(imageView, color: UIColor.green.withAlphaComponent(0.8), borderWidth: 2.0, scale: scale)
//        
//        // draw subFeature's rects
//        guard let subFeatures = feature.subFeatures as? [CITextFeature] else {fatalError()}
//        for subFeature in subFeatures {
//            subFeature.drawRectOnView(imageView, color: UIColor.yellow.withAlphaComponent(0.8), borderWidth: 1.0, scale: scale)
//        }
        
        
        
        CGRect textRect = [textFeature bounds];
        CGContextSaveGState(context);
        
        CGContextSetLineWidth(context, 3.0f);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextFillRect(context, textRect);
        
        for (CITextFeature *subFeature in textFeature.subFeatures) {
            CGRect subRect = [subFeature bounds];
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillRect(context, subRect);
        }
        
        //        CGContextAddArc(<#CGContextRef  _Nullable c#>, <#CGFloat x#>, <#CGFloat y#>, <#CGFloat radius#>, <#CGFloat startAngle#>, <#CGFloat endAngle#>, <#int clockwise#>)
//        CGContextAddArc(context, rectangleFeature.topLeft.x, rectangleFeature.topLeft.y, 5.0f, 0, 2 * M_PI, 1);
//        CGContextStrokePath(context);
//        CGContextAddArc(context, rectangleFeature.topRight.x, rectangleFeature.topRight.y, 5.0f, 0, 2 * M_PI, 1);
//        CGContextStrokePath(context);
//        CGContextAddArc(context, rectangleFeature.bottomLeft.x, rectangleFeature.bottomLeft.y, 5.0f, 0, 2 * M_PI, 1);
//        CGContextStrokePath(context);
//        CGContextAddArc(context, rectangleFeature.bottomRight.x, rectangleFeature.bottomRight.y, 5.0f, 0, 2 * M_PI, 1);
//        CGContextStrokePath(context);
        
        //        CGRect bounds;
        //        CGPoint topLeft;
        //        CGPoint topRight;
        //        CGPoint bottomLeft;
        //        CGPoint bottomRight;
        
        /*
         
         
         CGContextSetLineWidth(context, 3.0f);
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
         
         */
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

- (void)_drawEyeBallForFrame:(CGRect)rect
{
    /*
     CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextAddEllipseInRect(context, rect);
     CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
     CGContextFillPath(context);
     
     CGFloat x, y, eyeSizeWidth, eyeSizeHeight;
     eyeSizeWidth = rect.size.width * kRetinaToEyeScaleFactor;
     eyeSizeHeight = rect.size.height * kRetinaToEyeScaleFactor;
     
     x = 0;//arc4random_uniform((rect.size.width - eyeSizeWidth));
     y = 0;//arc4random_uniform((rect.size.height - eyeSizeHeight));
     x += rect.origin.x;
     y += rect.origin.y;
     
     CGFloat eyeSize = MIN(eyeSizeWidth, eyeSizeHeight);
     CGRect eyeBallRect = CGRectMake(x, y, eyeSize, eyeSize);
     CGContextAddEllipseInRect(context, eyeBallRect);
     CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
     CGContextFillPath(context);*/
}

@end
