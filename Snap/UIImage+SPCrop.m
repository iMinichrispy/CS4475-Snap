//
//  UIImage+SPCrop.m
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "UIImage+SPCrop.h"

@implementation UIImage (SPCrop)

// http://stackoverflow.com/questions/158914/cropping-an-uiimage
- (UIImage *)sp_croppedImageWithRect:(CGRect)rect {
    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end
