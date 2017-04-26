//
//  SPInvertEffect.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPInvertEffect.h"

@implementation SPInvertEffect

- (NSString *)name {
    return @"Inverse";
}

- (void)processImage:(cv::Mat&)image {
    cv::Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_BGR2BGRA);
}

@end
