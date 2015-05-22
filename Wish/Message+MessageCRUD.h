//
//  Message+MessageCRUD.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Message.h"

@interface Message (MessageCRUD)
+ (Message *)updateMessageWithInfo:(NSDictionary *)messageInfo ownerInfo:(NSDictionary *)ownerInfo;
@end
