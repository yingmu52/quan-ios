//
//  Feed.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "Feed.h"
#import "Comment.h"
#import "Plan.h"
#import "FetchCenter.h"
#import "AppDelegate.h"

@implementation Feed

+ (Feed *)createFeed:(NSString *)feedId
               title:(NSString *)feedTitle
              images:(NSArray *)imageIds
              planID:(NSString *)planId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Plan *plan = [Plan fetchID:planId inManagedObjectContext:context];
    
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:context];
    NSLog(@"create feed locally %@",feedId);
    feed.mUID = feedId;
    [plan updateTryTimesOfPlan:YES];
    feed.mTitle = feedTitle;
    feed.mCreateTime = [NSDate date];
    feed.mCoverImageId = imageIds.firstObject;
    feed.picUrls = [imageIds componentsJoinedByString:@","];
    feed.type = @(imageIds.count > 1 ? FeedTypeMultiplePicture : FeedTypeSinglePicture);
    plan.mCoverImageId = imageIds.firstObject;
    plan.mUpdateTime = [NSDate date];
    feed.plan = plan;
    feed.selfLiked = @(NO);
    return feed;
}

+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem
                     forPlan:(nullable Plan *)plan
        managedObjectContext:(nonnull NSManagedObjectContext *)context{
    
    Feed *feed = [Feed fetchID:feedItem[@"id"] inManagedObjectContext:context];

    if (!feed) {
        
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                             inManagedObjectContext:context];
        feed.mUID = feedItem[@"id"];
        feed.selfLiked = @(NO);
        feed.mTitle = feedItem[@"content"];
        feed.mCreateTime = [NSDate dateWithTimeIntervalSince1970:[feedItem[@"createTime"] integerValue]];
        if (plan) {
            feed.plan = plan;
        }   
    }
    
    if (![feed.mCoverImageId isEqualToString:feedItem[@"picurl"]]) {
        feed.mCoverImageId = feedItem[@"picurl"];
    }
    
    if (![feed.likeCount isEqualToNumber:@([feedItem[@"likeTimes"] integerValue])]){
        feed.likeCount = @([feedItem[@"likeTimes"] integerValue]);
    }
    
    if (![feed.commentCount isEqualToNumber:@([feedItem[@"commentTimes"] integerValue])]){
        feed.commentCount = @([feedItem[@"commentTimes"] integerValue]);
    }
    
    if (![feed.picUrls isEqualToString:feedItem[@"picurls"]]) {
        feed.picUrls = feedItem[@"picurls"];
    }
    
    if (![feed.type isEqualToNumber:@([feedItem[@"feedsType"] integerValue])]){
        feed.type = @([feedItem[@"feedsType"] integerValue]);
    }
    
    return feed;
}

#pragma mark - picUrls

- (NSNumber *)numberOfPictures{
    return @([self imageIdArray].count);
}

- (NSArray *)imageIdArray{
    return [self.picUrls componentsSeparatedByString:@","];
}

@end
