//
//  SPShareViewController.m
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPShareViewController.h"

#import <Masonry/Masonry.h>

#import "SPShareView.h"
#import "UIImage+SPCrop.h"

@interface SPShareViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak, readonly) SPShareView *shareView;

@end

@implementation SPShareViewController {
    SPShareResult _shareResult;
}

#pragma mark - Initialization

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    SPShareView *shareView = ({
        SPShareView *view = [[SPShareView alloc] init];
        view.imageView.image = [_image sp_croppedImageWithRect:CGRectMake(0.0f, 20.0f, _image.size.width, _image.size.height - 40.0f)];
        [view.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    [self.view addSubview:shareView];
    _shareView = shareView;
    
    [_shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(SPShareViewImageViewSize.height + 23.0f + 20.0f);
        make.bottom.leading.and.trailing.equalTo(self.view);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Actions

- (void)share:(UIButton *)sender {
    if (_image) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[_image] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

#pragma mark - Gestures

- (void)didTap:(UITapGestureRecognizer *)recognizer {
    if ([_delegate respondsToSelector:@selector(shareViewController:didFinishWithResult:)]) {
        [_delegate shareViewController:self didFinishWithResult:_shareResult];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.view) {
        return YES;
    }
    return NO;
}

@end
