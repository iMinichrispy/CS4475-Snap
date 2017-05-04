//
//  SPAppleEffect.m
//  Snap
//
//  Created by Alex Perez on 4/27/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPAppleEffect.h"

@implementation SPAppleEffect

- (instancetype)init {
    self = [super init];
    if (self) {
        _retunsSubFeatures = NO;
        _detector = [CIDetector detectorOfType:self.type context:nil options:@{CIDetectorAccuracy: self.accuracy, CIDetectorReturnSubFeatures: @(self.retunsSubFeatures), CIDetectorSmile: @(self.detectsSmile), CIDetectorEyeBlink: @(self.detectsSmile)}];
    }
    return self;
}

- (NSString *)type {
    return CIDetectorTypeFace;
}

- (NSString *)accuracy {
    return CIDetectorAccuracyLow;
}

@end
