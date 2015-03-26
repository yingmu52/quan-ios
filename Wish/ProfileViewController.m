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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FetchCenter.h"
#import "User.h"
@interface ProfileViewController ()
@property (nonatomic,weak) IBOutlet UIView *profileBackground;
@property (nonatomic,weak) IBOutlet UIImageView *profilePicture;
@property (nonatomic,weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *genderLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupProfileBanner];
    [self setupInfoSection];
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
    [self.profilePicture setImageWithURL:[User userProfilePictureURL]
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

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


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0){
        return 58.0f / 1136 * tableView.frame.size.height;
    }else{
        return 470.0f / 1136 * tableView.frame.size.height;
    };
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 400.0f / 1136 * tableView.frame.size.height;
    }else if (indexPath.section == 1){
        return 104.0f / 1136 * tableView.frame.size.height;
    }else{
        return 0.0f;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 0;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}



- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.backgroundColor = [SystemUtil colorFromHexString:@"#E7F0ED"];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [SystemUtil colorFromHexString:@"#F6FAF9"];
    
}


#pragma mark - functionality
- (void)setupInfoSection{
    self.nickNameLabel.text = [User userDisplayName];
    self.genderLabel.text = [User gender];
}
@end









