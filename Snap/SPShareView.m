//
//  SPShareView.m
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPShareView.h"

#import <Masonry/Masonry.h>

#import "SPFont.h"

CGSize const SPShareViewImageViewSize = (CGSize) { .width = 143.0f, .height = 190.0f };
static CGFloat const SPShareViewCornerRadius = 23.0f;
static CGFloat const SPShareViewPadding = 20.0f;
static CGFloat const SPShareViewButtonsOffest = 40.0f;

@implementation SPShareView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIVisualEffectView *effectView = ({
            UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            view.layer.cornerRadius = SPShareViewCornerRadius;
            view.clipsToBounds = YES;
            view;
        });
        [self addSubview:effectView];
        _effectView = effectView;
        
        UIImageView *imageView = ({
            UIImageView *view = [[UIImageView alloc] init];
            view.layer.cornerRadius = 4.0f;
            view.clipsToBounds = YES;
            view;
        });
        [effectView.contentView addSubview:imageView];
        _imageView = imageView;
        
        UIButton *shareButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"Share" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            button.titleLabel.font = [SPFont fontForTextStyle:UIFontTextStyleTitle1];
            button;
        });
        [effectView.contentView addSubview:shareButton];
        _shareButton = shareButton;
        
        UIButton *editButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"Edit" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            button.titleLabel.font = [SPFont fontForTextStyle:UIFontTextStyleTitle1];
            button;
        });
        [effectView.contentView addSubview:editButton];
        _editButton = editButton;
        
        [self _setupConstraints];
    }
    return self;
}

#pragma mark - Internal

- (void)_setupConstraints {
    [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.and.trailing.equalTo(self);
        make.bottom.equalTo(self).with.offset(SPShareViewCornerRadius);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.0f);
        make.top.mas_equalTo(23.0f);
        make.size.mas_equalTo(SPShareViewImageViewSize);
    }];
    
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_imageView.mas_trailing).with.offset(15.0f);
        make.trailing.mas_equalTo(-SPShareViewPadding);
        make.height.mas_equalTo(50.0f);
        make.centerY.equalTo(_imageView).with.offset(-SPShareViewButtonsOffest);
    }];
    
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shareButton);
        make.trailing.equalTo(_shareButton);
        make.height.equalTo(_shareButton);
        make.centerY.equalTo(_imageView).with.offset(SPShareViewButtonsOffest);
    }];
}

@end
