//
//  SPVideoCamera.h
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPEffect;

NS_ASSUME_NONNULL_BEGIN

@interface SPVideoCamera : UIView

@property (nonatomic, strong, nullable) SPEffect *currentEffect;

- (UIImage *)takePhoto;
- (void)start;
- (void)stop;
- (void)switchCameras;
- (void)toggleFlash;

@end

NS_ASSUME_NONNULL_END
