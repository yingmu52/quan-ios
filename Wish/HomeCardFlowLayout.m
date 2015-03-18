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

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
    } else {
        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
    }
    
    return proposedContentOffset;
}

- (CGFloat)flickVelocity {
    return 0.3;
}

@end
