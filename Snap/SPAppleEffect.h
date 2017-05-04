//
//  SPAppleEffect.h
//  Snap
//
//  Created by Alex Perez on 4/27/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEffect.h"

@interface SPAppleEffect : SPEffect

@property (nonatomic, strong, readonly) NSString *type; // default is CIDetectorTypeFace
@property (nonatomic, strong, readonly) NSString *accuracy; //default is CIDetectorAccuracyLow
@property (nonatomic, assign, readonly) BOOL retunsSubFeatures; // default is NO
@property (nonatomic, assign, readonly) BOOL detectsSmile; // default is NO
@property (nonatomic, strong, readonly) CIDetector *detector;

@end
