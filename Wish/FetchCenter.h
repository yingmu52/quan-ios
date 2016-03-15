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
- (void)didFinishUploadingImage:(NSArray *)imageIds forFeed:(Feed *)feed;
- (void)didReceivedCurrentProgressForUploadingImage:(CGFloat)percentage;
- (void)didFailUploadingImage:(UIImage *)image;

/** GET请求的失败回调函数*/
- (void)didFailSendingRequest;
@end

/** 创建事件完成*/
typedef void(^FetchCenterGetRequestPlanCreationCompleted)(Plan *plan);
/** 请求圈子列表完成*/
typedef void(^FetchCenterGetRequestGetCircleListCompleted)(NSArray *circleIds);
/** 切换圈子完成*/
typedef void(^FetchCenterGetRequestSwithCircleCompleted)(void);
/** 填写邀请码完成*/
typedef void(^FetchCenterGetRequestJoinCircleCompleted)(NSString *circleId);
/** 发现页拉取列表完成*/
typedef void(^FetchCenterGetRequestGetDiscoverListCompleted)(NSString *circleTitle);
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
/** 拉取关注事件列表完成*/
typedef void(^FetchCenterGetRequestGetFollowingPlanListCompleted)(NSArray *planIds);
/** 测试是否有新版本完成*/
typedef void(^FetchCenterGetRequestCheckVersionCompleted)(BOOL hasNewVersion);
/** 反馈完成*/
typedef void(^FetchCenterGetRequestSendFeedbackCompleted)(void);
/** 优图签名完成*/
typedef void(^FetchCenterGetRequestGetYoutuSignatureCompleted)(NSString *signature);
/** 登陆并获取uid和ukey完成*/
typedef void(^FetchCenterGetRequestGetUidAndUkeyCompleted)(NSDictionary *userInfo, BOOL isNewUser);
/** 微信拉取用户信息完成*/
typedef void(^FetchCenterGetRequestGetWechatUserInfoCompleted)(void);
/** 微信拉取用户信息完成*/
typedef void(^FetchCenterGetRequestGetFeedsListCompleted)(NSDictionary *pageInfo, BOOL hasNextPage, NSArray *feedIds);
/** 消息提醒完成*/
typedef void(^FetchCenterGetRequestGetMessageNotificationCompleted)(NSNumber *messageCount,NSNumber *followCount);
/** 拉取消息列表完成*/
typedef void(^FetchCenterGetRequestGetMessageListCompleted)(NSArray *messages);
/** 清空消息列表完成*/
typedef void(^FetchCenterGetRequestClearMessageListCompleted)(void);
/** 设置用户信息完成*/
typedef void(^FetchCenterGetRequestSetPersonalInfoCompleted)(void);
/** 评论或回复完成*/
typedef void(^FetchCenterGetRequestCommentCompleted)(Comment *comment);
/** 摘取评论列表完成*/
typedef void(^FetchCenterGetRequestGetCommentListCompleted)(NSDictionary *pageInfo, BOOL hasNextPage, NSArray *comments, Feed *feed);
/** 删除评论完成*/
typedef void(^FetchCenterGetRequestDeleteCommentCompleted)(void);
/** 上传图片完成*/
typedef void(^FetchCenterPostRequestUploadImagesCompleted)(NSArray *imageIds);


@interface FetchCenter : NSObject
@property (nonatomic,weak) id <FetchCenterDelegate>delegate;
@property (nonatomic,strong) NSString *buildVersion;
@property (nonatomic,strong) TXYUploadManager *uploadManager;

+ (NSString *)requestLogFilePath;

#pragma mark - 圈子

/** 删除成员 **/
typedef void(^FetchCenterGetRequestDeleteMemberCompleted)(void);
- (void)deleteMember:(NSString *)memberID
            inCircle:(NSString *)circleID
          completion:(FetchCenterGetRequestDeleteMemberCompleted)completionBlock;

/** 圈子成员列表 **/
typedef void(^FetchCenterGetRequestGetMemberListCompleted)(NSArray *memberIDs);
- (void)getMemberListForCircle:(Circle *)circle
                       completion:(FetchCenterGetRequestGetMemberListCompleted)completionBlock;

/** 设置圈子资料*/
typedef void(^FetchCenterGetRequestUpdateCircleCompleted)(void);
- (void)updateCircle:(NSString *)circleId
                name:(NSString *)circleName
         description:(NSString *)circleDescription
     backgroundImage:(NSString *)imageId
          completion:(FetchCenterGetRequestUpdateCircleCompleted)completionBlock;

/** 创建圈子*/
typedef void(^FetchCenterGetRequestCreateCircleCompleted)(Circle *circle);
- (void)createCircle:(NSString *)circleName
         description:(NSString *)circleDescription
   backgroundImageId:(NSString *)imageId
          completion:(FetchCenterGetRequestCreateCircleCompleted)completionBlock;


