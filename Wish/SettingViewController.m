//
//  SettingViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
}
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(dismissModalViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
}

@end
