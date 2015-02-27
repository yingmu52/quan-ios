//
//  FetchCenter.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plan+PlanCRUD.h"
#import "Feed+FeedCRUD.h"
#import "SystemUtil.h"


@protocol FetchCenterDelegate <NSObject>
@optional
- (void)didFinishFetchingFollowingPlanList;
@end
@interface FetchCenter : NSObject
@property (nonatomic,weak) id <FetchCenterDelegate>delegate;

- (void)fetchPlanList:(NSString *)ownerId;
- (void)uploadToCreatePlan:(Plan *)plan;
- (void)postToDeletePlan:(Plan *)plan;
- (void)uploadToCreateFeed:(Feed *)feed;
- (void)updateStatus:(Plan *)plan;

- (void)fetchFollowingPlanList:(NSArray *)ownerIds;

- (NSURL *)urlWithImageID:(NSString *)imageId;
@end
