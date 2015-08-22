//
//  NewsPageViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "NewsPageViewController.h"
#import "HMSegmentedControl.h"
#import "SystemUtil.h"
#import "DiscoveryVCData.h"
#import "FollowingTVCData.h"
@interface NewsPageViewController()
@property (nonatomic,strong) UIColor *navigationSeparatorColor;
@property (nonatomic,strong) DiscoveryVCData *discoveryVC;
@property (nonatomic,strong) FollowingTVCData *followingVC;
@end
@implementation NewsPageViewController


#pragma mark - 设置PageViewController

- (DiscoveryVCData *)discoveryVC{
    if (!_discoveryVC) {
        _discoveryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DiscoveryVCData"];
    }
    return _discoveryVC;
}

- (FollowingTVCData *)followingVC{
    if (!_followingVC){
        _followingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowingTVCData"];
    }
    return _followingVC;
}

#pragma mark - 设置导航选项卡
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
    
    //背影图
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    //设置PageViewController
    [self showController:self.followingVC];
    
    //防止视图进入导航后面
    self.edgesForExtendedLayout = UIRectEdgeNone;
    

}

- (void)showController:(UIViewController *)viewController{
    [self setViewControllers:@[viewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)switchSegmentedControl:(HMSegmentedControl *)control{
    if (control.selectedSegmentIndex == 0) {
        [self showController:self.followingVC];
    }else if (control.selectedSegmentIndex == 1){
        [self showController:self.discoveryVC];
    }
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [viewController isKindOfClass:[DiscoveryVCData class]] ? self.followingVC : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return [viewController isKindOfClass:[FollowingTVCData class]] ? self.discoveryVC : nil;
}
@end
