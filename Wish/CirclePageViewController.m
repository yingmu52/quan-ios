//
//  CirclePageViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/27/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CirclePageViewController.h"
#import "HMSegmentedControl.h"
#import "Theme.h"

@interface CirclePageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (nonatomic,strong) HMSegmentedControl *segmentedControl;
@property (nonatomic,strong) NSArray *circleControllers;
@end

@implementation CirclePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar addSubview:self.segmentedControl];
    [self setViewControllers:@[self.circleControllers.firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
    self.delegate = self;
    self.dataSource = self;
    self.view.backgroundColor = [SystemUtil colorFromHexString:@"#F4F8F7"];
}

- (NSArray *)circleControllers{
    if (!_circleControllers) {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"Circle" bundle:nil];
        UIViewController *circleListVC = [s instantiateViewControllerWithIdentifier:@"CircleListViewController"];
        UIViewController *followingCircleVC = [s instantiateViewControllerWithIdentifier:@"FollowingCirclesViewController"];
        _circleControllers = @[circleListVC,followingCircleVC];
    }
    return _circleControllers;
}

- (HMSegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"我加入的", @"我关注的"]];
        _segmentedControl.backgroundColor = [UIColor clearColor];
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        
        UIColor *textColor = [SystemUtil colorFromHexString:@"#1F2124"];
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : textColor,
                                                  NSFontAttributeName: [UIFont systemFontOfSize:16]};
        _segmentedControl.selectionIndicatorColor = [Theme globleColor];
        
        CGRect navRect = self.navigationController.navigationBar.frame;
        CGFloat width = CGRectGetWidth(navRect) * 0.66;
        CGFloat height = CGRectGetHeight(navRect);
        CGFloat x = (CGRectGetWidth(navRect) - width) * 0.5;
        CGFloat y = CGRectGetHeight(navRect) - height;
        _segmentedControl.frame = CGRectMake(x, y, width, height);
        
        __weak typeof(self) weakSelf = self;
        [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
            if (index == 0) {
                [weakSelf setViewControllers:@[weakSelf.circleControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
            }else{
                [weakSelf setViewControllers:@[weakSelf.circleControllers.lastObject] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            }
        }];
    }
    return _segmentedControl;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.segmentedControl.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.segmentedControl.hidden = NO;
}

#pragma mark - page view controller delegate and data source 

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(UIViewController *)viewController{
    if (viewController == self.circleControllers.lastObject) {
        return self.circleControllers.firstObject;
    }else{
        return nil;
    }
    
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(UIViewController *)viewController{
    if (viewController == self.circleControllers.firstObject) {
        return self.circleControllers.lastObject;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    NSUInteger index = [self.circleControllers indexOfObject:pendingViewControllers.lastObject];
    [self.segmentedControl setSelectedSegmentIndex:index animated:YES];
}

@end
