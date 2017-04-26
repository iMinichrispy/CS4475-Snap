//
//  SPHomeViewController.m
//  Snap
//
//  Created by Alex Perez on 4/20/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPHomeViewController.h"

#import <Masonry/Masonry.h>
#import <AudioToolbox/AudioToolbox.h>

#import "SPEffect.h"
#import "SPEffects.h"
#import "SPFont.h"
#import "SPCameraView.h"
#import "SPCarouselViewController.h"
#import "SPShareViewController.h"
#import "SPVideoCamera.h"

@interface SPHomeViewController () <SPCarouselViewControllerDataSource, SPCarouselViewControllerDelegate, UIGestureRecognizerDelegate, SPShareViewControllerDelegate>

@property (nonatomic, weak) SPCameraView *cameraView;
@property (nonatomic, assign) NSInteger currentEffectIndex;
@property (nonatomic, strong) NSArray<SPEffect *> *effects;

@end

@implementation SPHomeViewController

static NSInteger const SPStartingEffectIndex = 9;

#pragma mark - Setters

- (void)setCurrentEffectIndex:(NSInteger)currentEffectIndex {
    if (_currentEffectIndex != currentEffectIndex) {
        _currentEffectIndex = currentEffectIndex;
        SPEffect *currentEffect = self.effects[currentEffectIndex];
        _cameraView.camera.currentEffect = currentEffect;
        _cameraView.effectsCarousel.selectedSegmentIndex = _currentEffectIndex;
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.effects = [SPEffects effects];
    
    SPCameraView *cameraView = ({
        SPCameraView *view = [[SPCameraView alloc] initWithFrame:self.view.bounds];
        view.effectsCarousel.carouselDelegate = self;
        view.effectsCarousel.carouselDataSource = self;
        [view.cameraButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    [self.view addSubview:cameraView];
    _cameraView = cameraView;
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeRecognizer.delegate = self;
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeRecognizer.delegate = self;
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    // Workaround to ensure setter gets called
    _currentEffectIndex = -1;
    self.currentEffectIndex = SPStartingEffectIndex;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_cameraView.camera start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_cameraView.camera stop];
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

#pragma mark - SPShareViewControllerDelegate

- (void)shareViewController:(SPShareViewController *)shareViewController didFinishWithResult:(SPShareResult)result {
    [shareViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == _cameraView.effectView) {
        return NO;
    }
    return YES;
}

#pragma mark - Gestures

- (void)didSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        self.currentEffectIndex = MAX(0, self.currentEffectIndex - 1);
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        self.currentEffectIndex = MIN(self.effects.count - 1, self.currentEffectIndex + 1);
    }
}

#pragma mark - Actions

- (void)takePhoto:(UIButton *)sender {
    AudioServicesPlaySystemSoundWithCompletion(1108, nil);
    
    UIImage *image = [_cameraView.camera takePhoto];
    if (image) {
        SPShareViewController *shareViewController = [[SPShareViewController alloc] initWithImage:image];
        shareViewController.delegate = self;
        [self presentViewController:shareViewController animated:YES completion:nil];
        AudioServicesPlaySystemSoundWithCompletion(1519, nil);
    }
}

@end
