//
//  SPCarouselViewFlowLayout.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCarouselViewFlowLayout.h"

CGSize const SPCarouselViewFlowLayoutItemSize = (CGSize) { .width = 70.0f, .height = 38.0f};
CGFloat const SPCarouselViewFlowLayoutItemSpacing = 10.0f;

@implementation SPCarouselViewFlowLayout

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.itemSize = SPCarouselViewFlowLayoutItemSize;
        self.minimumInteritemSpacing = SPCarouselViewFlowLayoutItemSpacing;
        [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    return self;
}

@end
