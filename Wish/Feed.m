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

+ (Feed *)createFeedInPlan:(Plan *)plan feedTitle:(NSString *)feedTitle feedId:(NSString *)feedId imageIds:(NSArray *)imageIds{
    //create feed
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:delegate.managedObjectContext];
    feed.feedId = feedId;
    [plan updateTryTimesOfPlan:YES];
    feed.feedTitle = feedTitle;
    feed.createDate = [NSDate date];
    feed.imageId = imageIds.firstObject;
    feed.picUrls = [imageIds componentsJoinedByString:@","];
    feed.type = @(imageIds.count > 1 ? FeedTypeMultiplePicture : FeedTypeSinglePicture);
    plan.backgroundNum = imageIds.firstObject;
    plan.updateDate = [NSDate date];
    feed.plan = plan;
    feed.selfLiked = @(NO);
    [delegate saveContext];
    return feed;
}

+ (Feed *)updateFeedWithInfo:(NSDictionary *)feedItem
                     forPlan:(nullable NSDictionary *)planInfo
                   ownerInfo:(nullable NSDictionary *)ownerInfo
        managedObjectContext:(nonnull NSManagedObjectContext *)context{
    
    NSArray *checks = [Plan fetchWith:@"Feed"
                            predicate:[NSPredicate predicateWithFormat:@"feedId == %@",feedItem[@"id"]]
                     keyForDescriptor:@"createDate"
                 managedObjectContext:context];
    
    Feed *feed;
    NSAssert(checks.count <= 1, @"non unique feed found");
    if (!checks.count) {
        //create
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                             inManagedObjectContext:context];
        feed.feedId = feedItem[@"id"];
//        feed.imageId = feedItem[@"picurl"];
        feed.selfLiked = @(NO);
        feed.feedTitle = feedItem[@"content"];
        feed.createDate = [NSDate dateWithTimeIntervalSince1970:[feedItem[@"createTime"] integerValue]];
        if (planInfo && ownerInfo) {
            feed.plan = [Plan updatePlanFromServer:planInfo ownerInfo:ownerInfo managedObjectContext:context];
        }
        
    }else{
        //update
        feed = checks.lastObject;
        
    }
    
    if (![feed.imageId isEqualToString:feedItem[@"picurl"]]) {
        feed.imageId = feedItem[@"picurl"];
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


+ (Feed *)fetchFeedWithId:(NSString *)feedId{
    NSArray *results = [Plan fetchWith:@"Feed"
                             predicate:[NSPredicate predicateWithFormat:@"feedId = %@",feedId]
                      keyForDescriptor:@"createDate"
                  managedObjectContext:[AppDelegate getContext]];
    
    NSAssert(results.count <= 1, @"feed id is not unique");
    return results.lastObject;
}


- (void)deleteSelf{
    
    NSArray *sortedArray = [self.plan.feeds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]]];
    Feed *firstFeed = [sortedArray firstObject];
    Feed *second = [sortedArray objectAtIndex:1];
    if ([self.feedId isEqualToString:firstFeed.feedId]){
        //delete plan image
        self.plan.backgroundNum = second.imageId;
    }
    
    //delete Feed
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.managedObjectContext deleteObject:self];
    //tryTime - 1
    self.plan.tryTimes = @(self.plan.tryTimes.integerValue - 1);
    [delegate saveContext];
}

#pragma mark - picUrls

- (NSNumber *)numberOfPictures{
    return @([self imageIdArray].count);
}

- (NSArray *)imageIdArray{
    return [self.picUrls componentsSeparatedByString:@","];
}

@end
