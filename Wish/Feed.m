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
    Plan *plan = [Plan fetchWith:@"Plan"
                       predicate:[NSPredicate predicateWithFormat:@"mUID == %@",planId]
                keyForDescriptor:@"mUID"
            managedObjectContext:context].lastObject;
    
    Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:context];
    NSLog(@"create feed locally %@",feedId);
    feed.feedId = feedId;
    [plan updateTryTimesOfPlan:YES];
    feed.feedTitle = feedTitle;
    feed.createDate = [NSDate date];
    feed.imageId = imageIds.firstObject;
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
    
    NSArray *checks = [Plan fetchWith:@"Feed"
                            predicate:[NSPredicate predicateWithFormat:@"feedId == %@",feedItem[@"id"]]
                     keyForDescriptor:@"createDate"
                 managedObjectContext:context];
    
    Feed *feed;

    if (checks.count == 0) {
        
//        NSLog(@"%@",feedItem[@"id"]);
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                             inManagedObjectContext:context];
        feed.feedId = feedItem[@"id"];
        feed.selfLiked = @(NO);
        feed.feedTitle = feedItem[@"content"];
        feed.createDate = [NSDate dateWithTimeIntervalSince1970:[feedItem[@"createTime"] integerValue]];
        if (plan) {
            feed.plan = plan;
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
    return results.lastObject;
}


#pragma mark - picUrls

- (NSNumber *)numberOfPictures{
    return @([self imageIdArray].count);
}

- (NSArray *)imageIdArray{
    return [self.picUrls componentsSeparatedByString:@","];
}

@end
