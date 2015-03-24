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

//- (void)viewDidLayoutSubviews{
//    [super viewDidLayoutSubviews];
//    [self setupCollectionView];
//    [self.view layoutSubviews];
//}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    // By turning off clipping, you'll see the prior and next items.
//    self.collectionView.clipsToBounds = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];

}
//- (void)setupCollectionView{
//    
//    // the next two line of code is so mother fucking important !!!!!
////    [self.collectionView layoutIfNeeded];
//    
//    UICollectionViewFlowLayout *myLayout = [[UICollectionViewFlowLayout alloc] init];
//    
//    CGFloat margin = ((self.view.frame.size.width - self.collectionView.frame.size.width) / 2);
//    
//    // This assumes that the the collectionView is centered withing its parent view.
//    myLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width + margin,self.collectionView.frame.size.height);
//    
//    // A negative margin will shift each item to the left.
//    myLayout.minimumLineSpacing = -margin;
//    
//    myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    
//    myLayout.sectionInset = UIEdgeInsetsMake(0, -0.5f * margin, 0, -0.5f * margin);
//    [self.collectionView setCollectionViewLayout:myLayout];
//    
//}

//- (CGFloat)margin{
//    [self.view layoutSubviews];
////    return 26.0f / 640 * self.view.frame.size.width;
//    return 0.5f * (self.view.frame.size.width - self.collectionView.frame.size.width);
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    return -[self margin];
//}
//
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

//    CGSize size = CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
    CGSize size = CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
    return size;
}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)aCollectionView
//                        layout:(UICollectionViewFlowLayout *)aCollectionViewLayout
//        insetForSectionAtIndex:(NSInteger)aSection
//{
//    CGFloat margin = -0.5f * [self margin];
//    
//    // top, left, bottom, right
//    UIEdgeInsets myInsets = UIEdgeInsetsMake(0, margin, 0, margin);
//    
//    return myInsets;
//}
//

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
