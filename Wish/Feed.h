//
//  Feed.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Plan;

NS_ASSUME_NONNULL_BEGIN

@interface Feed : NSManagedObject

typedef enum {
    FeedTypeLegacy = 0, //单图
    FeedTypeNoPicture,
    FeedTypeSinglePicture,
    FeedTypeMultiplePicture
}FeedType;

typedef void(^FeedCreationCompletion)(Feed *feed);

+ (void)createFeed:(NSString *)feedId
             title:(NSString *)feedTitle
            images:(NSArray *)imageIds
            planID:(NSString *)planId;

//+ (Feed *)createFeedInPlan:(Plan *)plan
//                 feedTitle:(NSString *)feedTitle
//                    feedId:(NSString *)feedId
//                  imageIds:(NSArray *)imageIds;
//
+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem
                     forPlan:(nullable NSDictionary *)planInfo
                   ownerInfo:(nullable NSDictionary *)ownerInfo
        managedObjectContext:(nonnull NSManagedObjectContext *)context;

    
+ (Feed *)fetchFeedWithId:(NSString *)feedId;

- (void)deleteSelf;

- (NSNumber *)numberOfPictures;
- (NSArray *)imageIdArray;

@end

NS_ASSUME_NONNULL_END

#import "Feed+CoreDataProperties.h"
