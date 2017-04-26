//
//  SPCameraView.m
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCameraView.h"

#import <Masonry/Masonry.h>

#import "SPCameraButton.h"
#import "SPCarouselViewController.h"
#import "SPVideoCamera.h"

@implementation SPCameraView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        SPVideoCamera *camera = ({
            SPVideoCamera *videoCamera = [[SPVideoCamera alloc] init];
            videoCamera;
        });
        [self addSubview:camera];
        _camera = camera;
        
        UIVisualEffectView *effectView = ({
            UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            
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
                [button addTarget:_camera action:@selector(switchCameras) forControlEvents:UIControlEventTouchUpInside];
                button;
            });
            [view addSubview:switchCameraButton];
            _switchCameraButton = switchCameraButton;
            
            SPCarouselViewController *effectsCarousel = ({
                SPCarouselViewController *carousel = [[SPCarouselViewController alloc] init];
                carousel.collectionView.bounces = NO;
                carousel;
            });
            [view addSubview:effectsCarousel.view];
            _effectsCarousel = effectsCarousel;
            
            view;
        });
        [self addSubview:effectView];
        _effectView = effectView;
        
        [self _setupConstraints];
    }
    return self;
}

#pragma mark - Internal

- (void)_setupConstraints {
    [_camera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_effectView);
        make.bottom.equalTo(_effectView).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    
    [_switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(55.0f, 55.0f));
        make.right.equalTo(_effectView).with.offset(-30);
        make.centerY.equalTo(_cameraButton);
    }];
    
    [_effectsCarousel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.equalTo(_effectView);
        make.bottom.equalTo(_cameraButton.mas_top);
    }];
    
    [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self);
        make.top.equalTo(_effectsCarousel.view);
    }];
}

@end
