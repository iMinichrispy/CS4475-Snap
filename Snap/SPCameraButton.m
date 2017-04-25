//
//  SPCameraButton.m
//  Snap
//
//  Created by Alex Perez on 4/20/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCameraButton.h"

@import Masonry;

static CGFloat const SPCameraButtonDefaultRingWidth = 6.0f;
static CGFloat const SPCameraButtonDefaultInnerInset = 5.0f;

@interface SPCameraButton ()

@end

@implementation SPCameraButton {
    UIColor *_outerColor;
    UIColor *_innerColor;
    BOOL _highlighted;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.outerWidth = SPCameraButtonDefaultRingWidth;
        self.innerInset = SPCameraButtonDefaultInnerInset;
        
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return self;
}

#pragma mark - Getters

- (UIColor *)outerColor {
    if (!_outerColor) {
        _outerColor = [UIColor whiteColor];
    }
    return _outerColor;
}

- (UIColor *)innerColor {
    if (!_innerColor) {
        _innerColor = [UIColor whiteColor];
    }
    return _innerColor;
}

#pragma mark - Setters

- (void)setOuterWidth:(CGFloat)outerWidth {
    if (_outerWidth != outerWidth) {
        _outerWidth = outerWidth;
        [self setNeedsDisplay];
    }
}

- (void)setOuterColor:(UIColor *)outerColor {
    if (_outerColor != outerColor) {
        _outerColor = outerColor;
        [self setNeedsDisplay];
    }
}

- (void)setInnerInset:(CGFloat)innerInset {
    if (_innerInset != innerInset) {
        _innerInset = innerInset;
        [self setNeedsDisplay];
    }
}

- (void)setInnerColor:(UIColor *)innerColor {
    if (_innerColor != innerColor) {
        _innerColor = innerColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [self.outerColor setStroke];
    
    if (_highlighted) {
        [[UIColor colorWithWhite:0.15f alpha:1.0f] setFill];
    } else {
        [self.innerColor setFill];
    }
    
    CGFloat radius = CGRectGetMidX(self.bounds) - (self.outerWidth / 2.0f);
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidX(self.bounds));
    
    CGFloat innerInset = (_highlighted) ? 0.0f : self.innerInset;
    UIBezierPath *innerCircle = [UIBezierPath bezierPath];
    [innerCircle addArcWithCenter:center radius:radius - innerInset startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [innerCircle fill];
    
    UIBezierPath *outerRing = [UIBezierPath bezierPath];
    [outerRing addArcWithCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [outerRing setLineWidth:self.outerWidth];
    [outerRing stroke];
}

#pragma mark - Actions

- (void)touchDown:(UIButton *)button {
    _highlighted = YES;
    [self setNeedsDisplay];
}

- (void)touchUp:(UIButton *)button {
    _highlighted = NO;
    [self setNeedsDisplay];
}

@end
