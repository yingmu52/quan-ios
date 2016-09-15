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
#define TEST_URL @"http://121.42.179.193"
#define PROD_URL @"http://120.24.157.16" // 120.24.73.51
#define SHOULD_USE_TESTURL @"kShouldUSeInnerNetwork"

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
- (void)didReceivedCurrentProgressForUploadingImage:(CGFloat)percentage;
- (void)didFailUploadingImage:(UIImage *)image;
- (void)didFailToReachInternet;
/** GET请求的失败回调函数*/
- (void)didFailSendingRequest;
@end

/** 切换圈子完成*/
typedef void(^FetchCenterGetRequestSwithCircleCompleted)(void);

/** 赞某条Feed完成*/
typedef void(^FetchCenterGetRequestLikeFeedCompleted)(void);
/** 不赞某条Feed完成*/
typedef void(^FetchCenterGetRequestUnLikeFeedCompleted)(void);

/** 删除Feed完成*/
typedef void(^FetchCenterGetRequestDeleteFeedCompleted)(void);
/** 关注事件完成*/
typedef void(^FetchCenterGetRequestFollowPlanCompleted)(void);
/** 取消关注事件完成*/
typedef void(^FetchCenterGetRequestUnFollowPlanCompleted)(void);
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

/** 消息提醒完成*/
typedef void(^FetchCenterGetRequestGetMessageNotificationCompleted)(NSNumber *messageCount,NSNumber *followCount);
/** 清空消息列表完成*/
typedef void(^FetchCenterGetRequestClearMessageListCompleted)(void);
/** 设置用户信息完成*/
typedef void(^FetchCenterGetRequestSetPersonalInfoCompleted)(void);

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

/** 退出圈子 **/
typedef void(^FetchCenterGetRequestGetQuitCircleCompleted)(void);
- (void)quitCircle:(NSString *)circleId completion:(FetchCenterGetRequestGetQuitCircleCompleted)completionBlock;

/** 获取分享页URL **/
typedef void(^FetchCenterGetRequestGetCircleInvitationURLCompleted)(NSString *urlString);
- (void)getH5invitationUrlWithCircleId:(NSString *)circleId
                            completion:(FetchCenterGetRequestGetCircleInvitationURLCompleted)completionBlock;

