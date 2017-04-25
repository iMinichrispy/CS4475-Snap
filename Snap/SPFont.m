//
//  SPFont.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPFont.h"

static NSString *const SPFontAvenirMedium = @"Avenir-Medium";
static NSString *const SPFontAvenirHeavy = @"Avenir-Heavy";
static NSString *const SPFontAvenirMediumOblique = @"Avenir-MediumOblique";
static NSString *const SPFontAvenirLight = @"Avenir-Light";

@implementation SPFont

#pragma mark - Public

+ (UIFont *)fontForTextStyle:(NSString *)textStyle {
    return [self fontForTextStyle:textStyle type:SPFontTypeRegular];
}

+ (UIFont *)fontForTextStyle:(NSString *)textStyle type:(SPFontType)type {
    NSString *fontName = [self _fontNameForFontType:type];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
    return [UIFont fontWithName:fontName size:fontDescriptor.pointSize];
}

+ (UIFont *)fontForType:(SPFontType)type size:(CGFloat)size {
    NSString *fontName = [self _fontNameForFontType:type];
    return [UIFont fontWithName:fontName size:size];
}

#pragma mark - Internal

+ (NSString *)_fontNameForFontType:(SPFontType)type {
    switch (type) {
        case SPFontTypeRegular:
            return SPFontAvenirMedium;
        case SPFontTypeBold:
            return SPFontAvenirHeavy;
        case SPFontTypeItalic:
            return SPFontAvenirMediumOblique;
        case SPFontTypeLight:
            return SPFontAvenirLight;
    }
    NSAssert(NO, @"Missing font type");
    return SPFontAvenirMedium;
}

@end
