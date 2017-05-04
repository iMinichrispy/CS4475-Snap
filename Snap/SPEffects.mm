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
#import "SPFaceFeaturesDetection.h"
#import "SPFaceFeaturesDetectionApple.h"
#import "SPFeatureDetection.h"
#import "SPObjectDetection.h"
#import "SPMouthDetection.h"
#import "SPFaceFeaturesDetectionApple.h"
#import "SPPlaneEffect.h"
#import "SPTextDetectionEffect.h"
#import "SPEmojiEffectApple.h"
#import "SPEmojiEffectJumpApple.h"
#import "SPFaceEffect.h"
#import "SPFaceEffectApple.h"
#import "SPOldEffectApple.h"
#import "SPCoolEffect.h"
#import "SPMusicEffect.h"

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
    [SPFaceEffect class],
    [SPFaceEffectApple class],
    [SPFaceFeaturesDetectionApple class],
    [SPEmojiEffectJumpApple class],
    [SPEmojiEffectApple class],
    [SPFaceFeaturesDetection class],
    
    [SPCoolEffect class],
    [SPOldEffectApple class],
//    [SPMusicEffect class],
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
