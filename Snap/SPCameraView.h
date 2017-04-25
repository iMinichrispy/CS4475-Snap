//
//  SPCameraView.h
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPCarouselViewController, CvVideoCamera;

NS_ASSUME_NONNULL_BEGIN

@interface SPCameraView : UIView

@property (nonatomic, strong, readonly) CvVideoCamera *camera;
@property (nonatomic, weak, readonly) UIImageView *cameraContainerView;

@property (nonatomic, weak, readonly) UIView *controlsView;
@property (nonatomic, weak, readonly) UILabel *promptLabel;
@property (nonatomic, weak, readonly) UIButton *cameraButton;
@property (nonatomic, weak, readonly) UIButton *switchCameraButton;
@property (nonatomic, weak, readonly) UIVisualEffectView *effectView;
@property (nonatomic, strong, readonly) SPCarouselViewController *effectsCarousel;

@end

NS_ASSUME_NONNULL_END
