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
#import "DiscoveryBannerCell.h"
//#import "HMSegmentedControl.h"
@interface DiscoveryViewController () <CHTCollectionViewDelegateWaterfallLayout>
//@property (nonatomic,strong) UIColor *navigationSeparatorColor;
@end
@implementation DiscoveryViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWaterFallCollectionView];
}
- (void)setupWaterFallCollectionView{
    
    //set water fall layout
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    CGFloat horizontalInset = 16.0/640 * CGRectGetWidth([UIScreen mainScreen].bounds);
    layout.sectionInset = UIEdgeInsetsMake(horizontalInset, horizontalInset, horizontalInset, horizontalInset);
    //    layout.footerHeight = 550.0/1136*self.collectionView.frame.size.height; //banner height
    layout.minimumColumnSpacing = 14.0/16*horizontalInset;
    layout.minimumInteritemSpacing = 12.0/16*horizontalInset;
    
    //Render的方向会影响UI，必须和 sizeForItemAtIndexPath 对应
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    self.collectionView.collectionViewLayout = layout;
    
    
    //register footer view
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"DiscoveryFooterView"
    //                                                    bundle:[NSBundle mainBundle]]
    //          forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
    //                 withReuseIdentifier:BANNERID];
}
#pragma mark <UICollectionViewDataSource>
- (DiscoveryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscoveryCell *cell = (DiscoveryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NORMALCELLID forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    // Configure the cell
    return cell;
}
- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    //abstract
}
//- (DiscoveryBannerCell *)collectionView:(UICollectionView *)collectionView
//      viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    DiscoveryBannerCell *banner = nil;
////    if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
////        banner = (DiscoveryBannerCell *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
////                                                          withReuseIdentifier:BANNERID
////                                                                 forIndexPath:indexPath];
////    }
//
//    return banner;
//}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeZero;
    
    CGFloat width = 298.0 * 0.5;
    
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