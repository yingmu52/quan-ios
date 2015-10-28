//
//  InvitationViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-27.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "InvitationViewController.h"
#import "AppDelegate.h"

@interface InvitationViewController() <WXApiDelegate>

@end
@implementation InvitationViewController 

- (IBAction)dismissViewcontroller{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#define pgyerUrl @"www.pgyer.com/sAG9"
#define shareTitle @"H5大师将至"
#define shareDesc @"尽请期待！"
#define imgUrl @"http://7kttjt.com1.z0.glb.clouddn.com/image/view/app_icons/46df607f631689bfe4ed6839ad1a220b/120"
- (IBAction)tapOnWechat{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = shareTitle;
    message.description = shareDesc;
    message.thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = pgyerUrl;
    message.mediaObject = ext;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.scene = WXSceneSession;
    req.message = message;

    [WXApi sendReq:req];
    
    [self dismissViewcontroller];
}

- (IBAction)tapOnQQ{
    
    //必须执行下面这行，否则handleSendResult里会指示 EQQAPIAPPNOTREGISTED，应用未注册。
    TencentOAuth *oAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:nil];
    [oAuth openSDKWebViewQQShareEnable];
    
    //分享跳转URL
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:pgyerUrl]
                                                    title:shareTitle
                                              description:shareDesc
                                          previewImageURL:[NSURL URLWithString:imgUrl]];
    QQApiSendResultCode code = [QQApiInterface sendReq:[SendMessageToQQReq reqWithContent:newsObj]];
    NSLog(@"%@",@(code));
    [self dismissViewcontroller];


}

@end
