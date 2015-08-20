//
//  ProfileViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-22.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ProfileViewController.h"
#import "NavigationBar.h"

@interface ProfileViewController () 
@end

@implementation ProfileViewController

- (void)setInfoForOwner{
    if (self.owner) {
        if (self.owner.image) {
            self.profilePicture.image = self.owner.image;
        }else{
            [self.profilePicture setImageWithURL:[[FetchCenter new] urlWithImageID:self.owner.headUrl]
                     usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        self.nickNameTextField.text = self.owner.ownerName;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setInfoForOwner];
    self.tableView.scrollEnabled = NO;
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
//    NavigationBar *navBar = (NavigationBar *)self.navigationController.navigationBar;
//    [navBar showDefaultTextColor];
//    [navBar showDefaultBackground];
}


- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navWhiteButtonDefault]
                                     target:self
                                   selector:@selector(goBack)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
//    NavigationBar *navBar = (NavigationBar *)self.navigationController.navigationBar;
//    [navBar showClearBackground];
//    [navBar showTextWithColor:[UIColor whiteColor]];
    self.title = @"个人资料";
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0){
        return 58.0f / 1136 * tableView.frame.size.height;
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 400.0f / 1136 * tableView.frame.size.height;
    }else if (indexPath.section == 1){
        if (indexPath.row != 3){
            return 104.0f / 1136 * tableView.frame.size.height;
        }else{
            return 300.0f / 1136 * tableView.frame.size.height;
        }
        
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


@end









