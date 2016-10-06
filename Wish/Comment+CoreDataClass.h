//
//  Comment+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBase+CoreDataClass.h"

@class Feed, Owner;

NS_ASSUME_NONNULL_BEGIN

@interface Comment : MSBase


+ (Comment *)updateCommentWithInfo:(NSDictionary *)dict
                         ownerInfo:(NSDictionary *)ownerInfo
                            inFeed:(Feed *)feed
              managedObjectContext:(NSManagedObjectContext *)context;



+ (Comment *)createComment:(NSString *)content
                 commentId:(NSString *)commendId
                 forFeedID:(NSString *)feedID
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Comment *)replyToOwner:(NSString *)ownerID
                ownerName:(NSString *)ownerName
                  content:(NSString *)content
                commentId:(NSString *)commentId
                forFeedID:(NSString *)feedID
   inManagedObjectContext:(NSManagedObjectContext *)context;


@end

NS_ASSUME_NONNULL_END

#import "Comment+CoreDataProperties.h"
