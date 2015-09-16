//
//  Feed+FeedCRUD.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-29.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Feed.h"
#import "Plan+PlanCRUD.h"
@import UIKit;

typedef enum {
    FeedTypeLegacy = 0, //单图
    FeedTypeNoPicture,
    FeedTypeSinglePicture,
    FeedTypeMultiplePicture
}FeedType;


@interface Feed (FeedCRUD)
+ (Feed *)createFeedInPlan:(Plan *)plan feedTitle:(NSString *)feedTitle;

+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem forPlan:(Plan *)plan;

+ (Feed *)fetchFeedWithId:(NSString *)feedId;

- (void)deleteSelf;
@end
