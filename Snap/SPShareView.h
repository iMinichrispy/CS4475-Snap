//
//  SPShareView.h
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGSize const SPShareViewImageViewSize;

NS_ASSUME_NONNULL_BEGIN

@interface SPShareView : UIView

@property (nonatomic, weak, readonly) UIVisualEffectView *effectView;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) UIButton *shareButton;
@property (nonatomic, weak, readonly) UIButton *editButton;

@end
NS_ASSUME_NONNULL_END
