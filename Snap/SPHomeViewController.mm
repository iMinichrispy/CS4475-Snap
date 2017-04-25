//
//  SPHomeViewController.m
//  Snap
//
//  Created by Alex Perez on 4/20/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPHomeViewController.h"

#import <Masonry/Masonry.h>
#import <opencv2/videoio/cap_ios.h>

#import "SPEffect.h"
#import "SPEffects.h"
#import "SPFont.h"
#import "SPCameraView.h"
#import "SPCarouselViewController.h"
#import "SPShareViewController.h"
#import "SPOpenCVHelper.h"

@interface SPHomeViewController () <SPCarouselViewControllerDataSource, SPCarouselViewControllerDelegate, CvVideoCameraDelegate, UIGestureRecognizerDelegate, SPShareViewControllerDelegate>

@property (nonatomic, weak) SPCameraView *cameraView;
@property (nonatomic, assign) NSInteger currentEffectIndex;
@property (nonatomic, strong) NSArray<SPEffect *> *effects;

@end

@implementation SPHomeViewController {
    cv::Mat _outputFrame;
    SPEffect *_previousEffect;
}

static NSInteger const SPStartingEffectIndex = 3;

#pragma mark - Setters

- (void)setCurrentEffectIndex:(NSInteger)currentEffectIndex {
    if (_currentEffectIndex != currentEffectIndex) {
        _currentEffectIndex = currentEffectIndex;
        SPEffect *currentEffect = self.effects[currentEffectIndex];
        
        if ([_previousEffect respondsToSelector:@selector(effectDidEnd:)]) {
            [_previousEffect effectDidEnd:_previousEffect];
        }
        
        if ([currentEffect respondsToSelector:@selector(effectDidStart:)]) {
            [currentEffect effectDidStart:currentEffect];
        }
        _previousEffect = currentEffect;
        
        _cameraView.effectsCarousel.selectedSegmentIndex = _currentEffectIndex;
        _cameraView.promptLabel.text = currentEffect.prompt.uppercaseString;
        _cameraView.promptLabel.hidden = NO;
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.effects = [SPEffects effects];
    
    SPCameraView *cameraView = ({
        SPCameraView *view = [[SPCameraView alloc] initWithFrame:self.view.bounds];
        view.camera.delegate = self;
        view.effectsCarousel.carouselDelegate = self;
        view.effectsCarousel.carouselDataSource = self;
        [view.cameraButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [view.switchCameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    [self.view addSubview:cameraView];
    _cameraView = cameraView;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    // Workaround to ensure setter gets called
    _currentEffectIndex = -1;
    self.currentEffectIndex = SPStartingEffectIndex;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_cameraView.camera start];
}

#pragma mark - Gestures

- (void)didTap:(UITapGestureRecognizer *)recognizer {
    SPEffect *currentEffect = self.effects[self.currentEffectIndex];
    if ([currentEffect respondsToSelector:@selector(effect:handleTouchReferenceFrame:)]) {
        [currentEffect effect:currentEffect handleTouchReferenceFrame:_outputFrame];
    }
    _cameraView.promptLabel.hidden = YES;
}

- (void)didSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        self.currentEffectIndex = MAX(0, self.currentEffectIndex - 1);
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        self.currentEffectIndex = MIN(self.effects.count - 1, self.currentEffectIndex + 1);
    }
}

#pragma mark - SPCarouselViewControllerDataSource

- (NSUInteger)numberOfItemsInCarouselView:(SPCarouselViewController *)carouselView {
    return self.effects.count;
}

- (NSString *)carouselView:(SPCarouselViewController *)carouselView titleForItemAtIndex:(NSUInteger)index {
    SPEffect *effect = self.effects[index];
    NSString *name = effect.name;
    return name;
}

#pragma mark - SPCarouselViewControllerDelegate

- (void)carouselView:(SPCarouselViewController *)carouselView didSelectItemAtIndex:(NSUInteger)index {
//    self.currentEffectIndex = index;
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
    SPEffect *currentEffect = self.effects[self.currentEffectIndex];
    [currentEffect effect:currentEffect processImage:image];
    
    image.copyTo(_outputFrame);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *carouselView = _cameraView.effectsCarousel.view;
    if (CGRectContainsPoint(carouselView.bounds, [touch locationInView:carouselView])) {
        return NO;
    }
    return YES;
}

#pragma mark - SPShareViewControllerDelegate

- (void)shareViewController:(SPShareViewController *)shareViewController didFinishWithResult:(SPShareResult)result {
    [shareViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)takePhoto:(UIButton *)sender {
    UIImage *image = [SPOpenCVHelper UIImageFromCVMat:_outputFrame];
    SPEffect *currentEffect = self.effects[_currentEffectIndex];
    if ([currentEffect respondsToSelector:@selector(effect:imageForImage:)]) {
        image = [currentEffect effect:currentEffect imageForImage:image];
    }
    
    if (image) {
        _cameraView.promptLabel.hidden = YES;
        
        SPShareViewController *shareViewController = [[SPShareViewController alloc] initWithImage:image];
        shareViewController.delegate = self;
        [self presentViewController:shareViewController animated:YES completion:nil];
    }
}

- (void)switchCamera:(UIButton *)sender {
    [_cameraView.camera switchCameras];
}

@end
