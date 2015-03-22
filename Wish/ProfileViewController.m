//
//  ProfileViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-22.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ProfileViewController.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "NavigationBar.h"
@interface ProfileViewController ()
@property (nonatomic,weak) IBOutlet UIView *profileBackground;

@end

@implementation ProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupProfileBanner];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"个人资料";
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.backgroundColor = [Theme naviBackground];
    [self setNavBarText:[UIColor blackColor]];
}


- (void)setupProfileBanner{
    self.profileBackground.backgroundColor = [Theme profileBakground];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navWhiteButtonDefault]
                                     target:self.navigationController
                                   selector:@selector(popViewControllerAnimated:)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self setNavBarText:[UIColor whiteColor]];
    
}

- (void)setNavBarText:(UIColor *)color{
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName :color}];
}
@end
