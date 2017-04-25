//
//  SPFont.h
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SPFontType) {
    SPFontTypeRegular,
    SPFontTypeBold,
    SPFontTypeItalic,
    SPFontTypeLight
};

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class SPFont
 * @abstract Provides custom font styles for a consistent look across the app
 */
@interface SPFont : NSObject

+ (UIFont *)fontForTextStyle:(NSString *)textStyle; // type = SPFontTypeRegular
+ (UIFont *)fontForTextStyle:(NSString *)textStyle type:(SPFontType)type;
+ (UIFont *)fontForType:(SPFontType)type size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
