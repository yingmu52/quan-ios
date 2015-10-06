//
//  ProfileVCOwner.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-06.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ProfileVCOwner.h"
#import "NavigationBar.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "UIActionSheet+Blocks.h"
@interface ProfileVCOwner () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,FetchCenterDelegate,UITextFieldDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

@implementation ProfileVCOwner

- (void)setInfoForOwner{ //overwrite ! don't call super
    self.nickNameTextField.text = [User userDisplayName];
    self.genderLabel.text = [User gender];
    self.occupationTextField.text = [User occupation];
    self.descriptionTextView.text = [User personalDetailInfo];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell
}

- (void)goBack{
    [super goBack];
    if (!self.nickNameTextField.hasText || [[self.nickNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"姓名不能放空" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.nickNameTextField.text = [User userDisplayName];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        if (![self.nickNameTextField.text isEqualToString:[User userDisplayName]] ||
            ![self.genderLabel.text isEqualToString:[User gender]] ||
            ![self.occupationTextField.text isEqualToString:[User occupation]] ||
            ![self.descriptionTextView.text isEqualToString:[User personalDetailInfo]]) {
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"是否确认修改个人信息？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self uploadPersonalInfo];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [actionSheet addAction:confirm];
            [actionSheet addAction:cancel];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
        
    }
    return _fetchCenter;
}

#pragma mark - functionality


- (void)uploadPersonalInfo{
    [self.fetchCenter setPersonalInfo:self.nickNameTextField.text
                               gender:self.genderLabel.text
                              imageId:[User updatedProfilePictureId]
                           occupation:self.occupationTextField.text
                         personalInfo:self.descriptionTextView.text];
}
 
#pragma mark - update info

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        [self.nickNameTextField becomeFirstResponder];
    }
    if (indexPath.row == 1){
        self.genderLabel.text = [self.genderLabel.text isEqualToString:@"男"] ? @"女" : @"男";
    }
    [self dismissKeyboard];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissKeyboard];
}

#pragma mark - fetch center delegate
- (void)didFinishSettingPersonalInfo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0) {
        // down
        [self dismissKeyboard];
    }
}
@end
