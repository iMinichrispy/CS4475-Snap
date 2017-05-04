//
//  SPEmojiEffectApple.m
//  Snap
//
//  Created by Alex Perez on 5/3/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEmojiEffectApple.h"

#import "SPOpenCVHelper.h"
#import "SPRectOperations.h"

@implementation SPEmojiEffectApple {
    CGFloat _totalPoints;
    CGRect _averageRect;
    
//    NSDictionary *options = @{ CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES),};

}

- (NSString *)name {
    return @"Emoji2";
}

- (NSString *)tagline {
    return @"CoreImage";
}

- (BOOL)detectsSmile {
    return YES;
}

- (BOOL)movingAverage {
    return YES;
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
        
        UIImage *image = [UIImage imageNamed:@"LaughCry"];
        if ([faceFeature hasSmile]) {
            image = [UIImage imageNamed:@"Smile"];
        }
        
        CGFloat emojiWidth = faceRect.size.height * 1.5;
        CGFloat emojiHeight = faceRect.size.height * 1.3;
        CGPoint faceRectCenter = CGPointMake(CGRectGetMidX(faceRect), CGRectGetMidY(faceRect));
        
        CGFloat emojiOriginX = faceRectCenter.x - emojiWidth/2.0f;
        CGFloat emojiOriginY = faceRectCenter.y - emojiHeight/2.0f;
        CGRect emojiRect = CGRectMake(emojiOriginX, emojiOriginY, emojiWidth, emojiHeight);
        if (CGRectIsEmpty(_averageRect)) {
            _averageRect = emojiRect;
        } else {
            if (self.movingAverage) {
                _averageRect = SPAverageRect(_averageRect, emojiRect);
            } else {
                _averageRect = emojiRect;
            }
        }
        
        CGContextDrawImage(context, _averageRect, [image CGImage]);
        CGContextRestoreGState(context);
    }
    
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overlayImage;
}

@end
