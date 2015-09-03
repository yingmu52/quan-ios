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
        NSURL *imageUrl = [[FetchCenter new] urlWithImageID:self.owner.headUrl size:FetchCenterImageSize50];
        [self.profilePicture showImageWithImageUrl:imageUrl];
        self.nickNameTextField.text = self.owner.ownerName;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setInfoForOwner];
}

- (void)goBack{
    [self dismissKeyboard];
//    [self.navigationController popViewControllerAnimated:YES];
//    NavigationBar *navBar = (NavigationBar *)self.navigationController.navigationBar;
//    [navBar showDefaultTextColor];
//    [navBar showDefaultBackground];
}

- (void)dismissKeyboard{
    if (self.nickNameTextField.isFirstResponder) {
        [self.nickNameTextField resignFirstResponder];
    }else if (self.occupationTextField.isFirstResponder){
        [self.occupationTextField resignFirstResponder];
    }else if (self.descriptionTextView.isFirstResponder){
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                     target:self
                                   selector:@selector(goBack)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.title = @"个人资料";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (indexPath.row != 3){
            return 104.0f / 1136 * tableView.frame.size.height;
        }else{
            return 300.0f / 1136 * tableView.frame.size.height;
        }
        
    }else{
        return 0.0f;
    }
    
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









