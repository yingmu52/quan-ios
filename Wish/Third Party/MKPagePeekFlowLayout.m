//
//  MKPagePeekFlowLayout.m
//  pagePeekingCollectionView
//
//  Created by Mayank Kumar on 4/2/14.
//  Copyright (c) 2014 Mayank. All rights reserved.
//

#define SPACING_BETWEEN_CELLS 10.0
#define MIN_SWIPE_DISTANCE_TO_PAGE 20.0

#import "MKPagePeekFlowLayout.h"

@interface MKPagePeekFlowLayout ()
@end

@implementation MKPagePeekFlowLayout


- (void)prepareLayout {
    self.itemSize = CGSizeMake(self.collectionView.frame.size.width - 2*SPACING_BETWEEN_CELLS,
                               self.collectionView.frame.size.height - 2*SPACING_BETWEEN_CELLS);

    self.sectionInset = UIEdgeInsetsMake(0, 0, 0,0);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = SPACING_BETWEEN_CELLS;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = CGFLOAT_MAX;
    CGFloat horizontalCenter = proposedContentOffset.x
    + self.collectionView.frame.size.width/2 + self.sectionInset.left;
    
    CGRect visibleRect = CGRectMake(proposedContentOffset.x, 0.0f,
                                    self.collectionView.bounds.size.width,
                                    self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:visibleRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat distanceFromCenter = layoutAttributes.center.x - horizontalCenter;
        if (fabsf(distanceFromCenter) < fabsf(offsetAdjustment)) {
            offsetAdjustment = distanceFromCenter;
        }
    }
    
    CGFloat currentCardLeftX = proposedContentOffset.x  + offsetAdjustment;
    CGFloat swipeDistance = offsetAdjustment+self.sectionInset.left;
    CGFloat newCardLeftX;
    if (velocity.x == 0) {
        newCardLeftX = currentCardLeftX;
        CGFloat newOffset = newCardLeftX+self.sectionInset.left;
        if (newOffset<0) {
            newOffset = 0;
        }
        return CGPointMake(newOffset, proposedContentOffset.y);
    } else {
        if (swipeDistance < -MIN_SWIPE_DISTANCE_TO_PAGE) {
            //Moving right (swiping left) move to the next cell
            newCardLeftX = currentCardLeftX+self.itemSize.width+self.minimumLineSpacing;
        } else if (swipeDistance > MIN_SWIPE_DISTANCE_TO_PAGE) {
            //Moving left (swiping right) move to the previous cell
            newCardLeftX = currentCardLeftX-self.itemSize.width-self.minimumLineSpacing;
        } else {
            //Stay on the current cell (based on the proposed content offset)
            newCardLeftX = currentCardLeftX;
        }
        CGFloat newOffset = newCardLeftX+self.sectionInset.left;
        if (newOffset<0) {
            newOffset = 0;
        }
        return CGPointMake(newOffset, proposedContentOffset.y);
    }
}



@end
