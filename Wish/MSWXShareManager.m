//
//  MSWXShareManager.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/24/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSWXShareManager.h"
#import "WXApi.h"
@implementation MSWXShareManager


+ (void)share:(NSString *)title description:(NSString *)desc imageURL:(NSURL *)imageUrl h5url:(NSString *)h5url{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    message.thumbData = [NSData dataWithContentsOfURL:imageUrl];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = h5url;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.scene = WXSceneSession;
    req.message = message;
    
    [WXApi sendReq:req];

}
@end
