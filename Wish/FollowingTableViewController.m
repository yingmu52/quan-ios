//
//  FollowingTableViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "Theme.h"
//#import "UIViewController+ECSlidingViewController.h"
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
//    CGRect frame = CGRectMake(0,0, 25,25);
//    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
//                                        target:self.slidingViewController
//                                      selector:@selector(anchorTopViewToRightAnimated:)
//                                         frame:frame];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
}

#pragma mark - Table view data source


- (FollowingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingCell" forIndexPath:indexPath];
    [self configureFollowingCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureFollowingCell:(FollowingCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    //abstract
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 572.0/1136.0*self.tableView.bounds.size.height;
}



@end
