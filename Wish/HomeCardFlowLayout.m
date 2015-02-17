//
//  HomeCardFlowLayout.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardFlowLayout.h"
#define SPACING_BETWEEN_CELLS 10.0;

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
    CGSize collectionViewSize = self.collectionView.bounds.size;
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + self.collectionView.bounds.size.width * 0.5f;
    CGRect proposedRect = self.collectionView.bounds;
    // Comment out if you want the collectionview simply stop at the center of an item while scrolling freely
     proposedRect = CGRectMake(proposedContentOffset.x, 0.0, collectionViewSize.width, collectionViewSize.height);
    
    UICollectionViewLayoutAttributes* candidateAttributes;
    for (UICollectionViewLayoutAttributes* attributes in [self layoutAttributesForElementsInRect:proposedRect])
    {
        
        // == Skip comparison with non-cell items (headers and footers) == //
        if (attributes.representedElementCategory != UICollectionElementCategoryCell) continue;

        // == First time in the loop == //
        if(!candidateAttributes){
            candidateAttributes = attributes;
            continue;
        }
        if (fabsf(attributes.center.x - proposedContentOffsetCenterX) < fabsf(candidateAttributes.center.x - proposedContentOffsetCenterX)){
            candidateAttributes = attributes;
        }
    }
    return CGPointMake(candidateAttributes.center.x - self.collectionView.bounds.size.width * 0.5f, proposedContentOffset.y);
    
}


@end
