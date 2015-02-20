//
//  Feed+FeedCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-29.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Feed+FeedCRUD.h"
#import "FetchCenter.h"
@implementation Feed (FeedCRUD)

+ (Feed *)createFeed:(NSString *)title image:(UIImage *)image inPlan:(Plan *)plan{
    
    NSManagedObjectContext *context = plan.managedObjectContext;
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:context];
    
    feed.feedTitle = title;
    feed.image = image;
    feed.createDate = [NSDate date];
    feed.plan = plan;

    
    //update plan
    plan.image = image;
    if ([context save:nil]) {
        //upload to server
//        [FetchCenter uploadToCreateFeed:feed];
        [[[FetchCenter alloc] init] uploadToCreateFeed:feed];
    }

    return feed;
}



@end
