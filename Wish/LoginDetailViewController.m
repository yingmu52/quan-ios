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
#import "ECSlidingViewController.h"
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
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                     target:self
                                   selector:@selector(showMainView)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#warning - download head url for uploading to our server
//    [self.profileImageView setImageWithURL:[User userProfilePictureURL]
//                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
//                                 completed:^(UIImage *image,
//                                             NSError *error,
//                                             SDImageCacheType cacheType,
//                                             NSURL *imageURL)
//     {
//         //upload image on login
//         [self.fetchCenter uploadNewProfilePicture:image];
//     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    //    [self.fetchCenter updatePersonalInfo:[NSString stringWithFormat:@"%@ ",nickName] gender:gender];
    [self setupNavigationItem];
    
    [self.descriptionTextView setPlaceholder:@"描述下你是怎样的一个人？"];
    
    [self.nameTextField addTarget:self
                           action:@selector(textFieldDidUpdate)
                 forControlEvents:UIControlEventEditingChanged];

}


#pragma mark - new user registration


- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)didFinishUploadingPictureForProfile:(NSDictionary *)info{
    //finish uploading profile picture, imageid saved
}

- (void)handleFailure:(NSDictionary *)info{
    self.navigationItem.rightBarButtonItem = nil;
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)showMainView{
    //upload user info
    NSString *gender = [User gender];
    NSString *profilePicId = [User updatedProfilePictureId];
//    [self.fetchCenter setPersonalInfo:self.textField.text gender:gender imageId:profilePicId];
}

- (void)didFinishSettingPersonalInfo{
    [self performSegueWithIdentifier:@"showMainView" sender:nil];
}


#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showMainView"]) {
        ECSlidingViewController *root = (ECSlidingViewController *)segue.destinationViewController;
        root.anchorRightPeekAmount = root.view.frame.size.width * (640 - 290.0)/640;
        root.underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    }
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
    BOOL flag = self.nameTextField.text.length*[self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
    self.navigationItem.rightBarButtonItem.enabled = flag;
    UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
    [self.tikButton setImage:bg forState:UIControlStateNormal];
}

@end
