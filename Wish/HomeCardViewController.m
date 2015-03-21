//
//  HomeCardViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardViewController.h"

@interface HomeCardViewController ()
@end

@implementation HomeCardViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupCollectionView];
}
- (void)setupCollectionView{
    UINib *myNib = [UINib nibWithNibName:@"HomeCardView" bundle:nil];
    
    // All new cells will be created from this one
    [self.collectionView registerNib:myNib forCellWithReuseIdentifier:@"HomeCardCell"];
    
    // By turning off clipping, you'll see the prior and next items.
    self.collectionView.clipsToBounds = NO;
    
    // the next two line of code is so mother fucking important !!!!!
    [self.collectionView layoutIfNeeded];
    
    UICollectionViewFlowLayout *myLayout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat margin = ((self.view.frame.size.width - self.collectionView.frame.size.width) / 2);
    
    // This assumes that the the collectionView is centered withing its parent view.
//    myLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width + margin,self.collectionView.frame.size.height);
    
    // A negative margin will shift each item to the left.
    myLayout.minimumLineSpacing = -margin;
    
    myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.collectionView setCollectionViewLayout:myLayout];

    self.collectionView.pagingEnabled = YES;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat margin = ((self.view.frame.size.width - self.collectionView.frame.size.width) / 2);
    return  CGSizeMake(self.collectionView.frame.size.width + margin, self.view.frame.size.height * 890.0f / 1136);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)aCollectionView
                        layout:(UICollectionViewFlowLayout *)aCollectionViewLayout
        insetForSectionAtIndex:(NSInteger)aSection
{
    CGFloat margin = (aCollectionViewLayout.minimumLineSpacing * 0.5f);
    
    // top, left, bottom, right
    UIEdgeInsets myInsets = UIEdgeInsetsMake(0, margin, 0, margin);
    
    return myInsets;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)anIndexPath
{
    UICollectionViewCell *appropriateCell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"HomeCardCell" forIndexPath:anIndexPath];
    [self configureCollectionViewCell:appropriateCell atIndexPath:anIndexPath];
    return appropriateCell;
}

- (void)configureCollectionViewCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    //abstract
}
@end
