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

@interface LoginDetailViewController () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end
@implementation LoginDetailViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accessMainViewButton.hidden = YES;
    //download head url for uploading to our server
    [self.profileImageView setImageWithURL:[User userProfilePictureURL]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                 completed:^(UIImage *image,
                                             NSError *error,
                                             SDImageCacheType cacheType,
                                             NSURL *imageURL)
     {
         //upload image on login
         [self.fetchCenter uploadNewProfilePicture:image];
     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    [self.fetchCenter updatePersonalInfo:[NSString stringWithFormat:@"%@ ",nickName] gender:gender];

}


#pragma mark - new user registration


- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)didFinishUploadingPictureForProfile:(NSDictionary *)info{
    //finish uploading profile picture, imageid saved
    dispatch_main_async_safe(^{
        self.accessMainViewButton.hidden = NO;
    });
}

- (void)handleFailure:(NSDictionary *)info{
    dispatch_main_async_safe((^{
        self.navigationItem.rightBarButtonItem = nil;
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                    message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }));
    
}

- (IBAction)showMainView:(id)sender{
    //upload user info
    NSString *gender = [User gender];
    NSString *profilePicId = [User updatedProfilePictureId];
    [self.fetchCenter setPersonalInfo:self.textField.text gender:gender imageId:profilePicId];
}

- (void)didFinishSettingPersonalInfo{
    dispatch_main_async_safe(^{
        [self performSegueWithIdentifier:@"showMainView" sender:nil];
    });

}


#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showMainView"]) {
        ECSlidingViewController *root = (ECSlidingViewController *)segue.destinationViewController;
        root.anchorRightPeekAmount = root.view.frame.size.width * (640 - 290.0)/640;
        root.underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    }
}

@end
