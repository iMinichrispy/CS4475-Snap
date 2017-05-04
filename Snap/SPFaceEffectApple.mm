//
//  SPFaceEffectApple.m
//  Snap
//
//  Created by Alex Perez on 5/3/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPFaceEffectApple.h"

#import <UIKit/UIKit.h>
#import "SPOpenCVHelper.h"

@implementation SPFaceEffectApple

- (NSString *)name {
    return @"Face2";
}

- (NSString *)tagline {
    return @"CoreImage";
}

- (NSString *)type {
    return CIDetectorTypeFace;
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
        
        CGContextTranslateCTM(context, 0.0, imageRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

@end
