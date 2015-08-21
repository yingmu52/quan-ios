//
//  FollowingTableViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "Theme.h"
#import "FollowingCell.h"
@interface FollowingTableViewController ()
//@property (nonatomic,weak) IBOutlet UIView *footerView;
//@property (nonatomic,weak) IBOutlet UIImageView *loadMoreButton;
@end

@implementation FollowingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [Theme homeBackground];
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
    return 572.0 * 0.5;
}


@end
