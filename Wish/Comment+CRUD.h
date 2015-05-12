//
//  Comment+CRUD.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-08.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Comment.h"

@interface Comment (CRUD)
+ (Comment *)updateCommentFromServer:(NSDictionary *)dict;
+ (Comment *)createComment:(NSString *)content commentId:(NSString *)commendId forFeed:(Feed *)feed;
+ (Comment *)replyToOwner:(Owner *)owner content:(NSString *)text commentId:(NSString *)commentId forFeed:(Feed *)feed;
@end
