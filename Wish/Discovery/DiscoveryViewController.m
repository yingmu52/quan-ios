//
//  DiscoveryViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-17.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//
#import "DiscoveryViewController.h"
#import "Theme.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "MainTabBarController.h"
#import "UIImageView+WebCache.h"
@interface DiscoveryViewController () <CHTCollectionViewDelegateWaterfallLayout>
//@property (nonatomic,strong) UIColor *navigationSeparatorColor;
@end
@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWaterFallCollectionView];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.navigationItem.title = @"发现";
}

static CGFloat horizontalInset = 10.0f;

- (void)setupWaterFallCollectionView{
    
    //set water fall layout
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(horizontalInset, horizontalInset, horizontalInset, horizontalInset);
    layout.minimumColumnSpacing = horizontalInset;
    layout.minimumInteritemSpacing = horizontalInset;
    
    //Render的方向会影响UI，必须和 sizeForItemAtIndexPath 对应
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    self.collectionView.collectionViewLayout = layout;
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; //or the number of sections you want
}

- (DiscoveryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscoveryCell *cell = (DiscoveryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NORMALCELLID forIndexPath:indexPath];
    [cell removeFromSuperview]; //修复卡片排版重叠
    [self configureCell:cell atIndexPath:indexPath];
    // Configure the cell
    return cell;
}
- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    //abstract
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeZero;
    CGFloat width = 290 * 0.5;
    
    NSInteger num = ( indexPath.row + 1 ) % 4;
    if (num == 2 || num == 3){
        //odd number
        cellSize = CGSizeMake(width,480.0 * 0.5);
    }else if (num == 1 || num == 0){
        //even number
        cellSize = CGSizeMake(width,556.0 * 0.5);
    }
    return cellSize;
}

@end





