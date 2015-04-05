
//  MenuViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "User.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIViewController+ECSlidingViewController.h"
#import "Third Party/TencentOpenAPI.framework/Headers/TencentOAuth.h"
#import "Third Party/TencentOpenAPI.framework/Headers/TencentApiInterface.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#define AppKey @"ByYhJYTkXu0721fH"
#define AppID @"1104337894"

typedef enum {
    MenuTableWishList = 0,
    MenuTableJourney,
    MenuTableDiscover,
    MenuTableFollow
}MenuMidSection;

typedef enum {
    MenuSectionLogin = 0,
    MenuSectionMid,
    MenuSectionLower
}MenuSection;


@interface MenuViewController () <TencentSessionDelegate,FetchCenterDelegate>
@property (nonatomic) BOOL isLogin;
@property (nonatomic,strong) TencentOAuth *tencentOAuth;
@property (nonatomic,strong) APIResponse *apiResponse;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) IBOutlet UILabel *versionLabel;
@end


@implementation MenuViewController


- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)setVersionLabel:(UILabel *)versionLabel{
    _versionLabel = versionLabel;
    _versionLabel.text = @"Version 2.7.3";
}
- (IBAction)showSettingsView:(UIButton *)sender{
    if ([User isUserLogin]){
        [self performSegueWithIdentifier:@"showSettingView" sender:nil];
    }
}

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue
{
    //after returning to menue view
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set menu background image
    self.tableView.backgroundColor = [Theme menuBackground];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRef = tableView.frame.size.height;
    if (indexPath.section == MenuSectionLogin) {
        return heightRef * 278 / 1136;
    }else if (indexPath.section == MenuSectionMid){
        return heightRef * 178 / 1136;
    }else if (indexPath.section == MenuSectionLower){
        return heightRef * 146/ 1136;
    }else{
        return 0;
    }
}


- (MenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == MenuSectionLogin) {

        if (![User isUserLogin]) {
            cell.menuImageView.image = [Theme menuLoginDefault];
            cell.menuTitle.text = @"登录";
        }else{
            NSString *newPicId = [User updatedProfilePictureId];
            NSURL *url = [newPicId isEqualToString:@""] ? [User userProfilePictureURL] : [self.fetchCenter urlWithImageID:newPicId];
            [cell.menuImageView setImageWithURL:url
                    usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            cell.menuTitle.text = [User userDisplayName];
        }
    }
    
    if (indexPath.section == MenuSectionMid && indexPath.row == MenuTableFollow){
        cell.hidden = YES;
    }
    if (indexPath.section == MenuSectionLower) {
            //only setting
        [cell hideMessageButton];
    }

    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MenuSectionLogin && ![User isUserLogin]){
        [self login];
    }

    if ([User isUserLogin]) {
        if (indexPath.section == MenuSectionMid) {
            NSString *identifier;
            switch (indexPath.row) {
                case MenuTableWishList:
                    identifier = @"showWishList";
                    break;
                case MenuTableJourney:
                    identifier = @"ShowAcheivementList";
                    break;
                case MenuTableFollow:
                    identifier = @"ShowFollowingFeed";
                    break;
                case MenuTableDiscover:
                    identifier = @"ShowDiscoveryList";
                    break;
                default:
                    break;
            }
            [self performSegueWithIdentifier:identifier sender:nil];
        }
    }
}


#pragma mark - cell highlight behavior
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCell:tableView at:indexPath];

}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCell:tableView at:indexPath];
}
- (void)toggleCell:(UITableView *)tableView at:(NSIndexPath *)indexPath
{
    MenuCell *selectedCell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [selectedCell.menuImageView setHighlighted:!selectedCell.menuImageView.isHighlighted];

}

#pragma mark - login

- (TencentOAuth *)tencentOAuth{
    if (!_tencentOAuth) {
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:AppID andDelegate:self];
        _tencentOAuth.redirectURI = @"www.qq.com";
    }
    return _tencentOAuth;
}
- (void)login{
    NSArray *permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO];
    [self.tencentOAuth authorize:permissions inSafari:NO];
}

//login successed
- (void)tencentDidLogin
{
    NSLog(@"login successed");
    if (self.tencentOAuth.accessToken && [self.tencentOAuth.accessToken length]){
        [self.tencentOAuth getUserInfo];
    }else{
        NSLog(@"login fail, no accesstoken");
    }
}

- (void)getUserInfoResponse:(APIResponse *)response{
    //use openId and access_token to get uid+ukey
    [self.fetchCenter fetchUidandUkeyWithOpenId:self.tencentOAuth.openId accessToken:self.tencentOAuth.accessToken];
    self.apiResponse = response;
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    dispatch_main_async_safe((^{
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                    message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        [User updateOwnerInfo:nil];
        [self.tableView reloadData];
    }));
}

- (void)didFinishReceivingUid:(NSString *)uid uKey:(NSString *)uKey{
    //store access token, openid, expiration date, user photo, username, gender
    NSDictionary *fetchedUserInfo = [self.apiResponse jsonResponse];

    if (fetchedUserInfo) {
        
        //update local user info & UI
        dispatch_main_async_safe((^{
            
            NSString *nickName = fetchedUserInfo[@"nickname"];
            NSString *gender = fetchedUserInfo[@"gender"];
            
            NSDictionary *localUserInfo = @{ACCESS_TOKEN:self.tencentOAuth.accessToken,
                                            OPENID:self.tencentOAuth.openId,
                                            EXPIRATION_DATE:self.tencentOAuth.expirationDate,
                                            PROFILE_PICTURE_ID:fetchedUserInfo[@"figureurl_qq_2"],
                                            PROFILE_PICTURE_ID_CUSTOM:@"",
                                            GENDER:gender,
                                            USER_DISPLAY_NAME:nickName,
                                            UID:uid,
                                            UKEY:uKey};
            [User updateOwnerInfo:localUserInfo];
            NSLog(@"%@",localUserInfo);

            [self.tableView reloadData];
            [self performSegueWithIdentifier:@"showWishList" sender:nil];
            //update user info
//            [self.fetchCenter updatePersonalInfo:[NSString stringWithFormat:@"%@ ",nickName] gender:gender];

        }));
    }
}

- (void)didFinishUpdatingPersonalInfo{
    NSLog(@"info updated");
}
//login fail
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        NSLog(@"user cancelled");
    }else{
        NSLog(@"login fail");
    }
}

//no internet
-(void)tencentDidNotNetWork
{
    NSLog(@"无网络连接，请设置网络");
}


/*
 特别提示：
 1.由于登录是异步过程，这里可能会由于用户的行为导致整个登录的的流程无法正常走完，即有可能由于用户行为导致登录完成后不会有任何登录回调被调用。开发者在使用SDK进行开发的时候需要考虑到这点，防止由于一直在同步等待登录的回调而造成应用的卡死，建议在登录的时候将这个实现做成一个异步过程。
 2.获取到的access token具有3个月有效期，过期后提示用户重新登录授权。
 3. 第三方网站可存储access token信息，以便后续调用OpenAPI访问和修改用户信息时使用。如果需要保存授权信息，需要保存登录完成后返回的accessToken，openid 和 expirationDate三个数据，下次登录的时候直接将这三个数据是设置到TencentOAuth对象中即可。
 4. 建议应用在用户登录后，即调用getUserInfo接口获得该用户的头像、昵称并显示在界面上，使用户体验统一。
 */
@end
