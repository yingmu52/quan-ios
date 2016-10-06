//
//  Feed+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBase+CoreDataClass.h"

@class Comment, Plan;

NS_ASSUME_NONNULL_BEGIN

@interface Feed : MSBase

typedef enum {
    FeedTypeLegacy = 0, //单图
    FeedTypeNoPicture,
    FeedTypeSinglePicture,
    FeedTypeMultiplePicture
}FeedType;

typedef void(^FeedCreationCompletion)(Feed *feed);

+ (Feed *)createFeed:(NSString *)feedId
               title:(NSString *)feedTitle
              images:(NSArray *)imageIds
              planID:(NSString *)planId inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem
                     forPlan:(nullable Plan *)plan
        managedObjectContext:(nonnull NSManagedObjectContext *)context;


- (NSNumber *)numberOfPictures;
- (NSArray *)imageIdArray;


@end

NS_ASSUME_NONNULL_END

#import "Feed+CoreDataProperties.h"
