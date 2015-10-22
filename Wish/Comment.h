//
//  Comment.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed, Owner;

NS_ASSUME_NONNULL_BEGIN

@interface Comment : NSManagedObject

+ (Comment *)updateCommentWithInfo:(NSDictionary *)dict;
+ (Comment *)createComment:(NSString *)content commentId:(NSString *)commendId forFeed:(Feed *)feed;
+ (Comment *)replyToOwner:(Owner *)owner content:(NSString *)text commentId:(NSString *)commentId forFeed:(Feed *)feed;

@end

NS_ASSUME_NONNULL_END

#import "Comment+CoreDataProperties.h"
