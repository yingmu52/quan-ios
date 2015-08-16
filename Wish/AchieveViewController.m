//
//  AchieveViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AchieveViewController.h"
@implementation AchieveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];    
    self.title = @"已完结";
}

- (void)setUpNavigationItem
{
//    CGRect frame = CGRectMake(0,0, 25,25);
//    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
//                                        target:self.slidingViewController
//                                      selector:@selector(anchorTopViewToRightAnimated:)
//                                         frame:frame];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 444.0/1136*tableView.frame.size.height;
}

@end
