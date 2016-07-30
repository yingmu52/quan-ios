//
//  InvitationViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-27.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "InvitationViewController.h"
#import "AppDelegate.h"

//#define invitationH5URL @"http://cos.jsonadmin.wexincloud.com/data/shier.invite.html"
#define placeholder @"http://o1wh05aeh.qnssl.com/image/view/app_icons/3112ec32be856c30e9e1cbc0127d99b5/120"

@interface InvitationViewController() <WXApiDelegate>
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@end
@implementation InvitationViewController 


- (void)viewDidLoad{
    [super viewDidLoad];
    self.titleLabel.text = self.titleText;
}
- (IBAction)dismissViewcontroller{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSURL *)imageUrl{
    if (!_imageUrl) {
        _imageUrl = [NSURL URLWithString:placeholder];
    }
    return _imageUrl;
}

- (IBAction)tapOnWechat{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.sharedContentTitle;
    message.description = self.sharedContentDescription;
    NSData *thumbnailData = [NSData dataWithContentsOfURL:self.imageUrl];
    message.thumbData = thumbnailData;
    
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
                                                    title:self.sharedContentTitle
                                              description:self.sharedContentDescription
                                          previewImageURL:self.imageUrl];
    QQApiSendResultCode code = [QQApiInterface sendReq:[SendMessageToQQReq reqWithContent:newsObj]];
    NSLog(@"%@",@(code));
    [self dismissViewcontroller];


}

@end
