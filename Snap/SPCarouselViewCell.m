//
//  SPCarouselViewCell.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCarouselViewCell.h"

#import <Masonry/Masonry.h>

#import "SPFont.h"

@implementation SPCarouselViewCell

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [SPFont fontForTextStyle:UIFontTextStyleHeadline type:SPFontTypeBold];
            label.layer.shadowColor = [UIColor darkGrayColor].CGColor;
            label.layer.shadowOffset = CGSizeZero;
            label.layer.shadowOpacity = 1.0f;
            label.layer.shadowRadius = 5.0f;
            label;
        });
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        [self _setupConstraints];
    }
    return self;
}

#pragma mark - UICollectionViewCell

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    }
}

#pragma mark - Internal

- (void)_setupConstraints {
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.and.bottom.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView);
    }];
}

@end
