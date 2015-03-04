//
//  Feed+FeedCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-29.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Feed+FeedCRUD.h"
#import "FetchCenter.h"
#import "AppDelegate.h"
@implementation Feed (FeedCRUD)

+ (Feed *)createFeedWithImage:(UIImage *)image inPlan:(Plan *)plan{
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:context];
    
//    feed.feedTitle = title;
    feed.image = image;
    feed.createDate = [NSDate date];
    feed.plan = plan;

    //update plan
    plan.image = image;
    NSLog(@"saved feed with image");
//    if ([context save:nil]) {
        //upload to server
//        [[[FetchCenter alloc] init] uploadToCreateFeed:feed];

//    }
    return feed;
}

+ (Feed *)createFeedFromServer:(NSDictionary *)feedItem forPlan:(Plan *)plan{
    NSArray *checks = [Plan fetchWith:@"Feed"
                            predicate:[NSPredicate predicateWithFormat:@"feedId == %@",feedItem[@"id"]]
                     keyForDescriptor:@"createDate"];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    Feed *feed;
    NSAssert(checks.count <= 1, @"non unique feed found");
    if (!checks.count) {
        //create
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                                   inManagedObjectContext:context];
    }else{
        //update
        feed = checks.lastObject;
        
    }
    feed.commentCount = @([feedItem[@"commentTimes"] integerValue]);
    feed.feedTitle = feedItem[@"content"];
    feed.createDate = [NSDate dateWithTimeIntervalSince1970:[feedItem[@"createTime"] integerValue]];
    feed.feedId = feedItem[@"id"];
    feed.likeCount = @([feedItem[@"likeTimes"] integerValue]);
    feed.imageId = feedItem[@"picurl"];
    feed.plan = plan;
    
    if ([context save:nil]) {
        NSLog(@"updated feed from server");
    }
    return feed;
}

@end
