//
//  Message.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "Message.h"
#import "Owner.h"
#import "Plan.h"
#import "AppDelegate.h"
#import "User.h"
@implementation Message


+ (Message *)updateMessageWithInfo:(NSDictionary *)messageInfo ownerInfo:(NSDictionary *)ownerInfo{
    
    Message *message;
    NSArray *results = [Plan fetchWith:@"Message"
                             predicate:[NSPredicate predicateWithFormat:@"messageId == %@",messageInfo[@"messageId"]]
                      keyForDescriptor:@"createTime"]; //utility method from Plan+PlanCRUD.h
    
    NSAssert(results.count <= 1, @"messageId must be a unique!");
    if (!results.count) {
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                inManagedObjectContext:[AppDelegate getContext]];
        message.commentId = messageInfo[@"commentId"];
        message.content = messageInfo[@"content"];
        message.feedsId = messageInfo[@"feedsId"];
        message.messageId = messageInfo[@"messageId"];
        message.picurl = messageInfo[@"picurl"];
        
        message.createTime = [NSDate dateWithTimeIntervalSince1970:[messageInfo[@"createTime"] integerValue]];
        
        message.owner = [Owner updateOwnerWithInfo:ownerInfo];
        
        message.targetOwnerId = [User uid]; //this message is requested by the current user ~
        
        message.isRead = @(NO); // every newly created message is initially not read.
        
    }else{
        message = results.lastObject;
    }
    
    return message;
}

/* example
 
 {
 commentId = "comment555797d6493945.92169026";
 content = u4f60u5728u54c7u4ec0u4e48uff1f;
 createTime = 1431803862;
 feedsId = "feeds55570d571a14a4.21421165";
 messageId = "msg555797d64c9ad3.42196323";
 operatorId = 100008;
 picurl = "pic55570d5709bb86.99847365";
 },
 
 */
@end
