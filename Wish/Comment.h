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
