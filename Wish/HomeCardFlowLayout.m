//
//  HomeCardFlowLayout.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardFlowLayout.h"
#define SPACING_BETWEEN_CELLS 0.0;

@implementation HomeCardFlowLayout


- (void)prepareLayout {
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0,0);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumInteritemSpacing = SPACING_BETWEEN_CELLS;
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
