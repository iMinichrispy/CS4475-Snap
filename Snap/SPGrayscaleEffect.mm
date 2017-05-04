//
//  SPGrayscaleEffect.m
//  Snap
//
//  Created by Alex Perez on 4/30/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPGrayscaleEffect.h"

@implementation SPGrayscaleEffect

- (NSString *)name {
    return @"Gray";
}

- (void)processImage:(cv::Mat&)image {
    cvtColor(image, image, CV_BGR2GRAY);
}

@end
