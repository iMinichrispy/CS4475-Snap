//
//  SPCarouselViewController.h
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SPCarouselViewController;
@protocol SPCarouselViewControllerDataSource <NSObject>

- (NSUInteger)numberOfItemsInCarouselView:(SPCarouselViewController *)carouselView;
- (NSString *)carouselView:(SPCarouselViewController *)carouselView titleForItemAtIndex:(NSUInteger)index;

@end

@protocol SPCarouselViewControllerDelegate <NSObject>

- (void)carouselView:(SPCarouselViewController *)carouselView didSelectItemAtIndex:(NSUInteger)index;

@end

@interface SPCarouselViewController : UICollectionViewController

@property (nonatomic, weak, nullable) id<SPCarouselViewControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SPCarouselViewControllerDelegate> delegate;

@property (nonatomic) NSInteger selectedSegmentIndex;

@end

NS_ASSUME_NONNULL_END
