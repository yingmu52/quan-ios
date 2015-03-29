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
@interface ProfileViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,FetchCenterDelegate,UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UIView *profileBackground;
@property (nonatomic,weak) IBOutlet UIImageView *profilePicture;
@property (nonatomic,weak) IBOutlet UITextField *nickNameTextField;
@property (nonatomic,weak) IBOutlet UILabel *genderLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupProfileBanner];
    [self setupInfoSection];
}

- (void)setupProfileBanner{
    self.profileBackground.backgroundColor = [Theme profileBakground];
    
    if ([User isUserLogin]) {
        NSString *newPicId = [User updatedProfilePictureId];
        NSURL *url = [newPicId isEqualToString:@""] ? [User userProfilePictureURL] : [[FetchCenter new] urlWithImageID:newPicId];
        [self.profilePicture setImageWithURL:url
                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }


}

- (void)gobackToSettingView{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBar.backgroundColor = [Theme naviBackground];
    [self setNavBarText:[UIColor blackColor]];
    
    
    //updae info if needed
    if (![self.nickNameTextField.text isEqualToString:[User userDisplayName]] ||
        ![self.genderLabel.text isEqualToString:[User gender]]){

    }

}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navWhiteButtonDefault]
                                     target:self
                                   selector:@selector(gobackToSettingView)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self setNavBarText:[UIColor whiteColor]];

    self.title = @"个人资料";

}

- (void)setNavBarText:(UIColor *)color{
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName :color}];
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
    self.nickNameTextField.text = [User userDisplayName];
    self.genderLabel.text = [User gender];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell
}


#pragma mark - update info
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0){
            [self.nickNameTextField becomeFirstResponder];
        }
        if (indexPath.row == 1){
            self.genderLabel.text = [self.genderLabel.text isEqualToString:@"男"] ? @"女" : @"男";
        }
    }
    [self dismissKeyboardIfNeed];
}

- (void)dismissKeyboardIfNeed{
    if (self.nickNameTextField.isFirstResponder){
        [self.nickNameTextField resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissKeyboardIfNeed];
}

#pragma mark - upload profile pic
- (IBAction)tapOnCamera:(UIButton *)sender{
    UIImagePickerController *controller = [SystemUtil showCamera:self];
    if (controller) {
        [self presentViewController:controller animated:YES completion:nil];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        UIImage *capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
        //NSLog(@"%@",NSStringFromCGSize(editedImage.size));
        FetchCenter *fc = [[FetchCenter alloc] init];
        fc.delegate = self;
        [fc uploadNewProfilePicture:capturedImage];
    }];
}


- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    NSLog(@"fail");
}

- (void)didFinishUploadingPictureForProfile:(NSDictionary *)info{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *newUrl = [[FetchCenter new] urlWithImageID:[User updatedProfilePictureId]];
        [self.profilePicture setImageWithURL:newUrl
                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    });
}

@end









