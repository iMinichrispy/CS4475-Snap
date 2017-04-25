//
//  SPEffects.h
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPEffect;

@interface SPEffects : NSObject

@property (class, readonly) NSArray<SPEffect *> *effects;

@end
