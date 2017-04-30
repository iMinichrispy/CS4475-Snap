//
//  SPEffects.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEffects.h"

#import "SPEffect.h"
#import "SPInvertEffect.h"
#import "SPTextEffect.h"
#import "SPNormalEffect.h"
#import "SPSepiaEffect.h"
#import "SPGrayscaleEffect.h"
#import "SPEdgeDetection.h"
#import "SPContourDetection.h"
#import "SPEyeDetection.h"
#import "SPEyeDetectionApple.h"
#import "SPFeatureDetection.h"
#import "SPObjectDetection.h"
#import "SPMouthDetection.h"
#import "SPMouthDetection2.h"
#import "SPPlaneEffect.h"
#import "SPTextDetectionEffect.h"

@implementation SPEffects

static NSArray<Class> *__effectsClasses = @[
    [SPNormalEffect class],
    [SPInvertEffect class],
    [SPSepiaEffect class],
    [SPGrayscaleEffect class],
    [SPEdgeDetection class],
    [SPContourDetection class],
    [SPFeatureDetection class],
    [SPObjectDetection class],
    [SPEyeDetection class],
    [SPEyeDetectionApple class],
    [SPMouthDetection class],
    [SPMouthDetection2 class],
    [SPPlaneEffect class],
    [SPTextDetectionEffect class],
];

#pragma mark - Getters

+ (NSArray<SPEffect *> *)effects {
    static NSArray<SPEffect *> *effects;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray<SPEffect *> *newEffects = [[NSMutableArray alloc] init];
        for (Class effectsClass in __effectsClasses) {
            SPEffect *effect = [[effectsClass alloc] init];
            [newEffects addObject:effect];
        }
        effects = newEffects;
    });
    return effects;
}

@end
