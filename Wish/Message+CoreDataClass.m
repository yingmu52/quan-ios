//
//  Message+CoreDataClass.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Message+CoreDataClass.h"
#import "Owner+CoreDataClass.h"
@implementation Message


+ (Message *)updateMessageWithInfo:(NSDictionary *)messageInfo
                         ownerInfo:(NSDictionary *)ownerInfo
              managedObjectContext:(nonnull NSManagedObjectContext *)context{
    
    Message *message = [Message fetchID:messageInfo[@"messageId"] inManagedObjectContext:context];
    
    if (!message) {
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                inManagedObjectContext:context];
        message.commentId = messageInfo[@"commentId"];
        message.mTitle = messageInfo[@"content"];
        message.feedsId = messageInfo[@"feedsId"];
        message.mUID = messageInfo[@"messageId"];
        message.mCoverImageId = messageInfo[@"picurl"];
        
        message.mCreateTime = [NSDate dateWithTimeIntervalSince1970:[messageInfo[@"createTime"] integerValue]];
        
        message.owner = [Owner updateOwnerWithInfo:ownerInfo managedObjectContext:context];
        
        message.targetOwnerId = [User uid]; //this message is requested by the current user ~
        
    }
    
    BOOL userDeleted = [messageInfo[@"isdelete"] boolValue];
    if (message.userDeleted.boolValue != userDeleted) {
        message.userDeleted = @(userDeleted);
    }
    
    message.mLastReadTime = [NSDate date];
    return message;
}


@end
