//
//  LoginViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "LoginViewController.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "User.h"
#import "LoginDetailViewController.h"
#define QQAppKey @"ByYhJYTkXu0721fH"
#define QQAppID @"1104337894"

@interface LoginViewController () <TencentSessionDelegate,FetchCenterDelegate>
@property (nonatomic,strong) TencentOAuth *tencentOAuth;
@property (nonatomic,strong) APIResponse *apiResponse;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) IBOutlet UIButton *QQLoginButton;
@property (nonatomic,weak) IBOutlet UIButton *WechatLoginButton;
@end
@implementation LoginViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

#pragma mark - login

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    [User updateOwnerInfo:nil];
}


- (void)didFinishReceivingUid:(NSString *)uid uKey:(NSString *)uKey isNewUser:(BOOL)isNew userInfo:(NSDictionary *)userInfo{
    //store access token, openid, expiration date, user photo, username, gender
    NSDictionary *fetchedUserInfo = [self.apiResponse jsonResponse];
    
    if (fetchedUserInfo) {
        //update local user info & UI
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
                                                 USER_DISPLAY_NAME:userInfo[@"name"],
                                                 OCCUPATION:userInfo[@"profession"],
                                                 PERSONALDETAIL:userInfo[@"description"]};
            [User updateAttributeFromDictionary:additionalUserInfo];
//            NSLog(@"%@",localUserInfo);
            if (self.navigationController.presentingViewController){
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self performSegueWithIdentifier:@"showMainViewFromLogin" sender:nil];
            }

        }else{
            [self performSegueWithIdentifier:@"showLoginDetail" sender:nil];
        }
        
    }
    self.QQLoginButton.enabled = YES;

    NSLog(@"%@",[User getOwnerInfo]);
    
}


#pragma mark - QQ Login

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
//login fail
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        NSLog(@"user cancelled");
    }else{
        NSLog(@"login fail");
    }
    self.QQLoginButton.enabled = YES;
}

//no internet
-(void)tencentDidNotNetWork
{
    NSLog(@"无网络连接，请设置网络");
    self.QQLoginButton.enabled = YES;
}


/*
 特别提示：
 1.由于登录是异步过程，这里可能会由于用户的行为导致整个登录的的流程无法正常走完，即有可能由于用户行为导致登录完成后不会有任何登录回调被调用。开发者在使用SDK进行开发的时候需要考虑到这点，防止由于一直在同步等待登录的回调而造成应用的卡死，建议在登录的时候将这个实现做成一个异步过程。
 2.获取到的access token具有3个月有效期，过期后提示用户重新登录授权。
 3. 第三方网站可存储access token信息，以便后续调用OpenAPI访问和修改用户信息时使用。如果需要保存授权信息，需要保存登录完成后返回的accessToken，openid 和 expirationDate三个数据，下次登录的时候直接将这三个数据是设置到TencentOAuth对象中即可。
 4. 建议应用在用户登录后，即调用getUserInfo接口获得该用户的头像、昵称并显示在界面上，使用户体验统一。
 */

- (void)getUserInfoResponse:(APIResponse *)response{
    //use openId and access_token to get uid+ukey
    [self.fetchCenter fetchUidandUkeyWithOpenId:self.tencentOAuth.openId accessToken:self.tencentOAuth.accessToken];
    self.apiResponse = response;
}

- (TencentOAuth *)tencentOAuth{
    if (!_tencentOAuth) {
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
        _tencentOAuth.redirectURI = @"www.qq.com";
    }
    return _tencentOAuth;
}

- (IBAction)qqlogin{
    NSArray *permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO];
    [self.tencentOAuth authorize:permissions inSafari:NO];
    self.QQLoginButton.enabled = NO;
}

#pragma mark - wechat 

- (IBAction)wechatLogin{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo,snsapi_base"; // @"post_timeline,sns"
    req.state = @"fuck";
    req.openID = WECHATAppID;
    [WXApi sendAuthReq:req viewController:self delegate:self];
}


- (void)onResp:(BaseResp *)resp{
    SendAuthResp *temp = (SendAuthResp*)resp;
    NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", temp.code, temp.state, temp.errCode];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


@end
