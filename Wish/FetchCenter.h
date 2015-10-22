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
#import "Comment+CRUD.h"
#import "FetchCenter.h"
#import "AppDelegate.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
#import "Message+MessageCRUD.h"
#import "TXYUploadManager.h"
#import "SDWebImageManager.h"
#import "Circle.h"
#define INNER_NETWORK_URL @"http://182.254.167.228"
#define OUTTER_NETWORK_URL @"http://120.24.73.51"
#define SHOULD_USE_INNER_NETWORK @"kShouldUSeInnerNetwork"

typedef enum {
    FetchCenterImageSizeOriginal = 0,
    FetchCenterImageSize50 = 50,
    FetchCenterImageSize100 = 100,
    FetchCenterImageSize200 = 200,
    FetchCenterImageSize400 = 400,
    FetchCenterImageSize800 = 800
}FetchCenterImageSize;

@protocol FetchCenterDelegate <NSObject>
@optional
- (void)didFinishFetchingFollowingPlanList:(NSArray *)planIds;
- (void)didFinishUploadingPlan:(Plan *)plan;
- (void)didFinishUploadingFeed:(Feed *)feed;

- (void)didFinishUploadingImage:(NSArray *)imageIds forFeed:(Feed *)feed;
- (void)didReceivedCurrentProgressForUploadingImage:(CGFloat)percentage;

- (void)didFinishReceivingUidAndUKeyForUserInfo:(NSDictionary *)userInfo isNewUser:(BOOL)isNew;
- (void)didFinishGettingWeChatUserInfo;
- (void)didFinishUpdatingPlan:(Plan *)plan;
- (void)didFinishCheckingNewVersion:(BOOL)hasNewVersion;
- (void)didFinishUploadingPictureForProfile;
- (void)didfinishFetchingDiscovery:(NSArray *)plans circleTitle:(NSString *)title;
- (void)didFinishSettingPersonalInfo;
- (void)didFinishSendingFeedBack;
- (void)didFinishLoadingFeedList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage serverFeedIdList:(NSArray *)serverFeedIds;
- (void)didFinishDeletingFeed:(Feed *)feed;



- (void)didFinishLikingFeed:(Feed *)feed;
- (void)didFinishUnLikingFeed:(Feed *)feed;
- (void)didFinishCommentingFeed:(Feed *)feed commentId:(NSString *)commentId;
- (void)didFinishLoadingCommentList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage forFeed:(Feed *)feed;
- (void)didFinishDeletingComment:(Comment *)comment;

- (void)didFinishFollowingPlan:(Plan *)plan;
- (void)didFinishUnFollowingPlan:(Plan *)plan;

- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject;
- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject;

- (void)didFinishGettingMessageNotificationWithMessageCount:(NSNumber *)msgCount followCount:(NSNumber *)followCount;
- (void)didFinishClearingAllMessages;

- (void)didfinishGettingSignature;
@end

typedef void(^FetchCenterGetRequestPlanCreationCompleted)(void); //创建事件完成
typedef void(^FetchCenterGetRequestGetCircleListCompleted)(NSArray *circles); //请求圈子列表完成
typedef void(^FetchCenterGetRequestSwithCircleCompleted)(void); //切换圈子

@interface FetchCenter : NSObject
@property (nonatomic,weak) id <FetchCenterDelegate>delegate;
@property (nonatomic,strong) NSString *buildVersion;
@property (nonatomic,strong) TXYUploadManager *uploadManager;

+ (NSString *)requestLogFilePath;

#pragma mark - 圈子

/**
 * 获取圈子列表
 *
 * @param completionBlock 返回圈子列表数组
 */
- (void)getCircleList:(FetchCenterGetRequestGetCircleListCompleted)completionBlock;

/**
 * 切换圈子
 * @param circleId 目标圈子的id
 */
- (void)switchToCircle:(NSString *)circleId completion:(FetchCenterGetRequestSwithCircleCompleted)completionBlock;

#pragma mark - 消息
- (void)clearAllMessages;
- (void)getMessageList;
- (void)getMessageNotificationInfo;

#pragma mark - 事件动态，（Feed）
- (void)loadFeedsListForPlan:(Plan *)plan pageInfo:(NSDictionary *)info;
- (void)likeFeed:(Feed *)feed;
- (void)unLikeFeed:(Feed *)feed;
- (void)deleteFeed:(Feed *)feed;
- (void)uploadImages:(NSArray *)images toCreateFeed:(Feed *)feed;
- (void)uploadToCreateFeed:(Feed *)feed fetchedImageIds:(NSArray *)imageIds;

#pragma mark - 评论回复
- (void)commentOnFeed:(Feed *)feed content:(NSString *)text;
- (void)replyAtFeed:(Feed *)feed content:(NSString *)text toOwner:(Owner *)owner;
- (void)getCommentListForFeed:(NSString *)feedId pageInfo:(NSDictionary *)info;
- (void)deleteComment:(Comment *)comment;

#pragma mark - 事件
- (void)fetchPlanListForOwnerId:(NSString *)ownerId;
- (void)uploadToCreatePlan:(Plan *)plan
                completion:(FetchCenterGetRequestPlanCreationCompleted)completionBlock;
- (void)updatePlan:(Plan *)plan;
- (void)postToDeletePlan:(Plan *)plan;
- (void)updateStatus:(Plan *)plan;

#pragma mark - 关注
- (void)followPlan:(Plan *)plan;
- (void)unFollowPlan:(Plan *)plan;

#pragma mark - 发现
- (void)getDiscoveryList;
- (void)fetchFollowingPlanList;

#pragma mark - 个人
- (void)sendFeedback:(NSString *)content content:(NSString *)email;
- (void)checkVersion;
- (void)uploadNewProfilePicture:(UIImage *)picture;
- (void)setPersonalInfo:(NSString *)nickName
                 gender:(NSString *)gender
                imageId:(NSString *)imageId 
             occupation:(NSString *)occupation
           personalInfo:(NSString *)info;

#pragma mark - ultility
- (NSURL *)urlWithImageID:(NSString *)imageId size:(FetchCenterImageSize)size;

#pragma mark - 登陆
- (void)fetchUidandUkeyWithOpenId:(NSString *)openId accessToken:(NSString *)token;
- (void)fetchAccessTokenWithWechatCode:(NSString *)code;
- (void)fetchWechatUserInfoWithOpenID:(NSString *)openID token:(NSString *)accessToken;

#pragma mark - 优图
- (void)requestSignature;
@end

