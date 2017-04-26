//
//  SPEffect.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEffect.h"

#import "SPOpenCVHelper.h"

@implementation SPEffect

#pragma mark - Initialization

- (instancetype)init {
    NSAssert(![self isMemberOfClass:[SPEffect class]], @"SPEffect is an abstract class and should not be instantiated directly");
    return [super init];
}

#pragma mark - Public

- (NSString *)name {
    return @"None";
}

- (void)processImage:(cv::Mat&)image {
    // No op, to be implemented by subclasses
}

- (void)start {
    // No op, to be implemented by subclasses
}

- (void)stop {
    // No op, to be implemented by subclasses
}

- (void)handleTouchFrame:(const cv::Mat&)frame {
    // No op, to be implemented by subclasses
}

- (UIImage *)imageForFrame:(const cv::Mat&)frame {
    UIImage *image = [SPOpenCVHelper UIImageFromCVMat:frame];
    return image;
}

@end
