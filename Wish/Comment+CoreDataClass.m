//
//  Comment+CoreDataClass.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Comment+CoreDataClass.h"
#import "Feed+CoreDataClass.h"
#import "Owner+CoreDataClass.h"
@implementation Comment

+ (Comment *)updateCommentWithInfo:(NSDictionary *)dict
                         ownerInfo:(NSDictionary *)ownerInfo
                            inFeed:(nonnull Feed *)feed
              managedObjectContext:(nonnull NSManagedObjectContext *)context{
    
    Comment *comment = [Comment fetchID:dict[@"id"] inManagedObjectContext:context];
    
    if (!comment) {
        comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
        comment.mUID = dict[@"id"];
        comment.mTitle = dict[@"content"];
        comment.mCreateTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
        
        
        NSString *ownerId = dict[@"ownerId"];
        comment.owner = [Owner updateOwnerWithInfo:ownerInfo[ownerId]
                              managedObjectContext:context];
        comment.feed = feed;
        
    }
    NSString *commentTo = dict[@"commentTo"]; //this is what differential reply and comment
    if (commentTo.length > 0 && ![comment.idForReply isEqualToString:commentTo]) {
        comment.idForReply = commentTo;
        NSString *nameForReply = [ownerInfo[commentTo] objectForKey:@"name"];
        comment.nameForReply = nameForReply;
        //        NSLog(@"comment to %@, %@",commentTo,nameForReply);
    }
    
    
    comment.mLastReadTime = [NSDate date];
    
    return comment;
}



+ (Comment *)createComment:(NSString *)content
                 commentId:(NSString *)commendId
                 forFeedID:(NSString *)feedID
    inManagedObjectContext:(NSManagedObjectContext *)context{
    
    Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                     inManagedObjectContext:context];
    comment.mUID = commendId;
    comment.mTitle = content;
    comment.mCreateTime = [NSDate date];
    comment.owner = [Owner updateOwnerWithInfo:[Owner myWebInfo] managedObjectContext:context];
    
    Feed *feed = [Feed fetchID:feedID inManagedObjectContext:context];
    feed.commentCount = @(feed.commentCount.integerValue + 1);
    comment.feed = feed;
    
    return comment;
}


+ (Comment *)replyToOwner:(NSString *)ownerID
                ownerName:(NSString *)ownerName
                  content:(NSString *)content
                commentId:(NSString *)commentId
                forFeedID:(NSString *)feedID
   inManagedObjectContext:(NSManagedObjectContext *)context{
    Comment *comment = [Comment createComment:content
                                    commentId:commentId
                                    forFeedID:feedID
                       inManagedObjectContext:context];
    comment.idForReply = ownerID;
    comment.nameForReply = ownerName;
    return comment;
}


@end
