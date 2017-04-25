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
#import "SPEdgeDetection.h"
#import "SPContourDetection.h"
#import "SPEyeDetection.h"
#import "SPFeatureDetection.h"
#import "SPObjectDetection.h"

@implementation SPEffects

static NSArray<Class> *__effectsClasses = @[[SPInvertEffect class], [SPSepiaEffect class], [SPEdgeDetection class], [SPContourDetection class], [SPFeatureDetection class], [SPObjectDetection class], [SPEyeDetection class], [SPTextEffect class], [SPNormalEffect class]];

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
