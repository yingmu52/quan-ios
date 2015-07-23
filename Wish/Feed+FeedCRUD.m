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
    
    NSManagedObjectContext *context = [AppDelegate getContext];
    
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:context];
    
    feed.image = image;
    feed.createDate = [NSDate date];
    feed.plan = plan;
    feed.selfLiked = @(NO);
    return feed;
}

+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem forPlan:(Plan *)plan{
    NSArray *checks = [Plan fetchWith:@"Feed"
                            predicate:[NSPredicate predicateWithFormat:@"feedId == %@",feedItem[@"id"]]
                     keyForDescriptor:@"createDate"];
    NSManagedObjectContext *context = [AppDelegate getContext];
    Feed *feed;
    NSAssert(checks.count <= 1, @"non unique feed found");
    if (!checks.count) {
        //create
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                                   inManagedObjectContext:context];
        feed.feedId = feedItem[@"id"];
        feed.imageId = feedItem[@"picurl"];
        if (plan) feed.plan = plan;
        
#warning move these line down when the server supports identifiying wether isSelfLiked
        feed.selfLiked = @(NO);
        feed.feedTitle = feedItem[@"content"];
        feed.createDate = [NSDate dateWithTimeIntervalSince1970:[feedItem[@"createTime"] integerValue]];

        
    }else{
        //update
        feed = checks.lastObject;
        
    }

    if (![feed.likeCount isEqualToNumber:@([feedItem[@"likeTimes"] integerValue])]){
        feed.likeCount = @([feedItem[@"likeTimes"] integerValue]);
    }

    if (![feed.commentCount isEqualToNumber:@([feedItem[@"commentTimes"] integerValue])]){
        feed.commentCount = @([feedItem[@"commentTimes"] integerValue]);
    }


    
    return feed;
}

+ (Feed *)fetchFeedWithId:(NSString *)feedId{
    NSArray *results = [Plan fetchWith:@"Feed"
                             predicate:[NSPredicate predicateWithFormat:@"feedId = %@",feedId]
                      keyForDescriptor:@"createDate"];
    NSAssert(results.count <= 1, @"feed id is not unique");
    return results.lastObject;
}

- (void)deleteSelf{
    
    NSArray *sortedArray = [self.plan.feeds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]]];
    Feed *firstFeed = [sortedArray firstObject];
    Feed *second = [sortedArray objectAtIndex:1];
    if ([self.feedId isEqualToString:firstFeed.feedId]){
        //delete plan image
        self.plan.image = second.image;
        self.plan.backgroundNum = second.imageId;
    }

    //delete Feed
    [[AppDelegate getContext] deleteObject:self];
    //tryTime - 1
    self.plan.tryTimes = @(self.plan.tryTimes.integerValue - 1);
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];

}
@end


