//
//  AchieveViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AchieveViewController.h"
#import "AchieveCell.h"
#import "Theme.h"
#import "UIViewController+ECSlidingViewController.h"
#import "SystemUtil.h"
@interface AchieveViewController ()

@end

@implementation AchieveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    
    //add timeline to background
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView = view;
    UIView *timeLine = [[UIView alloc] initWithFrame:CGRectMake(view.bounds.origin.x + view.bounds.size.width * 170/640,0,
                                                                2,view.bounds.size.height)];
    timeLine.backgroundColor = [SystemUtil colorFromHexString:@"#33c7b7"];
    [view addSubview:timeLine];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self.slidingViewController
                                      selector:@selector(anchorTopViewToRightAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 444.0/1136*tableView.frame.size.height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (AchieveCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AchieveCell *cell = [tableView dequeueReusableCellWithIdentifier:ACHIEVECELLID
                                                            forIndexPath:indexPath];
//     Configure the cell...
    if (indexPath.row % 2 == 0) {
        cell.badgeImageView.image = [Theme achievementFail];
    }else{
        cell.badgeImageView.image = [Theme achievementFinish];
    }
    
    return cell;
}

@end
