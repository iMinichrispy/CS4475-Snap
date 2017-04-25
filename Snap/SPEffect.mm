//
//  SPEffect.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEffect.h"

@implementation SPEffect

- (NSString *)name {
    return @"None";
}

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image {
    // No op, use a subclass
}

@end
