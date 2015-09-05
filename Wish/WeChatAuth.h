//
//  WeChatAuth.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-04.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeChatAuth : NSObject

- (void)getAccessTokenWithCode:(NSString *)code;
@end
