//
//  SPCameraView.h
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>

@class SPCarouselViewController;

@interface SPCameraView : UIView

@property (nonatomic, weak) UILabel *promptLabel;

@property (nonatomic, strong) CvVideoCamera *camera;
@property (nonatomic, weak) UIImageView *cameraContainerView;

@property (nonatomic, weak) UIButton *cameraButton;
@property (nonatomic, weak) UIButton *switchCameraButton;

@property (nonatomic, strong) SPCarouselViewController *effectsCarousel;

@end
