//
//  Comment+CRUD.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-08.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Comment+CRUD.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "Owner+OwnerCRUD.h"
#import "User.h"
@implementation Comment (CRUD)

+ (Comment *)updateCommentFromServer:(NSDictionary *)dict{
    
    Comment *comment;
    NSArray *results = [Plan fetchWith:@"Comment"
                             predicate:[NSPredicate predicateWithFormat:@"commentId == %@",dict[@"id"]]
                      keyForDescriptor:@"commentId"]; //utility method from Plan+PlanCRUD.h
    NSAssert(results.count <= 1, @"ownerId must be a unique!");
    if (!results.count) {
        comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:[AppDelegate getContext]];
    }else{
        comment = results.lastObject;
    }
    comment.commentId = dict[@"id"];
    comment.content = dict[@"content"];
    comment.createTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
    comment.isMyComment = @([dict[@"ownerId"] isEqualToString:[User uid]]);
    NSString *commentTo = dict[@"commentTo"]; //this is what differential reply and comment
    
    if (![commentTo isKindOfClass:[NSNull class]] && ![commentTo isEqualToString:@""]) { //for cases where commentTo = "<null>";
        comment.idForReply = commentTo;
    }
    
    return comment;
}

+ (Comment *)createComment:(NSString *)content commentId:(NSString *)commendId forFeed:(Feed *)feed{


    Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                     inManagedObjectContext:[AppDelegate getContext]];
    comment.commentId = commendId;
    comment.content = content;
    comment.createTime = [NSDate date];
    comment.feed = feed;
    comment.owner = [Owner updateOwnerFromServer:@{@"headUrl":[User updatedProfilePictureId],
                                                   @"id":[User uid],
                                                   @"name":[User userDisplayName]}];
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
