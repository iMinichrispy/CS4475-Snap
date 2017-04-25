//
//  SPHomeViewController.m
//  Snap
//
//  Created by Alex Perez on 4/20/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPHomeViewController.h"

#import <opencv2/videoio/cap_ios.h>

#import "SPEffect.h"
#import "SPEffects.h"

#import "SPFont.h"
#import "SPCameraView.h"
#import "SPCarouselViewController.h"

@interface SPHomeViewController () <SPCarouselViewControllerDataSource, SPCarouselViewControllerDelegate, CvVideoCameraDelegate>

@property (nonatomic, weak) SPCameraView *cameraView;
@property (nonatomic, assign) NSInteger currentEffectIndex;
@property (nonatomic, strong) NSArray<SPEffect *> *effects;

@end

@implementation SPHomeViewController {
    cv::Mat outputFrame;
}

static NSInteger const SPStartingEffectIndex = 2;

#pragma mark - Setters

- (void)setCurrentEffectIndex:(NSInteger)currentEffectIndex {
    if (_currentEffectIndex != currentEffectIndex) {
        _currentEffectIndex = currentEffectIndex;
        _cameraView.camera.delegate = self;
        _cameraView.effectsCarousel.selectedSegmentIndex = _currentEffectIndex;
        SPEffect *currentEffect = self.effects[currentEffectIndex];
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
        view.effectsCarousel.delegate = self;
        view.effectsCarousel.dataSource = self;
        [view.cameraButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [view.switchCameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    [self.view addSubview:cameraView];
    _cameraView = cameraView;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
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
        [currentEffect effect:currentEffect handleTouchReferenceFrame:outputFrame];
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
    self.currentEffectIndex = index;
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
    SPEffect *currentEffect = self.effects[self.currentEffectIndex];
    [currentEffect effect:currentEffect processImage:image];
    
    image.copyTo(outputFrame);
}

#pragma mark - Actions

- (void)takePhoto:(UIButton *)sender {
    UIGraphicsBeginImageContext(_cameraView.cameraContainerView.frame.size);
    [_cameraView.cameraContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    _cameraView.cameraContainerView.image = screenshot;
//    [_camera stop];
    UIGraphicsEndImageContext();
}

- (void)switchCamera:(UIButton *)sender {
    [_cameraView.camera switchCameras];
}

@end
