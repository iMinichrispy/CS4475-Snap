//
//  UIImage+SPCrop.h
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SPCrop)

- (UIImage *)sp_croppedImageWithRect:(CGRect)rect;

@end
