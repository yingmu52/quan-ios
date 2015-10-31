//
//  FetchCenter.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plan.h"
#import "Feed.h"
#import "SystemUtil.h"
#import "Owner.h"
#import "Comment.h"
#import "FetchCenter.h"
#import "AppDelegate.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
#import "Message.h"
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
/** 新版请求的失败回调函数*/
- (void)didFailSendingRequest;

- (void)didFinishGettingMessageNotificationWithMessageCount:(NSNumber *)msgCount followCount:(NSNumber *)followCount;
- (void)didFinishClearingAllMessages;

- (void)didfinishGettingSignature;
@end

/** 创建事件完成*/
typedef void(^FetchCenterGetRequestPlanCreationCompleted)(Plan *plan);
/** 请求圈子列表完成*/
typedef void(^FetchCenterGetRequestGetCircleListCompleted)(NSArray *circles);
/** 切换圈子完成*/
typedef void(^FetchCenterGetRequestSwithCircleCompleted)(void);
/** 填写邀请码完成*/
typedef void(^FetchCenterGetRequestJoinCircleCompleted)(NSString *circleId);
/** 发现页拉取列表完成*/
typedef void(^FetchCenterGetRequestGetDiscoverListCompleted)(NSMutableArray *plans, NSString *circleTitle);
/** 拉取主人id的事件列表完成*/
typedef void(^FetchCenterGetRequestGetPlanListCompleted)(NSArray *plans);
/** 赞某条Feed完成*/
typedef void(^FetchCenterGetRequestLikeFeedCompleted)(void);
/** 不赞某条Feed完成*/
typedef void(^FetchCenterGetRequestUnLikeFeedCompleted)(void);
/** 更新事件完成*/
typedef void(^FetchCenterGetRequestUpdatePlanCompleted)(void);
/** 更新事件状态完成*/
typedef void(^FetchCenterGetRequestUpdatePlanStatusCompleted)(void);
/** 更新事件状态完成*/
typedef void(^FetchCenterGetRequestDeletePlanCompleted)(void);
/** 上传Feed完成*/
typedef void(^FetchCenterGetRequestUploadFeedCompleted)(Feed *feed);
/** 删除Feed完成*/
typedef void(^FetchCenterGetRequestDeleteFeedCompleted)(void);
/** 关注事件完成*/
typedef void(^FetchCenterGetRequestFollowPlanCompleted)(void);
/** 取消关注事件完成*/
typedef void(^FetchCenterGetRequestUnFollowPlanCompleted)(void);


@interface FetchCenter : NSObject
@property (nonatomic,weak) id <FetchCenterDelegate>delegate;
@property (nonatomic,strong) NSString *buildVersion;
@property (nonatomic,strong) TXYUploadManager *uploadManager;

+ (NSString *)requestLogFilePath;

#pragma mark - 圈子

/**加入圈子*/
- (void)joinCircle:(NSString *)invitationCode completion:(FetchCenterGetRequestJoinCircleCompleted)completionBlock;

/**获取圈子列表*/
- (void)getCircleList:(FetchCenterGetRequestGetCircleListCompleted)completionBlock;

/**切换圈子*/
- (void)switchToCircle:(NSString *)circleId completion:(FetchCenterGetRequestSwithCircleCompleted)completionBlock;

#pragma mark - 消息
- (void)clearAllMessages;
- (void)getMessageList;
- (void)getMessageNotificationInfo;

#pragma mark - 事件动态，（Feed）
- (void)loadFeedsListForPlan:(Plan *)plan pageInfo:(NSDictionary *)info;

/**赞*/
- (void)likeFeed:(Feed *)feed completion:(FetchCenterGetRequestLikeFeedCompleted)completionBlock;

/**取消赞*/
- (void)unLikeFeed:(Feed *)feed completion:(FetchCenterGetRequestUnLikeFeedCompleted)completionBlock;

- (void)deleteFeed:(Feed *)feed completion:(FetchCenterGetRequestDeleteFeedCompleted)completionBlock;;
- (void)uploadImages:(NSArray *)images toCreateFeed:(Feed *)feed;
- (void)uploadToCreateFeed:(Feed *)feed
           fetchedImageIds:(NSArray *)imageIds
                completion:(FetchCenterGetRequestUploadFeedCompleted)completionBlock;;

#pragma mark - 评论回复
- (void)commentOnFeed:(Feed *)feed content:(NSString *)text;
- (void)replyAtFeed:(Feed *)feed content:(NSString *)text toOwner:(Owner *)owner;
- (void)getCommentListForFeed:(NSString *)feedId pageInfo:(NSDictionary *)info;
- (void)deleteComment:(Comment *)comment;

#pragma mark - 事件

/**拉取主人id的事件列表*/
- (void)getPlanListForOwnerId:(NSString *)ownerId
                   completion:(FetchCenterGetRequestGetPlanListCompleted)completionBlock;

- (void)uploadToCreatePlan:(Plan *)plan
                completion:(FetchCenterGetRequestPlanCreationCompleted)completionBlock;
- (void)updatePlan:(Plan *)plan completion:(FetchCenterGetRequestUpdatePlanCompleted)completionBlock;
- (void)postToDeletePlan:(Plan *)plan completion:(FetchCenterGetRequestDeletePlanCompleted)completionBlock;
- (void)updateStatus:(Plan *)plan completion:(FetchCenterGetRequestUpdatePlanStatusCompleted)completionBlock;

#pragma mark - 关注
- (void)followPlan:(Plan *)plan completion:(FetchCenterGetRequestFollowPlanCompleted)completionBlock;
- (void)unFollowPlan:(Plan *)plan completion:(FetchCenterGetRequestUnFollowPlanCompleted)completionBlock;;

#pragma mark - 发现
- (void)getDiscoveryList:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock;
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

