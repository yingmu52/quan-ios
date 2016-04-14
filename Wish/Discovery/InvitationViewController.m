//
//  InvitationViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-27.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "InvitationViewController.h"
#import "AppDelegate.h"

#define invitationH5URL @"http://cos.jsonadmin.wexincloud.com/data/shier.invite.html"
#define placeholder @"http://7kttjt.com1.z0.glb.clouddn.com/image/view/app_icons/46df607f631689bfe4ed6839ad1a220b/120"

@interface InvitationViewController() <WXApiDelegate>
@property (nonatomic,strong) NSURL *circleImageUrl;
@property (nonatomic,strong) NSString *h5Url;
@property (nonatomic,strong) NSString *invitationTitle;
@property (nonatomic,strong) NSString *invitationDesc;
@end
@implementation InvitationViewController 


- (NSString *)h5Url{
    if (!_h5Url && self.circle) {
        _h5Url = [NSString stringWithFormat:@"%@?quanId=%@",invitationH5URL,self.circle.circleId];
    }
    NSLog(@"H5 URL: %@",_h5Url);
    return _h5Url;
}

- (NSURL *)circleImageUrl{
    if (!_circleImageUrl) {
        if (self.circle.imageId) {
            //接入H5页，需要带入圈子id
            NSString *urlString = [self.fetchCenter urlWithImageID:self.circle.imageId
                                                           size:FetchCenterImageSizeOriginal].absoluteString;
            _circleImageUrl = [NSURL URLWithString:urlString];
        }else{
            _circleImageUrl = [NSURL URLWithString:placeholder];
        }
    }    
    NSLog(@"image url : %@",_circleImageUrl);
    return _circleImageUrl;
}


- (IBAction)dismissViewcontroller{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)tapOnWechat{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.circle.circleName;
    message.description = self.circle.circleDescription;
    message.thumbData = [NSData dataWithContentsOfURL:self.circleImageUrl];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.h5Url;
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
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.h5Url]
                                                    title:self.circle.circleName
                                              description:self.circle.circleDescription
                                          previewImageURL:self.circleImageUrl];
    QQApiSendResultCode code = [QQApiInterface sendReq:[SendMessageToQQReq reqWithContent:newsObj]];
    NSLog(@"%@",@(code));
    [self dismissViewcontroller];


}

@end