/** 获取圈子里的事件列表 **/
typedef void(^FetchCenterGetRequestGetCirclePlanListCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getPlanListInCircleId:(NSString *)circleId
                    localList:(NSArray *)localList
                       onPage:(NSNumber *)localPage
         completion:(FetchCenterGetRequestGetCirclePlanListCompleted)completionBlock;

/** 删除成员 **/
typedef void(^FetchCenterGetRequestDeleteMemberCompleted)(void);
- (void)deleteMember:(NSString *)memberID
            inCircle:(NSString *)circleID
          completion:(FetchCenterGetRequestDeleteMemberCompleted)completionBlock;

/** 圈子成员列表 **/

typedef void(^FetchCenterGetRequestGetMemberListCompleted)(NSArray *memberIDs);
- (void)getMemberListForCircleId:(NSString *)circleId
                       localList:(NSArray *)localList
                      completion:(FetchCenterGetRequestGetMemberListCompleted)completionBlock;

/** 设置圈子资料*/
typedef void(^FetchCenterGetRequestUpdateCircleCompleted)(void);
- (void)updateCircle:(NSString *)circleId
                name:(NSString *)circleName
         description:(NSString *)circleDescription
     backgroundImage:(NSString *)imageId
          completion:(FetchCenterGetRequestUpdateCircleCompleted)completionBlock;

/** 创建圈子*/
typedef void(^FetchCenterGetRequestCreateCircleCompleted)(void);
- (void)createCircle:(NSString *)circleName
         description:(NSString *)circleDescription
   backgroundImageId:(NSString *)imageId
          completion:(FetchCenterGetRequestCreateCircleCompleted)completionBlock;


/** 删除圈子*/
typedef void(^FetchCenterGetRequestDeleteCircleCompleted)(void);
- (void)deleteCircle:(NSString *)circleId completion:(FetchCenterGetRequestDeleteCircleCompleted)completionBlock;

/** 填写邀请码完成*/
typedef void(^FetchCenterGetRequestJoinCircleCompleted)(NSString *circleName);
/**加入圈子*/
- (void)joinCircleId:(NSString *)circleId
         nonceString:(NSString *)noncestr
           signature:(NSString *)signature
          expireTime:(NSString *)expireTime
          inviteCode:(NSString *)code
          completion:(FetchCenterGetRequestJoinCircleCompleted)completionBlock;

/**获取圈子列表*/
typedef void(^FetchCenterGetRequestGetCircleListCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getCircleList:(NSArray *)localList
               onPage:(NSNumber *)localPage
           completion:(FetchCenterGetRequestGetCircleListCompleted)completionBlock;

/**切换圈子*/
- (void)switchToCircle:(NSString *)circleId completion:(FetchCenterGetRequestSwithCircleCompleted)completionBlock;

#pragma mark - 消息
- (void)clearAllMessages:(FetchCenterGetRequestClearMessageListCompleted)completionBlock;


/** 拉取消息列表完成*/
typedef void(^FetchCenterGetRequestGetMessageListCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getMessageListWithLocalList:(NSArray *)localList
                             onPage:(NSNumber *)localPage
                         completion:(FetchCenterGetRequestGetMessageListCompleted)completionBlock;


- (void)getMessageNotificationInfo:(FetchCenterGetRequestGetMessageNotificationCompleted)completionBlock;

#pragma mark - 事件动态，（Feed）

typedef void(^FetchCenterGetRequestGetFeedsListCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getFeedsListForPlan:(NSString *)planId
                  localList:(NSArray *)localList
                     onPage:(NSNumber *)localPage
                 completion:(FetchCenterGetRequestGetFeedsListCompleted)completionBlock;

/**赞*/
- (void)likeFeed:(Feed *)feed completion:(FetchCenterGetRequestLikeFeedCompleted)completionBlock;

/**取消赞*/
- (void)unLikeFeed:(Feed *)feed completion:(FetchCenterGetRequestUnLikeFeedCompleted)completionBlock;

- (void)deleteFeed:(Feed *)feed completion:(FetchCenterGetRequestDeleteFeedCompleted)completionBlock;

- (void)uploadImages:(NSArray *)images
          completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock;

/** 上传Feed完成*/
typedef void(^FetchCenterGetRequestUploadFeedCompleted)(NSString *feedId);
- (void)createFeed:(NSString *)feedTitle
            planId:(NSString *)planId
   fetchedImageIds:(NSArray *)imageIds
        completion:(FetchCenterGetRequestUploadFeedCompleted)completionBlock;



#pragma mark - 评论回复
/** 评论或回复完成*/
typedef void(^FetchCenterGetRequestCommentCompleted)(void);

- (void)replyToFeedID:(NSString *)feedID
              content:(NSString *)text
            toOwnerID:(NSString *)ownerID
            ownerName:(NSString *)ownerName
           completion:(FetchCenterGetRequestCommentCompleted)completionBlock;

/** 摘取评论列表完成*/
typedef void(^FetchCenterGetRequestGetCommentListCompleted)(NSNumber *currentPage,
                                                            NSNumber *totalPage,
                                                            BOOL hasComments);
- (void)getCommentListForFeed:(NSString *)feedId
                    localList:(NSArray *)localList
                  currentPage:(NSNumber *)localCurrentPage
                   completion:(FetchCenterGetRequestGetCommentListCompleted)completionBlock;

- (void)deleteComment:(Comment *)comment
           completion:(FetchCenterGetRequestDeleteCommentCompleted)completionBlock;;

#pragma mark - 事件

/**拉取主人id的事件列表*/
typedef void(^FetchCenterGetRequestGetPlanListCompleted)(void);
- (void)getPlanListForOwnerId:(NSString *)ownerId
                    localList:(NSArray *)localList
                   completion:(FetchCenterGetRequestGetPlanListCompleted)completionBlock;

/** 创建事件*/
//typedef void(^FetchCenterGetRequestPlanCreationCompleted)(NSString *planId, NSString *backgroundID);
//- (void)createPlan:(NSString *)planTitle
//          circleId:(NSString *)circleId
//        completion:(FetchCenterGetRequestPlanCreationCompleted)completionBlock;

typedef void(^FetchCenterPostRequestPlanAndFeedCreationCompleted)(NSString *planId);
- (void)createPlan:(NSString *)planTitle
   planDescription:(NSString *)description
          circleID:(NSString *)circleId
           picurls:(NSArray *)picurls
         feedTitle:(NSString *)feedTitle
        completion:(FetchCenterPostRequestPlanAndFeedCreationCompleted)completionBlock;


/** 更新事件完成*/
typedef void(^FetchCenterGetRequestUpdatePlanCompleted)(void);
- (void)updatePlan:(NSString *)planId
             title:(NSString *)planTitle
         isPrivate:(BOOL)isPrivate
       description:(NSString *)planDescription
        completion:(FetchCenterGetRequestUpdatePlanCompleted)completionBlock;

/** 删除事件状态完成*/
typedef void(^FetchCenterGetRequestDeletePlanCompleted)(void);
- (void)deletePlanId:(NSString *)planId completion:(FetchCenterGetRequestDeletePlanCompleted)completionBlock;

/** 更新事件状态完成*/
typedef void(^FetchCenterGetRequestUpdatePlanStatusCompleted)(void);
- (void)updatePlanId:(NSString *)planId
          planStatus:(PlanStatus)planStatus
          completion:(FetchCenterGetRequestUpdatePlanStatusCompleted)completionBlock;

#pragma mark - 关注
- (void)followPlan:(Plan *)plan completion:(FetchCenterGetRequestFollowPlanCompleted)completionBlock;
- (void)unFollowPlan:(Plan *)plan completion:(FetchCenterGetRequestUnFollowPlanCompleted)completionBlock;;

/** 拉取关注事件列表完成*/
typedef void(^FetchCenterGetRequestGetFollowingPlanListCompleted)(void);
- (void)getFollowingList:(NSArray *)localList completion:(FetchCenterGetRequestGetFollowingPlanListCompleted)completionBlock;



#pragma mark - 发现
/** 发现页拉取列表完成*/
typedef void(^FetchCenterGetRequestGetDiscoverListCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getDiscoveryList:(NSArray *)localList
                  onPage:(NSNumber *)localPage
              completion:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock;

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

typedef void(^FetchCenterPostRequestSendDeviceTokenCompleted)(void);
- (void)sendDeviceToken:(NSString *)deviceToken completion:(FetchCenterPostRequestSendDeviceTokenCompleted)completionBlock;


- (NSURL *)urlWithImageID:(NSString *)imageId size:(FetchCenterImageSize)size;
- (void)syncEntity:(NSString *)entityName
            idName:(NSString *)uniqueID
         localList:(NSArray *)localList
        serverList:(NSArray *)serverList
         inContext:(NSManagedObjectContext *)workerContext;

typedef void(^FetchCenterGetRequestCheckWhitelistCompleted)(BOOL isSuperUser);
- (void)checkWhitelist:(FetchCenterGetRequestCheckWhitelistCompleted)completionBlock;

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

