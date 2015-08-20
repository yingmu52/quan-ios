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
#import "HMSegmentedControl.h"

@interface DiscoveryViewController () <CHTCollectionViewDelegateWaterfallLayout>
@property (nonatomic,strong) UIColor *navigationSeparatorColor;
@end

@implementation DiscoveryViewController

- (UIColor *)navigationSeparatorColor{
    if (!_navigationSeparatorColor){
        _navigationSeparatorColor = [SystemUtil colorFromHexString:@"#32C9A9"];
    }
    return _navigationSeparatorColor;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //设置导航分隔线的颜色
    UIImage *shadow = [SystemUtil imageFromColor:self.navigationSeparatorColor
                                            size:CGSizeMake(CGRectGetWidth(self.view.frame), 2)];
    [self.navigationController.navigationBar setShadowImage:shadow];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWaterFallCollectionView];
    
    //在导航添加选项卡
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"我的关注", @"发现"]];

    NSDictionary *normalAttribute = self.navigationController.navigationBar.titleTextAttributes;
    NSDictionary *selectedAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0],
                               NSForegroundColorAttributeName:self.navigationSeparatorColor};
    segmentedControl.titleTextAttributes = normal;
    
    segmentedControl.frame = CGRectMake(0,0,0.8 * CGRectGetWidth(self.view.frame),CGRectGetHeight(self.navigationController.navigationBar.frame));
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.userDraggable = YES;
    segmentedControl.selectionIndicatorColor = self.navigationSeparatorColor;
    [segmentedControl addTarget:self action:@selector(switchSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    
    //选中项颜色
    [segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        if (index == segmentedControl.selectedSegmentIndex) { //选中态颜色
            return [[NSAttributedString alloc] initWithString:title attributes:selectedAttribute];
        }else{ //常态颜色
            return [[NSAttributedString alloc] initWithString:title attributes:normalAttribute];;
        }
        
    }];
    self.navigationItem.titleView = segmentedControl;
}

- (void)switchSegmentedControl:(HMSegmentedControl *)control{
    //abstract
}

- (void)setupWaterFallCollectionView{
    
    //set water fall layout
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    CGFloat horizontalInset = 16.0/640 * self.collectionView.frame.size.width;
    layout.sectionInset = UIEdgeInsetsMake(horizontalInset, horizontalInset, horizontalInset, horizontalInset);
//    layout.footerHeight = 550.0/1136*self.collectionView.frame.size.height; //banner height
    layout.minimumColumnSpacing = 14.0/16*horizontalInset;
    layout.minimumInteritemSpacing = 12.0/16*horizontalInset;
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
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
    CGFloat width = 298.0/640*collectionView.frame.size.width;
    
    NSInteger num = ( indexPath.row + 1 ) % 4;
    if (num == 2 || num == 3){
        //odd number
        cellSize = CGSizeMake(width,480.0/1136*collectionView.frame.size.height);
    }else if (num == 1 || num == 0){
        //even number
        cellSize = CGSizeMake(width,556.0/1136*collectionView.frame.size.height);
    }
    return cellSize;
}

@end
