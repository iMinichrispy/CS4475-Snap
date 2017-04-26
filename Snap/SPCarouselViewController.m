//
//  SPCarouselViewController.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPCarouselViewController.h"

#import "SPCarouselViewCell.h"
#import "SPCarouselViewFlowLayout.h"

static NSString *const SPCarouselViewCellIdentifier = @"SPCarouselViewCellIdentifier";

@interface SPCarouselViewController ()

@end

@implementation SPCarouselViewController {
    BOOL _finishedFirstLayout;
    CGPoint _firstLayoutContentOffset;
    BOOL _didChangeTraitCollection;
}

#pragma mark - Initialization

- (instancetype)init {
    SPCarouselViewFlowLayout *flowLayout = [[SPCarouselViewFlowLayout alloc] init];
    return [super initWithCollectionViewLayout:flowLayout];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.backgroundColor = nil;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[SPCarouselViewCell class] forCellWithReuseIdentifier:SPCarouselViewCellIdentifier];
    
    CGFloat contentPadding = round(CGRectGetMidX(self.collectionView.frame)) - round(SPCarouselViewFlowLayoutItemSize.width / 2);
    self.collectionView.contentInset = UIEdgeInsetsMake(0, contentPadding, 0, contentPadding);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    _didChangeTraitCollection = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!_finishedFirstLayout) {
        _finishedFirstLayout = YES;
        [self _setOffsetForSelectedSegmentIndex:_selectedSegmentIndex animated:NO];
        self.collectionView.scrollEnabled = [self _shouldScroll];
    }
    
    if (_didChangeTraitCollection) {
        [self _setOffsetForSelectedSegmentIndex:_selectedSegmentIndex animated:NO];
        self.collectionView.scrollEnabled = [self _shouldScroll];
        _didChangeTraitCollection = NO;
    }
}

#pragma mark - Setters

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    if (_selectedSegmentIndex != selectedSegmentIndex) {
        NSInteger oldSelectedSegmentIndex = _selectedSegmentIndex;
        _selectedSegmentIndex = selectedSegmentIndex;
        
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldSelectedSegmentIndex inSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedSegmentIndex inSection:0];
        
        if ([_carouselDelegate respondsToSelector:@selector(carouselView:didSelectItemAtIndex:)]) {
            [_carouselDelegate carouselView:self didSelectItemAtIndex:indexPath.row];
        }
        
        SPCarouselViewCell *oldSelectedCell = (SPCarouselViewCell *)[self.collectionView cellForItemAtIndexPath:oldIndexPath];
        oldSelectedCell.selected = NO;
        SPCarouselViewCell *selectedCell = (SPCarouselViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        selectedCell.selected = YES;
        
        [self _setOffsetForSelectedSegmentIndex:_selectedSegmentIndex animated:YES];
        
        UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
        [generator selectionChanged];
    }
}

#pragma mark - Internal

- (void)_setOffsetForSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated {
    CGPoint offset;
    if ([self _shouldScroll]) {
        // Calculate the offset to center the selected item
        CGFloat itemOffset = (SPCarouselViewFlowLayoutItemSize.width + SPCarouselViewFlowLayoutItemSpacing) * selectedSegmentIndex;
        offset = CGPointMake(itemOffset + round(SPCarouselViewFlowLayoutItemSize.width / 2) - round(CGRectGetMidX(self.collectionView.frame)), self.collectionView.contentOffset.y);
    } else {
        // Calculate the offset to center the scrollview's content
        CGFloat contentOffsetX = ([self _contentWidth] / 2) - CGRectGetMidX(self.collectionView.frame);
        offset = CGPointMake(contentOffsetX, self.collectionView.contentOffset.y);
    }
    
    // Only set the offset if the subviews have been layed out
    if (_finishedFirstLayout) {
        [self.collectionView setContentOffset:offset animated:animated];
    }
}

- (CGFloat)_contentWidth {
    NSInteger numItems = [self collectionView:self.collectionView numberOfItemsInSection:0];
    CGFloat contentWidth = (SPCarouselViewFlowLayoutItemSize.width + SPCarouselViewFlowLayoutItemSpacing) * numItems - SPCarouselViewFlowLayoutItemSpacing;
    return contentWidth;
}

- (BOOL)_shouldScroll {
    return ([self _contentWidth] > CGRectGetWidth(self.collectionView.frame));
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_carouselDataSource respondsToSelector:@selector(numberOfItemsInCarouselView:)]) {
        return [_carouselDataSource numberOfItemsInCarouselView:self];
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SPCarouselViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SPCarouselViewCellIdentifier forIndexPath:indexPath];
    
    if ([_carouselDataSource respondsToSelector:@selector(carouselView:titleForItemAtIndex:)]) {
        NSString *title = [_carouselDataSource carouselView:self titleForItemAtIndex:indexPath.row];
        cell.titleLabel.text = title;
    }
    
    cell.selected = (indexPath.row == _selectedSegmentIndex);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedSegmentIndex:indexPath.row];
}

@end
