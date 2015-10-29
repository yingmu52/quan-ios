//
//  LoginDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-22.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "LoginDetailViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FetchCenter.h"
#import "User.h"
#import "Theme.h"
#import "GCPTextView.h"
@interface LoginDetailViewController () <FetchCenterDelegate,UITextFieldDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) UIButton *tikButton;

@property (nonatomic,weak) IBOutlet UITextField *nameTextField;
@property (nonatomic,weak) IBOutlet UITextField *occupationTextField;
@property (nonatomic,weak) IBOutlet UILabel *genderLabel;
@property (nonatomic,weak) IBOutlet GCPTextView *descriptionTextView;
@end
@implementation LoginDetailViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)setupNavigationItem{
    self.navigationController.navigationBar.hidden = NO;

    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(goBackToLogin)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                     target:self
                                   selector:@selector(uploadUserInfo)
                                      frame:frame];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
//    self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)goBackToLogin{
    [self.navigationController performSegueWithIdentifier:@"LoginDetailToLoginView" sender:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[User userProfilePictureURL]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             // progression tracking code
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                // do something with image
                                [self.fetchCenter uploadNewProfilePicture:image];
                            }
                        }];

    [self setupNavigationItem];
    
    [self.descriptionTextView setPlaceholder:@"描述下你是怎样的一个人？"];
    
    [self.nameTextField addTarget:self
                           action:@selector(textFieldDidUpdate)
                 forControlEvents:UIControlEventEditingChanged];
    
    self.nameTextField.text = [User userDisplayName];
    self.genderLabel.text = [User gender];

}


#pragma mark - new user registration

- (void)uploadUserInfo{
    //upload user info
    [self.fetchCenter setPersonalInfo:self.nameTextField.text
                               gender:self.genderLabel.text
                              imageId:[User updatedProfilePictureId]
                           occupation:self.occupationTextField.text
                         personalInfo:self.descriptionTextView.text];
    [self.nameTextField resignFirstResponder];
    [self.occupationTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
}

- (void)didFinishSettingPersonalInfo{
    self.navigationController.navigationBar.hidden = YES;
    [self performSegueWithIdentifier:@"showInvitationCodeView" sender:nil];
}



#pragma mark - Table View Delegate 


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat baseHeight = self.view.bounds.size.height;
    switch (indexPath.row) {
        case 0:
            return 100.0f / 1136 * baseHeight;
            break;
        case 4: // personal descriptionr
            return ( 1136 - 110 - 100 - 3 * 102 ) / 1136.0f * baseHeight; // screen height - nav bar height - banner height - 3 * info field
            break;
        default:
            return 102.0f / 1136 * baseHeight;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 1){
        [self.nameTextField becomeFirstResponder];
    }
    if (indexPath.row == 2){
        self.genderLabel.text = [self.genderLabel.text isEqualToString:@"男"] ? @"女" : @"男";
    }
    if (indexPath.row == 3){
        [self.occupationTextField becomeFirstResponder];
    }
    if (indexPath.row == 4){
        [self.descriptionTextView becomeFirstResponder];
    }

}

#pragma mark - Text Field Delegate 

- (void)textFieldDidUpdate{
    if (self.nameTextField.isFirstResponder){
        BOOL flag = self.nameTextField.text.length*[self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
    }

}

@end
