//
//  HomeCardFlowLayout.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardFlowLayout.h"

@implementation HomeCardFlowLayout

- (void)prepareLayout {
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGSize deviceSize = [[UIScreen mainScreen] bounds].size;
    CGFloat interMargin = deviceSize.width * 24.0 / 640;
    CGFloat itemWidth = 548.0/640*deviceSize.width;
    CGFloat itemHeight = 850.0/1136*deviceSize.height;
    CGFloat edgeMargin = deviceSize.width - itemWidth - 2*interMargin;
    self.minimumInteritemSpacing = interMargin;
    self.minimumLineSpacing = 0.0f;
    self.itemSize = CGSizeMake(itemWidth,itemHeight);
    self.sectionInset = UIEdgeInsetsMake(0, edgeMargin, 0, edgeMargin);

}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    NSLog(@"called");
    if (proposedContentOffset.x > self.collectionView.contentOffset.x) {
        proposedContentOffset.x = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width / 2.;
    }
    else if (proposedContentOffset.x < self.collectionView.contentOffset.x) {
        proposedContentOffset.x = self.collectionView.contentOffset.x - self.collectionView.bounds.size.width / 2.;
    }
    
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + self.collectionView.bounds.size.width / 2.;
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0., self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes *a in attributes) {
        CGFloat itemHorizontalCenter = a.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    CGPoint point = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    return point;
}

//- (CGSize)collectionViewContentSize
//{
//    // Only support single section for now.
//    // Only support Horizontal scroll
//    NSUInteger count = [self.collectionView.dataSource collectionView:self.collectionView
//                                               numberOfItemsInSection:0];
//    
//    CGSize canvasSize = self.collectionView.frame.size;
//    CGSize contentSize = canvasSize;
//    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
//    {
//        NSUInteger rowCount = (canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1;
//        NSUInteger columnCount = (canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1;
//        NSUInteger page = ceilf((CGFloat)count / (CGFloat)(rowCount * columnCount));
//        contentSize.width = page * canvasSize.width;
//    }
//    
//    return contentSize;
//}
//
//
//- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize canvasSize = self.collectionView.frame.size;
//    
//    NSUInteger rowCount = (canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1;
//    NSUInteger columnCount = (canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1;
//    
//    CGFloat pageMarginX = (canvasSize.width - columnCount * self.itemSize.width - (columnCount > 1 ? (columnCount - 1) * self.minimumLineSpacing : 0)) / 2.0f;
//    CGFloat pageMarginY = (canvasSize.height - rowCount * self.itemSize.height - (rowCount > 1 ? (rowCount - 1) * self.minimumInteritemSpacing : 0)) / 2.0f;
//
//    NSUInteger page = indexPath.row / (rowCount * columnCount);
//    NSUInteger remainder = indexPath.row - page * (rowCount * columnCount);
//    NSUInteger row = remainder / columnCount;
//    NSUInteger column = remainder - row * columnCount;
//    
//    CGRect cellFrame = CGRectZero;
//    cellFrame.origin.x = pageMarginX + column * (self.itemSize.width + self.minimumLineSpacing);
//    cellFrame.origin.y = pageMarginY + row * (self.itemSize.height + self.minimumInteritemSpacing);
//    cellFrame.size.width = self.itemSize.width;
//    cellFrame.size.height = self.itemSize.height;
//    
//    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
//    {
//        cellFrame.origin.x += page * canvasSize.width;
//    }
//    
//    return cellFrame;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewLayoutAttributes * attr = [super layoutAttributesForItemAtIndexPath:indexPath];
//    attr.frame = [self frameForItemAtIndexPath:indexPath];
//    return attr;
//}
//
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    NSArray * originAttrs = [super layoutAttributesForElementsInRect:rect];
//    NSMutableArray * attrs = [NSMutableArray array];
//    
//    [originAttrs enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * attr, NSUInteger idx, BOOL *stop) {
//        NSIndexPath * idxPath = attr.indexPath;
//        CGRect itemFrame = [self frameForItemAtIndexPath:idxPath];
//        if (CGRectIntersectsRect(itemFrame, rect))
//        {
//            attr = [self layoutAttributesForItemAtIndexPath:idxPath];
//            [attrs addObject:attr];
//        }
//    }];
//    
//    return attrs;
//}

@end
