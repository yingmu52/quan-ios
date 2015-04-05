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
#import "Owner+OwnerCRUD.h"


#define INNER_NETWORK_URL @"http://182.254.167.228"
#define OUTTER_NETWORK_URL @"http://120.24.73.51"

#define SHOULD_USE_OUTTER_NETWORK @"kShouldUSeOutterNetwork"

@protocol FetchCenterDelegate <NSObject>
@optional
- (void)didFinishFetchingFollowingPlanList;
- (void)didFinishUploadingPlan:(Plan *)plan;
- (void)didFinishUploadingFeed:(Feed *)feed;
- (void)didFinishReceivingUid:(NSString *)uid uKey:(NSString *)uKey;
- (void)didFinishUpdatingPlan:(Plan *)plan;
- (void)didFinishCheckingNewVersion:(BOOL)hasNewVersion;
- (void)didFinishUploadingPictureForProfile:(NSDictionary *)info;
- (void)didfinishFetchingDiscovery:(NSArray *)plans;
- (void)didFinishUpdatingPersonalInfo;
//- (void)didFinishCreatingPersonalInfo;
- (void)didFinishSendingFeedBack;


- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject;
- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject;


@end
@interface FetchCenter : NSObject
@property (nonatomic,weak) id <FetchCenterDelegate>delegate;



- (void)getDiscoveryList;


- (void)sendFeedback:(NSString *)title content:(NSString *)content;
- (void)checkVersion;
- (void)uploadNewProfilePicture:(UIImage *)picture;
- (void)updatePersonalInfo:(NSString *)nickName gender:(NSString *)gender;
//- (void)createPersonalInfo:(NSString *)nickName gender:(NSString *)gender;


- (void)likeFeed:(Feed *)feed;
- (void)unLikeFeed:(Feed *)feed;


- (void)fetchPlanList:(NSString *)ownerId;
- (void)uploadToCreatePlan:(Plan *)plan;
- (void)updatePlan:(Plan *)plan;
- (void)postToDeletePlan:(Plan *)plan;
- (void)uploadToCreateFeed:(Feed *)feed;
- (void)updateStatus:(Plan *)plan;

- (void)fetchFollowingPlanList;

- (NSURL *)urlWithImageID:(NSString *)imageId;

- (void)fetchUidandUkeyWithOpenId:(NSString *)openId accessToken:(NSString *)token;

@end
