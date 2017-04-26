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

/*!
 * @class SPEffect
 * @note This is an abstract class, DO NOT USE DIRECTLY
 */
@interface SPEffect : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, nullable) NSString *prompt;

@property (nonatomic, assign) BOOL shouldHandleTouch;

- (void)processImage:(cv::Mat&)image;
- (void)start;
- (void)stop;
- (void)handleTouchFrame:(const cv::Mat&)frame;
- (UIImage *)imageForFrame:(const cv::Mat&)frame; // potentially for any post-processing

@end

NS_ASSUME_NONNULL_END
