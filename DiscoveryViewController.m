//
//  DiscoveryViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-17.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "Theme.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "DiscoveryBannerCell.h"
#import "DiscoveryCell.h"
@interface DiscoveryViewController () <CHTCollectionViewDelegateWaterfallLayout>

@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupWaterFallCollectionView];
}

- (void)setupWaterFallCollectionView{
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    CGFloat horizontalInset = 16.0/640 * self.collectionView.frame.size.width;
    layout.sectionInset = UIEdgeInsetsMake(horizontalInset, horizontalInset, horizontalInset, horizontalInset);
    layout.footerHeight = 550.0/1136*self.collectionView.frame.size.height;
    layout.minimumColumnSpacing = 14.0/16*horizontalInset;
    layout.minimumInteritemSpacing = 12.0/16*horizontalInset;
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView registerClass:[DiscoveryBannerCell class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:@"DiscoveryOffcialBanner"];

}
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self.slidingViewController
                                      selector:@selector(anchorTopViewToRightAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
}

#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (DiscoveryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscoveryCell *cell = (DiscoveryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DiscoveryCell" forIndexPath:indexPath];
    
    // Configure the cell
    return cell;
}


- (DiscoveryBannerCell *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DiscoveryBannerCell *reusableView = nil;
    if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"DiscoveryOffcialBanner"
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor orangeColor];
    }
    return reusableView;
}


#pragma mark - CHTCollectionViewDelegateWaterfallLayout
    
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeZero;
    CGFloat width = 298.0/640*collectionView.frame.size.width;
    if (indexPath.row == 1 || indexPath.row == 2) {
        cellSize = CGSizeMake(width,480.0/1136*collectionView.frame.size.height);
    }else if (indexPath.row == 0 || indexPath.row == 3){
        cellSize = CGSizeMake(width,556.0/1136*collectionView.frame.size.height);
    }
    return cellSize;
}

#pragma mark <UICollectionViewDelegate>

@end
