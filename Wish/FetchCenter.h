//
//  FetchCenter.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plan+CoreDataClass.h"
#import "Feed+CoreDataClass.h"
#import "SystemUtil.h"
#import "Owner+CoreDataClass.h"
#import "Comment+CoreDataClass.h"
#import "FetchCenter.h"
#import "AppDelegate.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
#import "Message+CoreDataClass.h"
#import "TXYUploadManager.h"
#import "SDWebImageManager.h"
#import "Circle+CoreDataClass.h"
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
- (void)didFailUploadingImage:(UIImage *)image;
- (void)didFailToReachInternet;
/** GET请求的失败回调函数*/
- (void)didFailSendingRequest;
- (void)didFailSendingRequestWithMessage:(NSString *)message;
@end


//General Get Post completion block
typedef void(^FetchCenterPostRequestCompleted)(void);
typedef void(^FetchCenterGetRequestCompleted)(void);

typedef void(^FetchCenterGetRequestCheckVersionCompleted)(BOOL hasNewVersion);

typedef void(^FetchCenterGetRequestGetYoutuSignatureCompleted)(NSString *signature);

/** 登陆并获取uid和ukey完成*/
typedef void(^FetchCenterGetRequestGetUidAndUkeyCompleted)(NSDictionary *userInfo, BOOL isNewUser);


/** 消息提醒完成*/
typedef void(^FetchCenterGetRequestGetMessageNotificationCompleted)(NSNumber *messageCount,NSNumber *followCount);


@interface FetchCenter : NSObject
@property (nonatomic,weak) id <FetchCenterDelegate>delegate;
@property (nonatomic,strong) NSString *buildVersion;
@property (nonatomic,strong) TXYUploadManager *uploadManager;

+ (NSString *)requestLogFilePath;

#pragma mark - 圈子


/** 关注圈子 **/

- (void)followCircleId:(NSString *)circleId
            completion:(FetchCenterGetRequestCompleted)completionBlock;


