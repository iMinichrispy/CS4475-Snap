//
//  SPCameraView.m
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCameraView.h"

#import <Masonry/Masonry.h>

#import "SPFont.h"
#import "SPCameraButton.h"
#import "SPCarouselViewController.h"

@interface SPCameraView ()

@property (nonatomic, weak) UIView *controlsView;

@end

@implementation SPCameraView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *cameraContainerView = [[UIImageView alloc] init];
        [self addSubview:cameraContainerView];
        _cameraContainerView = cameraContainerView;
        
        CvVideoCamera *camera = ({
            CvVideoCamera *videoCamera = [[CvVideoCamera alloc] initWithParentView:cameraContainerView];
            videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
            videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
            videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
            videoCamera.defaultFPS = 30;
            videoCamera.grayscaleMode = NO;
            videoCamera;
        });
        _camera = camera;
        
        UIView *controlsView = ({
            UIView *view = [[UIView alloc] init];
            
            UIButton *cameraButton = ({
                UIButton *button = [[SPCameraButton alloc] init];
                button;
            });
            [view addSubview:cameraButton];
            _cameraButton = cameraButton;
            
            UIButton *switchCameraButton = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setImage:[UIImage imageNamed:@"SwitchCamera"] forState:UIControlStateNormal];
                button.tintColor = [UIColor whiteColor];
                button;
            });
            [view addSubview:switchCameraButton];
            _switchCameraButton = switchCameraButton;
            
            UILabel *promptLabel = ({
                UILabel *label = [[UILabel alloc] init];
                label.font = [SPFont fontForTextStyle:UIFontTextStyleTitle3 type:SPFontTypeBold];
                label.translatesAutoresizingMaskIntoConstraints = NO;
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor whiteColor];
                label.layer.shadowColor = [UIColor darkGrayColor].CGColor;
                label.layer.shadowOffset = CGSizeZero;
                label.layer.shadowOpacity = 1.0f;
                label.layer.shadowRadius = 5.0f;
                label;
            });
            [view addSubview:promptLabel];
            _promptLabel = promptLabel;
            
            SPCarouselViewController *effectsCarousel = ({
                SPCarouselViewController *carousel = [[SPCarouselViewController alloc] init];
                carousel;
            });
            [view addSubview:effectsCarousel.view];
            _effectsCarousel = effectsCarousel;
            
            view;
        });
        [self addSubview:controlsView];
        _controlsView = controlsView;
        
        [self _setupConstraints];
    }
    return self;
}

#pragma mark - Internal

- (void)_setupConstraints {
    [_cameraContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_controlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_controlsView);
        make.bottom.equalTo(_controlsView).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    
    [_switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(34, 26));
        make.right.equalTo(_controlsView).with.offset(-30);
        make.centerY.equalTo(_cameraButton);
    }];
    
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_controlsView);
    }];
    
    [_effectsCarousel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.equalTo(_controlsView);
        make.bottom.equalTo(_cameraButton.mas_top);
    }];
}

@end
