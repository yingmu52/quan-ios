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
#import "MBProgressHUD.h"
#define QQAppKey @"ByYhJYTkXu0721fH"
//#import "SMSSDKUI.h"
@interface LoginViewController () <TencentSessionDelegate,FetchCenterDelegate,WXApiManagerDelegate,MBProgressHUDDelegate>
@property (nonatomic,strong) TencentOAuth *tencentOAuth;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) IBOutlet UIButton *QQLoginButton;
@property (nonatomic,weak) IBOutlet UIButton *WechatLoginButton;
@property (nonatomic,strong) MBProgressHUD *hud;

@end
@implementation LoginViewController


- (MBProgressHUD *)hud{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.delegate = self;
    }
    return _hud;
}


+ (LoginViewController *)initLoginViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationViewController"];
    return lvc;
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

#pragma mark - QQ Login

//login successed
- (void)tencentDidLogin
{
    //获取用户信息
//    if (self.tencentOAuth.accessToken.length > 0){
//        [self.tencentOAuth getUserInfo];
//    }
    
    //保持授权数据
    NSDictionary *localUserInfo = @{ACCESS_TOKEN:self.tencentOAuth.accessToken,
                                    OPENID:self.tencentOAuth.openId,
                                    EXPIRATION_DATE:self.tencentOAuth.expirationDate};
    [User updateAttributeFromDictionary:localUserInfo];

    //use openId and access_token to get uid+ukey
    [self.fetchCenter getUidandUkeyWithOpenId:self.tencentOAuth.openId
                                  accessToken:self.tencentOAuth.accessToken
                                   completion:^(NSDictionary *userInfo, BOOL isNewUser)
     {
         [self processLoginWithUserInfo:userInfo isUser:isNewUser];
     }];
    
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

//- (void)getUserInfoResponse:(APIResponse *)response{
//    //保存accessToken和openId
//    @try {
//        NSDictionary *fetchedUserInfo = [response jsonResponse];
//        if (fetchedUserInfo) { //处理QQ Api用户信息返回失败引起闪退
//            NSDictionary *fetchedUserInfo = @{PROFILE_PICTURE_ID:fetchedUserInfo[@"figureurl_qq_2"],
//                                              GENDER:fetchedUserInfo[@"gender"],
//                                              USER_DISPLAY_NAME:fetchedUserInfo[@"nickname"]};
//            [User updateAttributeFromDictionary:fetchedUserInfo];
//        }
//    } @catch (NSException *exception) {
//        NSLog(@"%@",exception);
//    }
//}

- (void)processLoginWithUserInfo:(NSDictionary *)userInfo isUser:(BOOL)isNewUser{
    if (!isNewUser) {
        NSDictionary *additionalUserInfo = @{PROFILE_PICTURE_ID_CUSTOM:userInfo[@"headUrl"],
                                             GENDER:[userInfo[@"gender"] boolValue] ? @"男" : @"女",
                                             USER_DISPLAY_NAME:userInfo[@"name"],
                                             OCCUPATION:userInfo[@"profession"],
                                             PERSONALDETAIL:userInfo[@"description"]};
        [User updateAttributeFromDictionary:additionalUserInfo];
        
        [AppDelegate showMainTabbar];

    }else{
        if ([[User loginType] isEqualToString:@"qq"]) {
            [self performSegueWithIdentifier:@"showLoginDetail" sender:nil];
        }
        if ([[User loginType] isEqualToString:@"wx"]) {
            [self.fetchCenter getWechatUserInfoWithOpenID:[User openID]
                                                    token:[User accessToken]
                                               completion:^
            {
                [self performSegueWithIdentifier:@"showLoginDetail" sender:nil];
                //微信的登陆方式很奇怪，performsegue无法解法，故以此解法。
            }];
        }
        
    }
    
    //Send Device Token
    if ([User deviceToken].length > 0) {
        [self.fetchCenter sendDeviceToken:[User deviceToken] completion:nil];
    }
    
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
    [User updateOwnerInfo:@{LOGIN_TYPE:@"qq"}];
}

#pragma mark - wechat 

- (IBAction)wechatLogin{
    
    //检查网络
    Reachability *rech = [Reachability reachabilityForInternetConnection];
    if (rech.currentReachabilityStatus != NotReachable){
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo,snsapi_base"; // @"post_timeline,sns"
        req.openID = WECHATAppID;
        
        WXApiManager *manager = [WXApiManager sharedManager];
        manager.delegate = self;
        [WXApi sendAuthReq:req viewController:self delegate:manager];
        
        [User updateOwnerInfo:@{LOGIN_TYPE:@"wx"}];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"手机无网络"
                                                                       message:@"请确保手机有正常的网络连接"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response{
    self.hud.label.text = @"登陆中...";
    [self.fetchCenter getAccessTokenWithWechatCode:response.code
                                        completion:^(NSDictionary *userInfo, BOOL isNewUser)
    {
        [self processLoginWithUserInfo:userInfo isUser:isNewUser];
        [self.hud hideAnimated:YES];
    }];
}

#pragma mark - visitor login 

- (IBAction)visitorLogin{
    //展示获取验证码界面，SMSGetCodeMethodSMS:表示通过文本短信方式获取验证码
//    [SMSSDKUI showVerificationCodeViewWithMetohd:SMSGetCodeMethodSMS result:^(enum SMSUIResponseState state,NSString *phoneNumber,NSString *zone, NSError *error) {
//        
//    }];
}

@end


