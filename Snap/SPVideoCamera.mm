//
//  SPVideoCamera.m
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPVideoCamera.h"

#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <opencv2/videoio/cap_ios.h>

#import "SPEffect.h"
#import "SPFont.h"

@interface SPVideoCamera () <CvVideoCameraDelegate>

@property (nonatomic, strong, readonly) CvVideoCamera *camera;
@property (nonatomic, weak, readonly) UILabel *promptLabel;
@property (nonatomic, weak, readonly) UILabel *taglineLabel;
@property (nonatomic, weak, readonly) UIView *containerView;

@end

@implementation SPVideoCamera {
    cv::Mat _outputFrame;
    BOOL _flashOn;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *containerView = ({
            UIView *view = [[UIView alloc] init];
            view;
        });
        [self addSubview:containerView];
        _containerView = containerView;
        
        CvVideoCamera *camera = ({
            CvVideoCamera *videoCamera = [[CvVideoCamera alloc] initWithParentView:containerView];
            videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
            videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
            videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
            videoCamera.defaultFPS = 30;
            videoCamera.grayscaleMode = NO;
            videoCamera.delegate = self;
            videoCamera;
        });
        _camera = camera;
        
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
        [self addSubview:promptLabel];
        _promptLabel = promptLabel;
        
        UILabel *taglineLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.font = [SPFont fontForTextStyle:UIFontTextStyleFootnote type:SPFontTypeBold];
//            label.backgroundColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            
            label.layer.shadowColor = [UIColor darkGrayColor].CGColor;
            label.layer.shadowOffset = CGSizeZero;
            label.layer.shadowOpacity = 1.0f;
            label.layer.shadowRadius = 5.0f;
            label;
        });
        [self addSubview:taglineLabel];
        _taglineLabel = taglineLabel;
        
        [self _setupConstraints];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

#pragma mark - Setters

- (void)setCurrentEffect:(SPEffect *)currentEffect {
    if (_currentEffect != currentEffect) {
        SPEffect *previousEffect = _currentEffect;
        _currentEffect = currentEffect;
        
        _promptLabel.text = _currentEffect.prompt.uppercaseString;
#if DEBUG
        _taglineLabel.text = _currentEffect.tagline;
#endif
        _promptLabel.hidden = NO;
        
        [previousEffect stop];
        [currentEffect start];
    }
}

#pragma mark - Public

- (void)start {
    [_camera start];
}

- (void)stop {
    [_camera stop];
}

- (void)switchCameras {
    [_camera switchCameras];
}

- (UIImage *)takePhoto {
    _promptLabel.hidden = YES;
    UIImage *image = [_currentEffect imageForFrame:_outputFrame];
    return image;
}

- (void)toggleFlash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        
        [device lockForConfiguration:nil];
        if (_flashOn) {
            [device setTorchMode:AVCaptureTorchModeOff];
//            [device setFlashMode:AVCaptureFlashModeOff];
            _flashOn = NO;
        } else {
            [device setTorchMode:AVCaptureTorchModeOn];
//            [device setFlashMode:AVCaptureFlashModeOn];
            _flashOn = YES;
        }
        [device unlockForConfiguration];
    }
}

#pragma mark - Internal

- (void)_setupConstraints {
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [_taglineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).with.offset(180);
        make.trailing.equalTo(self).with.offset(-5);
    }];
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
    [_currentEffect processImage:image];
    image.copyTo(_outputFrame);
}

#pragma mark - Gestures

- (void)didTap:(UITapGestureRecognizer *)recognizer {
    [_currentEffect handleTouchFrame:_outputFrame];
    _promptLabel.hidden = YES;
}

@end
