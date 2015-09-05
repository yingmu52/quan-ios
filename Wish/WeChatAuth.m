//
//  WeChatAuth.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-04.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WeChatAuth.h"
#import "AppDelegate.h"
#define WECHATAPPSECRET @"b96847759f201e33891ea1221f77cb21"
//#define BaseURL @"https://api.weixin.qq.com/sns/oauth2/"
//#define GetAccessToken @"access_token?"
//#define GetUserInfo @"userinfo?"
typedef enum {
    RequestOperationGetAccessToken,
    RequestOperationGetUserInfo
}RequestOperation;

@implementation WeChatAuth

- (void)getAccessTokenWithCode:(NSString *)code{
    NSString *rqtStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WECHATAppID,WECHATAPPSECRET,code];
    [self sendRequest:rqtStr operation:RequestOperationGetAccessToken];
}

/**
 http请求方式: GET
 https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
 */
- (void)getUserInfo:(NSString *)accessToken openID:(NSString *)openID{
    NSString *rqtStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openID];
    [self sendRequest:rqtStr operation:RequestOperationGetUserInfo];
}
- (void)sendRequest:(NSString *)str operation:(RequestOperation)operation{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      
                                      NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                      
                                      NSDictionary *timeOutDict = @{@"ret":@"Request Timeout",
                                                                    @"msg":@"Fail sending request to server"};
                                      NSDictionary *responseInfo = responseJson ? responseJson : timeOutDict;

                                      if (!error){
                                          [self finishSendingRequest:responseInfo operation:operation];
                                      }else{
                                      }
                                      
                                  }];
    [task resume];

}

- (void)finishSendingRequest:(NSDictionary *)json operation:(RequestOperation)operation{
    switch (operation) {
        case RequestOperationGetAccessToken:{
            NSString *accessToken = json[@"access_token"];
            //            NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:[json[@"expires_in"] integerValue]];
            NSString *openId = json[@"openid"];
//            NSString *refreshToken = json[@"refresh_token"];
            //            NSString *scope = json[@"scope"];
//            NSString *unionId = json[@"unionid"];
            /**
             此接口用于获取用户个人信息。开发者可通过OpenID来获取用户基本信息。特别需要注意的是，如果开发者拥有多个移动应用、网站应用和公众帐号，可通过获取用户基本信息中的unionid来区分用户的唯一性，因为只要是同一个微信开放平台帐号下的移动应用、网站应用和公众帐号，用户的unionid是唯一的。换句话说，同一用户，对同一个微信开放平台下的不同应用，unionid是相同的。
             **/
            if (accessToken && openId) {
                [self getUserInfo:accessToken openID:openId];
            }

        }
            break;
        case RequestOperationGetUserInfo:{
            NSString *headURL = json[@"headimgurl"];
            NSString *nickName = json[@"nickname"];
            NSString *openID = json[@"openid"];
            NSString *gender = [json[@"sex"] integerValue] ? @"男" : @"女";
//            NSString *unionID = json[@"unionid"];
            NSLog(@"%@",json);
        }
            break;
        default:
            break;
    }
}
@end


