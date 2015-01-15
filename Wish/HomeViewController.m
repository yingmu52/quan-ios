//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeViewController.h"
#import "UINavigationItem+CustomItem.h"
#import "CustomBarItem.h"
#import "Theme.h"
#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface HomeViewController ()

@property  (nonatomic,weak) CustomBarItem *menuButton;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    
    self.menuButton = [self.navigationItem setItemWithImage:[Theme navMenuDefault]
                                                       size:CGSizeMake(30, 30)
                                                   itemType:left];
    [self.menuButton addTarget:self
                      selector:@selector(menuButtonPressed)
                         event:UIControlEventTouchUpInside];
//    MenuViewController *menuVC = (MenuViewController *)self.slidingViewController.underLeftViewController;
//    [self.menuButton addTarget:self
//                      selector:@selector(openmenu)
//                         event:UIControlEventTouchUpInside];
//    [[UIApplication sharedApplication] keyWindow].rootViewController
//    [self.navigationItem setItemWithImage:@"nav-ic-tab-default" size:CGSizeMake(30, 30) itemType:left];
//    
//    CustomBarItem *centerItem = [self.navigationItem setItemWithTitle:@"中间的中间的中" textColor:[UIColor whiteColor] fontSize:19 itemType:center];
//    [centerItem addTarget:self selector:@selector(clickTitleView) event:(UIControlEventTouchUpInside)];
//    
//    CustomBarItem *rightItem = [self.navigationItem setItemWithTitle:@"右边右边" textColor:[UIColor whiteColor] fontSize:17 itemType:right];
//    [rightItem setOffset:10];//设置item偏移量(正值向左偏，负值向右偏)
    
    //[self setUpLeftNavigationItem];//多个item
}

- (void)menuButtonPressed{
    NSLog(@"test");
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
