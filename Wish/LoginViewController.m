//
//  LoginViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "LoginViewController.h"
#import "Third Party/TencentOpenAPI.framework/Headers/TencentOAuth.h"
#import "Third Party/TencentOpenAPI.framework/Headers/TencentApiInterface.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "User.h"
#import "LoginDetailViewController.h"
#import "ECSlidingViewController.h"

#define AppKey @"ByYhJYTkXu0721fH"
#define AppID @"1104337894"

@interface LoginViewController () <TencentSessionDelegate,FetchCenterDelegate>
@property (nonatomic,strong) TencentOAuth *tencentOAuth;
@property (nonatomic,strong) APIResponse *apiResponse;
@property (nonatomic,strong) FetchCenter *fetchCenter;


@property (nonatomic,weak) IBOutlet UIButton *loginButton;
@end
@implementation LoginViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (TencentOAuth *)tencentOAuth{
    if (!_tencentOAuth) {
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:AppID andDelegate:self];
        _tencentOAuth.redirectURI = @"www.qq.com";
    }
    return _tencentOAuth;
}

#pragma mark - login

- (IBAction)login:(id)sender{
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
    }));
}

/*
 data =     {
 isNew = 0;
 maninfo =         {
 birthday = 1234;
 createTime = 1429674033;
 followPlanList = "<null>";
 gender = 2;
 headUrl = "pic5537183176a034.11814009";
 id = 100001;
 name = "hello_***_name";
 ownPlanList = "[\"100001_1429674034\",\"100001_1429674035\",\"100001_1429674036\"]";
 setLife = 1000;
 };
 uid = 100001;
 ukey = "ukey553718312f2248.52389148";
 };
 msg = ok;
 ret = 0;
 }
 */

- (void)didFinishReceivingUid:(NSString *)uid uKey:(NSString *)uKey isNewUser:(BOOL)isNew userInfo:(NSDictionary *)userInfo{
    //store access token, openid, expiration date, user photo, username, gender
    NSDictionary *fetchedUserInfo = [self.apiResponse jsonResponse];
    
    if (fetchedUserInfo) {
        //update local user info & UI
        dispatch_main_async_safe((^{
            NSDictionary *localUserInfo = @{ACCESS_TOKEN:self.tencentOAuth.accessToken,
                                            OPENID:self.tencentOAuth.openId,
                                            EXPIRATION_DATE:self.tencentOAuth.expirationDate,
                                            PROFILE_PICTURE_ID:fetchedUserInfo[@"figureurl_qq_2"],
                                            GENDER:fetchedUserInfo[@"gender"],
                                            USER_DISPLAY_NAME:fetchedUserInfo[@"nickname"],
                                            UID:uid,
                                            UKEY:uKey};
            [User updateOwnerInfo:localUserInfo];
            
            if (!isNew) {
                NSDictionary *additionalUserInfo = @{PROFILE_PICTURE_ID_CUSTOM:userInfo[@"headUrl"],
                                                     GENDER:[userInfo[@"gender"] boolValue] ? @"男" : @"女",
                                                     USER_DISPLAY_NAME:userInfo[@"name"]};
                [User updateAttributeFromDictionary:additionalUserInfo];
//                NSLog(@"%@",localUserInfo);
                [self performSegueWithIdentifier:@"showMainViewFromLogin" sender:nil];
            }else{
                [self performSegueWithIdentifier:@"showLoginDetail" sender:nil];
            }

        }));
    }
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showMainViewFromLogin"]) {
        ECSlidingViewController *root = (ECSlidingViewController *)segue.destinationViewController;
        root.anchorRightPeekAmount = root.view.frame.size.width * (640 - 290.0)/640;
        root.underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    }
    //    if ([segue.identifier isEqualToString:@"showLoginDetail"]) {
    //        [segue.destinationViewController setUserInfo:sender];
    //    }
    
}
@end
