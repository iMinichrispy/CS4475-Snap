//
//  SPTextEffect.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPTextEffect.h"

@implementation SPTextEffect

- (NSString *)name {
    return @"Text";
}

- (void)processImage:(cv::Mat&)image {
    const char* str = [@"Alex Perez" cStringUsingEncoding: NSUTF8StringEncoding];
    cv::putText(image, str, cv::Point(100, 100), cv::FONT_HERSHEY_PLAIN, 2.0, cv::Scalar(0, 0, 255));
}

@end
