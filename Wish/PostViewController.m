//
//  PostViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostViewController.h"
#import "Theme.h"
@interface PostViewController ()

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    UIButton *doneButton = [Theme buttonWithImage:[Theme navComposeButtonDefault]
                                           target:self
                                         selector:nil
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];

}

@end
