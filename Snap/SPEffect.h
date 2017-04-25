//
//  SPEffect.h
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

@class SPEffect;
@protocol SPEffectDelegate <NSObject>

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image;

@optional
- (void)effect:(SPEffect *)effect handleTouchReferenceFrame:(const cv::Mat&)reference;
- (void)effectDidStart:(SPEffect *)effect;
- (void)effectDidEnd:(SPEffect *)effect;
- (UIImage *)effect:(SPEffect *)effect imageForImage:(UIImage *)image;

@end

@interface SPEffect : NSObject <SPEffectDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, nullable) NSString *prompt;

@end

NS_ASSUME_NONNULL_END
