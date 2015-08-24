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
#import "ImagePicker.h"
#import "UIActionSheet+Blocks.h"
@interface ProfileVCOwner () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,FetchCenterDelegate,UITextFieldDelegate,ImagePickerDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

@implementation ProfileVCOwner

- (void)setInfoForOwner{ //overwrite ! don't call super
    
    self.profileBackground.backgroundColor = [Theme profileBakground];
    NSString *newPicId = [User updatedProfilePictureId];
    [self.profilePicture setImageWithURL:[self.fetchCenter urlWithImageID:newPicId]
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.nickNameTextField.text = [User userDisplayName];
    self.genderLabel.text = [User gender];
    self.occupationTextField.text = [User occupation];
    self.descriptionTextView.text = [User personalDetailInfo];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell
}

#define giveup @"放弃"
#define confirm @"确认"
#define goback @"返回"
- (void)goBack{
    [super goBack];
    if (!self.nickNameTextField.hasText || [[self.nickNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [UIActionSheet showInView:self.tableView withTitle:@"姓名不能放空" cancelButtonTitle:@"好的" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"好的"]) {
                self.nickNameTextField.text = [User userDisplayName];
            }
        }];
    }else{
        if (![self.nickNameTextField.text isEqualToString:[User userDisplayName]] ||
            ![self.genderLabel.text isEqualToString:[User gender]] ||
            ![self.occupationTextField.text isEqualToString:[User occupation]] ||
            ![self.descriptionTextView.text isEqualToString:[User personalDetailInfo]]) {
            [UIActionSheet showInView:self.tableView
                            withTitle:@"是否确认修改个人信息？"
                    cancelButtonTitle:nil
               destructiveButtonTitle:confirm
                    otherButtonTitles:@[giveup,goback]
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                 NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
//                                 if ([title isEqualToString:giveup]) {
//                                     //放弃编辑
////                                     [self.navigationController popViewControllerAnimated:YES];
//                                 }
                                 if ([title isEqualToString:confirm]){
                                     //确认编辑
                                     [self uploadPersonalInfo];
                                 }
                                 if ([title isEqualToString:goback]){
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }
                             }];
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

#pragma mark - upload profile pic

- (IBAction)tapOnCamera:(UIButton *)sender{
    [ImagePicker startPickingImageFromLocalSourceFor:self];
}
 
- (void)didFinishPickingImage:(UIImage *)image{
//    [self showSpinniner];
    [self.fetchCenter uploadNewProfilePicture:image];
}
 
- (void)didFailPickingImage{
 
}

#pragma mark - fetch center delegate
- (void)didFinishSettingPersonalInfo{
//    [self dismissSpinner];
    NSURL *newUrl = [self.fetchCenter urlWithImageID:[User updatedProfilePictureId]];
    [self.profilePicture setImageWithURL:newUrl
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
//    [self handleFailure:info];
//}
// 
//- (void)didFinishUploadingPictureForProfile:(NSDictionary *)info{
//    [self uploadPersonalInfo];
//}
// 
- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self.navigationController popViewControllerAnimated:YES];
    [self handleFailure:info];
}
 
- (void)handleFailure:(NSDictionary *)info{
//    [self dismissSpinner];
//    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
//                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
//                               delegate:self
//                      cancelButtonTitle:@"OK"
//                      otherButtonTitles:nil, nil] show];
}
 
//#pragma mark - activity
// 
//- (void)showSpinniner{
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
//    [spinner startAnimating];
//}
// 
//- (void)dismissSpinner{
//    self.navigationItem.rightBarButtonItem = nil;
//}
//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0) {
        // down
        [self dismissKeyboard];
    }
}
@end
