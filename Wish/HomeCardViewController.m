//
//  HomeCardViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardViewController.h"
@interface HomeCardViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation HomeCardViewController

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPat{
    CGSize size = CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
    return size;
}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)aCollectionView
//                        layout:(UICollectionViewFlowLayout *)aCollectionViewLayout
//        insetForSectionAtIndex:(NSInteger)aSection
//{
//    // top, left, bottom, right
//    UIEdgeInsets myInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    return myInsets;
//}


- (HomeCardView *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)anIndexPath
{
    HomeCardView *appropriateCell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"HomeCardCell" forIndexPath:anIndexPath];
    [self configureCollectionViewCell:appropriateCell atIndexPath:anIndexPath];
    return appropriateCell;
}

- (void)configureCollectionViewCell:(HomeCardView *)cell atIndexPath:(NSIndexPath *)indexPath{
    //abstract
}
@end
