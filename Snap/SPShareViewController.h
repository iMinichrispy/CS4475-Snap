//
//  SPShareViewController.h
//  Snap
//
//  Created by Alex Perez on 4/25/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPShareResult) {
    SPShareResultCancelled,
    SPShareResultShared,
};

@class SPShareViewController;

@protocol SPShareViewControllerDelegate <NSObject>

- (void)shareViewController:(SPShareViewController *)shareViewController didFinishWithResult:(SPShareResult)result;

@end

@interface SPShareViewController : UIViewController

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, weak) id<SPShareViewControllerDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
