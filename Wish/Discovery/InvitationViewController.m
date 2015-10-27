//
//  InvitationViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-27.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "InvitationViewController.h"
#import "AppDelegate.h"
@implementation InvitationViewController

- (IBAction)dismissViewcontroller{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapOnWechat{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"H5大师将至";
    message.description = @"尽请期待！";
    [message setThumbImage:nil];
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = @"www.pgyer.com/sAG9";
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

- (IBAction)tapOnQQ{
    
}

@end
