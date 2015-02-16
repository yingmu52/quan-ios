//
//  FollowingTableViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "Theme.h"
#import "UIViewController+ECSlidingViewController.h"
#import "FollowingCell.h"

@interface FollowingTableViewController ()
@property (nonatomic,weak) IBOutlet UIView *footerView;
@property (nonatomic,weak) IBOutlet UIImageView *loadMoreButton;
@end

@implementation FollowingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.tableView.backgroundColor = [Theme homeBackground];
    
}

- (void)setFooterView:(UIView *)footerView{
    _footerView = footerView;
    _footerView.backgroundColor = footerView.superview.backgroundColor;
    CGRect frame = _footerView.frame;
    frame.size.height = (80+44*2)/1136.0 * footerView.superview.bounds.size.height;
    _footerView.frame = frame;
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self.slidingViewController
                                      selector:@selector(anchorTopViewToRightAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
}

#pragma mark - Table view data source

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 2*90.0/1136.0*self.tableView.bounds.size.height)];
//    footerView.backgroundColor = [UIColor clearColor];
//    
//    CGFloat x = 58.0/640.0*footerView.frame.size.width;
//    CGFloat y = 44.0/1136.0*self.view.bounds.size.height;
//    CGRect btnFrame = CGRectMake(x,y, self.view.bounds.size.width - 2*x, 0.66*footerView.frame.size.height);
//    UIButton *loadMore = [UIButton buttonWithType:UIButtonTypeCustom];
//    loadMore.frame = btnFrame;
//    loadMore.titleLabel.text = @"再来点新鲜的";
//    [footerView addSubview:loadMore];
//    return footerView;
//
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 10;
}


- (FollowingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingCell" forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 572.0/1136.0*self.tableView.bounds.size.height;
}



@end