/** 删除圈子*/
typedef void(^FetchCenterGetRequestDeleteCircleCompleted)(BOOL isCurrentLegalToDelete);
- (void)deleteCircle:(Circle *)circle completion:(FetchCenterGetRequestDeleteCircleCompleted)completionBlock;

/**加入圈子*/
- (void)joinCircle:(NSString *)invitationCode completion:(FetchCenterGetRequestJoinCircleCompleted)completionBlock;

/**获取圈子列表*/
- (void)getCircleList:(FetchCenterGetRequestGetCircleListCompleted)completionBlock;

/**切换圈子*/
- (void)switchToCircle:(NSString *)circleId completion:(FetchCenterGetRequestSwithCircleCompleted)completionBlock;

#pragma mark - 消息
- (void)clearAllMessages:(FetchCenterGetRequestClearMessageListCompleted)completionBlock;
- (void)getMessageList:(FetchCenterGetRequestGetMessageListCompleted)completionBlock;
- (void)getMessageNotificationInfo:(FetchCenterGetRequestGetMessageNotificationCompleted)completionBlock;

#pragma mark - 事件动态，（Feed）
- (void)loadFeedsListForPlan:(Plan *)plan
                    pageInfo:(NSDictionary *)info
                  completion:(FetchCenterGetRequestGetFeedsListCompleted)completionBlock;

/**赞*/
- (void)likeFeed:(Feed *)feed completion:(FetchCenterGetRequestLikeFeedCompleted)completionBlock;

/**取消赞*/
- (void)unLikeFeed:(Feed *)feed completion:(FetchCenterGetRequestUnLikeFeedCompleted)completionBlock;

- (void)deleteFeed:(Feed *)feed completion:(FetchCenterGetRequestDeleteFeedCompleted)completionBlock;

- (void)uploadImages:(NSArray *)images
          completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock;

- (void)uploadToCreateFeed:(Feed *)feed
           fetchedImageIds:(NSArray *)imageIds
                completion:(FetchCenterGetRequestUploadFeedCompleted)completionBlock;

#pragma mark - 评论回复
- (void)commentOnFeed:(Feed *)feed
              content:(NSString *)text
           completion:(FetchCenterGetRequestCommentCompleted)completionBlock;

- (void)replyAtFeed:(Feed *)feed
            content:(NSString *)text
            toOwner:(Owner *)owner
         completion:(FetchCenterGetRequestCommentCompleted)completionBlock;


- (void)getCommentListForFeed:(NSString *)feedId
                     pageInfo:(NSDictionary *)info
                   completion:(FetchCenterGetRequestGetCommentListCompleted)completionBlock;

- (void)deleteComment:(Comment *)comment
           completion:(FetchCenterGetRequestDeleteCommentCompleted)completionBlock;;

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
- (void)getDiscoveryList:(NSMutableArray *)currentPlans
              completion:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock;

- (void)getFollowingPlanList:(FetchCenterGetRequestGetFollowingPlanListCompleted)completionBlock;

#pragma mark - 个人
- (void)sendFeedback:(NSString *)content
             content:(NSString *)email
          completion:(FetchCenterGetRequestSendFeedbackCompleted)completionBlock;

- (void)checkVersion:(FetchCenterGetRequestCheckVersionCompleted)completionBlock;
- (void)uploadNewProfilePicture:(UIImage *)picture
                     completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock;
;
- (void)setPersonalInfo:(NSString *)nickName
                 gender:(NSString *)gender
                imageId:(NSString *)imageId 
             occupation:(NSString *)occupation
           personalInfo:(NSString *)info
             completion:(FetchCenterGetRequestSetPersonalInfoCompleted)completionBlock;;

#pragma mark - 工具
- (NSURL *)urlWithImageID:(NSString *)imageId size:(FetchCenterImageSize)size;

typedef void(^FetchCenterImageUploadCompletionBlock)(NSString *fetchedId); //上传图像成功
typedef void(^FetchCenterGetRequestCompletionBlock)(NSDictionary *responseJson); //请求成功
- (void)postImageWithOperation:(UIImage *)image
                      complete:(FetchCenterImageUploadCompletionBlock)completionBlock;
#pragma mark - 登陆
- (void)getUidandUkeyWithOpenId:(NSString *)openId
                    accessToken:(NSString *)token
                     completion:(FetchCenterGetRequestGetUidAndUkeyCompleted)completionBlock;

- (void)getAccessTokenWithWechatCode:(NSString *)code
                          completion:(FetchCenterGetRequestGetUidAndUkeyCompleted)completionBlock;

- (void)getWechatUserInfoWithOpenID:(NSString *)openID
                              token:(NSString *)accessToken
                         completion:(FetchCenterGetRequestGetWechatUserInfoCompleted)completionBlock;

#pragma mark - 优图
- (void)requestSignature:(FetchCenterGetRequestGetYoutuSignatureCompleted)completionBlock;
@end