/** 我关注圈子列表 **/
typedef void(^FetchCenterGetRequestGetFollowingCircleCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getFollowingCircleList:(NSArray *)localList
                        onPage:(NSNumber *)localPage
                    completion:(FetchCenterGetRequestGetFollowingCircleCompleted)completionBlock;


/** 退出圈子 **/
- (void)quitCircle:(NSString *)circleId completion:(FetchCenterGetRequestCompleted)completionBlock;

/** 获取分享页URL **/
typedef void(^FetchCenterGetRequestGetCircleInvitationURLCompleted)(NSString *urlString);
- (void)getH5invitationUrlWithCircleId:(NSString *)circleId
                            completion:(FetchCenterGetRequestGetCircleInvitationURLCompleted)completionBlock;

/** 获取圈子里的事件列表 **/
typedef void(^FetchCenterGetRequestGetCirclePlanListCompleted)(NSNumber *currentPage, NSNumber *totalPage, NSArray *topMemberList);
- (void)getPlanListInCircleId:(NSString *)circleId
                    localList:(NSArray *)localList
                       onPage:(NSNumber *)localPage
         completion:(FetchCenterGetRequestGetCirclePlanListCompleted)completionBlock;

/** 删除成员 **/
- (void)deleteMember:(NSString *)memberID
            inCircle:(NSString *)circleID
          completion:(FetchCenterGetRequestCompleted)completionBlock;

/** 圈子成员列表 **/

typedef void(^FetchCenterGetRequestGetMemberListCompleted)(NSArray *memberIDs);
- (void)getMemberListForCircleId:(NSString *)circleId
                       localList:(NSArray *)localList
                      completion:(FetchCenterGetRequestGetMemberListCompleted)completionBlock;

/** 设置圈子资料*/
- (void)updateCircle:(NSString *)circleId
                name:(NSString *)circleName
         description:(NSString *)circleDescription
     backgroundImage:(NSString *)imageId
          completion:(FetchCenterGetRequestCompleted)completionBlock;

/** 创建圈子*/
- (void)createCircle:(NSString *)circleName
         description:(NSString *)circleDescription
   backgroundImageId:(NSString *)imageId
          completion:(FetchCenterGetRequestCompleted)completionBlock;


/** 删除圈子*/
- (void)deleteCircle:(NSString *)circleId completion:(FetchCenterGetRequestCompleted)completionBlock;

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
- (void)switchToCircle:(NSString *)circleId completion:(FetchCenterGetRequestCompleted)completionBlock;

#pragma mark - 消息
- (void)clearAllMessages:(FetchCenterGetRequestCompleted)completionBlock;


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
- (void)likeFeed:(Feed *)feed completion:(FetchCenterGetRequestCompleted)completionBlock;

/**取消赞*/
- (void)unLikeFeed:(Feed *)feed completion:(FetchCenterGetRequestCompleted)completionBlock;

- (void)deleteFeed:(Feed *)feed completion:(FetchCenterGetRequestCompleted)completionBlock;



/** 上传图片完成*/
typedef void(^FetchCenterPostRequestUploadImagesCompleted)(NSArray *imageIds);
typedef void(^FetchCenterPostRequestUploadImagesReceivedPercentage)(CGFloat progress);
- (void)uploadImages:(NSArray *)images
            progress:(FetchCenterPostRequestUploadImagesReceivedPercentage)progressBlock
          completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock;

/** 上传Feed完成*/
typedef void(^FetchCenterGetRequestUploadFeedCompleted)(NSString *feedId);
- (void)createFeed:(NSString *)feedTitle
            planId:(NSString *)planId
   fetchedImageIds:(NSArray *)imageIds
        completion:(FetchCenterGetRequestUploadFeedCompleted)completionBlock;



#pragma mark - 评论回复
/** 评论或回复完成*/
- (void)replyToFeedID:(NSString *)feedID
              content:(NSString *)text
            toOwnerID:(NSString *)ownerID
            ownerName:(NSString *)ownerName
           completion:(FetchCenterGetRequestCompleted)completionBlock;

/** 摘取评论列表完成*/
typedef void(^FetchCenterGetRequestGetCommentListCompleted)(NSNumber *currentPage,
                                                            NSNumber *totalPage,
                                                            BOOL hasComments);
- (void)getCommentListForFeed:(NSString *)feedId
                    localList:(NSArray *)localList
                  currentPage:(NSNumber *)localCurrentPage
                   completion:(FetchCenterGetRequestGetCommentListCompleted)completionBlock;

- (void)deleteComment:(Comment *)comment
           completion:(FetchCenterGetRequestCompleted)completionBlock;;

#pragma mark - 事件

/** 设置事件圈子归属 **/
- (void)updatePlanId:(NSString *)planId
          inCircleId:(NSString *)circleId
          completion:(FetchCenterGetRequestCompleted)completionBlock;

/**拉取主人id的事件列表*/
- (void)getPlanListForOwnerId:(NSString *)ownerId
                    localList:(NSArray *)localList
                   completion:(FetchCenterGetRequestCompleted)completionBlock;

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
- (void)updatePlan:(NSString *)planId
             title:(NSString *)planTitle
         isPrivate:(BOOL)isPrivate
       description:(NSString *)planDescription
        completion:(FetchCenterGetRequestCompleted)completionBlock;

/** 删除事件状态完成*/
- (void)deletePlanId:(NSString *)planId completion:(FetchCenterGetRequestCompleted)completionBlock;

/** 更新事件状态完成*/
- (void)updatePlanId:(NSString *)planId
          planStatus:(PlanStatus)planStatus
          completion:(FetchCenterGetRequestCompleted)completionBlock;

#pragma mark - 关注
- (void)followPlan:(Plan *)plan completion:(FetchCenterGetRequestCompleted)completionBlock;
- (void)unFollowPlan:(Plan *)plan completion:(FetchCenterGetRequestCompleted)completionBlock;;

/** 拉取关注事件列表完成*/
- (void)getFollowingList:(NSArray *)localList completion:(FetchCenterGetRequestCompleted)completionBlock;



#pragma mark - 发现
/** 发现页拉取列表完成*/
typedef void(^FetchCenterGetRequestGetDiscoverListCompleted)(NSNumber *currentPage, NSNumber *totalPage);
- (void)getDiscoveryList:(NSArray *)localList
                  onPage:(NSNumber *)localPage
              completion:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock;

#pragma mark - 个人
- (void)sendFeedback:(NSString *)content
             content:(NSString *)email
          completion:(FetchCenterGetRequestCompleted)completionBlock;

- (void)checkVersion:(FetchCenterGetRequestCheckVersionCompleted)completionBlock;
- (void)uploadNewProfilePicture:(UIImage *)picture
                     completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock;
;
- (void)setPersonalInfo:(NSString *)nickName
                 gender:(NSString *)gender
                imageId:(NSString *)imageId 
             occupation:(NSString *)occupation
           personalInfo:(NSString *)info
             completion:(FetchCenterGetRequestCompleted)completionBlock;;

#pragma mark - 工具

- (void)sendDeviceToken:(NSString *)deviceToken completion:(FetchCenterPostRequestCompleted)completionBlock;


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

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(FetchCenterPostRequestCompleted)completionBlock;

- (void)registerWithUsername:(NSString *)userName
                    password:(NSString *)password
                  completion:(FetchCenterPostRequestCompleted)completionBlock;

- (void)getUidandUkeyWithOpenId:(NSString *)openId
                    accessToken:(NSString *)token
                     completion:(FetchCenterGetRequestGetUidAndUkeyCompleted)completionBlock;

- (void)getAccessTokenWithWechatCode:(NSString *)code
                          completion:(FetchCenterGetRequestGetUidAndUkeyCompleted)completionBlock;

- (void)getWechatUserInfoWithOpenID:(NSString *)openID
                              token:(NSString *)accessToken
                         completion:(FetchCenterGetRequestCompleted)completionBlock;

#pragma mark - 优图
- (void)requestSignature:(FetchCenterGetRequestGetYoutuSignatureCompleted)completionBlock;
@end

