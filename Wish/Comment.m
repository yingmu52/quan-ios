//
//  Comment.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "Comment.h"
#import "Feed.h"
#import "Owner.h"
#import "Plan.h"
#import "AppDelegate.h"
#import "User.h"
@implementation Comment

+ (Comment *)updateCommentWithInfo:(NSDictionary *)dict
              managedObjectContext:(nonnull NSManagedObjectContext *)context{
    
    Comment *comment;
    NSArray *results = [Plan fetchWith:@"Comment"
                             predicate:[NSPredicate predicateWithFormat:@"commentId == %@",dict[@"id"]]
                      keyForDescriptor:@"commentId"
                  managedObjectContext:context]; //utility method from Plan+PlanCRUD.h
    
    NSAssert(results.count <= 1, @"ownerId must be a unique!");
    if (!results.count) {
        comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
        comment.commentId = dict[@"id"];
        comment.content = dict[@"content"];
        comment.createTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
        comment.isMyComment = @([dict[@"ownerId"] isEqualToString:[User uid]]);
        NSString *commentTo = dict[@"commentTo"]; //this is what differential reply and comment
        
        if (![commentTo isKindOfClass:[NSNull class]] && ![commentTo isEqualToString:@""]) { //for cases where commentTo = "<null>";
            comment.idForReply = commentTo;
        }
        
    }else{
        comment = results.lastObject;
    }
    
    return comment;
}

+ (Comment *)createComment:(NSString *)content commentId:(NSString *)commendId forFeed:(Feed *)feed{
    
    NSManagedObjectContext *context = [AppDelegate getContext];
    Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                     inManagedObjectContext:context];
    comment.commentId = commendId;
    comment.content = content;
    comment.createTime = [NSDate date];
    comment.feed = feed;
    comment.owner = [Owner updateOwnerWithInfo:[Owner myWebInfo] managedObjectContext:context];
    return comment;
    
}


+ (Comment *)replyToOwner:(Owner *)owner content:(NSString *)text commentId:(NSString *)commentId forFeed:(Feed *)feed{
    if (!owner.ownerId) {
        NSLog(@"invalid owner %@",owner);
    }
    Comment *comment = [self.class createComment:text commentId:commentId forFeed:feed];
    comment.idForReply = owner.ownerId;
    comment.nameForReply = owner.ownerName;
    return comment;
}

@end
