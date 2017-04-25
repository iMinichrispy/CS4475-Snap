//
//  SPCameraButton.h
//  Snap
//
//  Created by Alex Perez on 4/20/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPCameraButton : UIButton

@property (nonatomic, assign) CGFloat outerWidth;
@property (nonatomic, strong, null_resettable) UIColor *outerColor;

@property (nonatomic, assign) CGFloat innerInset;
@property (nonatomic, strong, null_resettable) UIColor *innerColor;

@end

NS_ASSUME_NONNULL_END
