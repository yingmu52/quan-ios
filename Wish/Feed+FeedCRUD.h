//
//  Feed+FeedCRUD.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-29.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Feed.h"
#import "Plan.h"
@import UIKit;

@interface Feed (FeedCRUD)
+ (Feed *)createFeed:(NSString *)title image:(UIImage *)image inPlan:(Plan *)plan;
+ (Feed *)createFeedFromServer:(NSDictionary *)feedItem;
@end
