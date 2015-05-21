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

@interface Feed (FeedCRUD)
+ (Feed *)createFeedWithImage:(UIImage *)image inPlan:(Plan *)plan;

+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem forPlan:(Plan *)plan;

@end
