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
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

static CGFloat horizontalInset = 10.0f;

- (void)setupWaterFallCollectionView{
    
    //set water fall layout
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(horizontalInset, horizontalInset, horizontalInset, horizontalInset);
    //    layout.footerHeight = 550.0/1136*self.collectionView.frame.size.height; //banner height
    layout.minimumColumnSpacing = horizontalInset;
    layout.minimumInteritemSpacing = horizontalInset;
    
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

//#pragma mark - Scroll view delegate (Add Button Animation)
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    self.lastContentOffSet = scrollView.contentOffset.y;
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (self.lastContentOffSet < scrollView.contentOffset.y) {
//        //hide camera
//        if (self.addButton.isUserInteractionEnabled) [self animateCameraIcon:YES];
//        
//    }else if (self.lastContentOffSet > scrollView.contentOffset.y) {
//        //show camera
//        if (!self.addButton.isUserInteractionEnabled) [self animateCameraIcon:NO];
//    }
//    
//}
//
//- (void)animateCameraIcon:(BOOL)shouldHideCamera{
////    CGFloat movingDistance = CGRectGetHeight(self.view.frame) * 0.5f;
//    self.addButton.userInteractionEnabled = !shouldHideCamera;
//    if (shouldHideCamera){
////        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        [UIView animateWithDuration:0.5 animations:^{
//            self.addButton.alpha = 0.0f;
////            self.addButton.center = CGPointMake(self.addButton.center.x,self.addButton.center.y + movingDistance);
////            self.navigationController.navigationBar.alpha = 0;
//        }];
//    }else{
////        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        [UIView animateWithDuration:0.5 animations:^{
//            self.addButton.alpha = 1.0f;
////            self.addButton.center = CGPointMake(self.addButton.center.x,self.addButton.center.y - movingDistance);
////            self.navigationController.navigationBar.alpha = 1;
//        }];
//    }
//}
//- (void)loaddAddButton{
//    //读取加号按扭
//    UIImage *icon = [Theme discoveryAddButton];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:icon forState:UIControlStateNormal];
//    button.hidden = NO;
//    UIWindow *topView = [[UIApplication sharedApplication] keyWindow];
//    CGFloat trailing = 15;
//    CGFloat bottom = self.tabBarController.tabBar.frame.size.height;
//    CGFloat side = 65.0f;
//    [button setFrame:CGRectMake(topView.frame.size.width - trailing - side,topView.frame.size.height - bottom - side,side,side)];
//    [topView addSubview:button];
//    [button addTarget:self action:@selector(addWish) forControlEvents:UIControlEventTouchUpInside];
//    self.addButton = button;
//}
//
//- (void)addWish{
//    [self performSegueWithIdentifier:@"showPostViewFromDiscovery" sender:nil];
//}
//
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self loaddAddButton];
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [self.addButton removeFromSuperview];
//}


@end