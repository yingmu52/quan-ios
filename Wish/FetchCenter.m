//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"

#define INNER_NETWORK_URL @"http://182.254.167.228"
#define OUTTER_NETWORK_URL @"http://120.24.73.51"
#define PROJECT @"/superplan/"

#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"
#define CREATE_PLAN @"splan_plan_create.php"
#define DELETE_PLAN @"splan_plan_delete_id.php"
#define UPDATE_PLAN_STATUS @"splan_plan_set_state.php"
#define UPDATE_PLAN @"splan_plan_update.php"

#define FEED @"feeds/"
#define PIC @"pic/"
#define UPLOAD_IMAGE @"splan_pic_upload.php"
#define GET_IMAGE @"splan_pic_get.php"
#define kFetchedImage @"fetchedImage" // for constructing NSDictionary with image data
#define CREATE_FEED @"splan_feeds_create.php"
#define LIKE_FEED @"splan_feeds_like.php"
#define UNLIKE_FEED @"splan_feeds_unlike.php"
#define LOAD_FEED_LIST @"splan_feeds_getlist.php"
#define DELETE_FEED @"splan_feeds_delete_id.php"
#define COMMENT_FEED @"splan_comment_create.php"
#define GET_FEED_COMMENTS @"splan_comment_getlist.php"
#define DELETE_COMMENT @"splan_comment_delete.php"

#define FOLLOW @"follow/"
#define GET_FOLLOW_LIST @"splan_follow_get_feedslist.php"
#define FOLLOW_PLAN @"splan_follow_do.php"
#define UNFOLLOW_PLAN @"splan_follow_undo.php"

#define USER @"man/"
#define GETUID @"splan_get_uid.php"
#define SET_USER_INFO @"splan_man_set.php"
#define GET_ACCESSTOKEN_OPENID @"splan_wx_code2token.php"
#define OTHER @"other/"
#define CHECK_NEW_VERSION @"splan_other_new_version.php"
#define FEED_BACK @"splan_other_support_set.php"


#define DISCOVER @"find/"
#define GET_DISCOVER_LIST @"splan_find_planlist.php"

#define CIRCLE @"quan/"
#define JOINT_CIRCLE @"splan_quan_join.php"
#define TOOL @"tool/"
#define GET_CIRCLE_LIST @"tool_quan_get.php"
#define SWITCH_CIRCLE @"tool_quan_man.php"

#define MESSAGE @"message/"
#define GET_MESSAGE_LIST @"splan_message_getlist.php"
#define GET_MESSAGE_NOTIFICATION @"splan_count_get.php"
#define CLEAR_ALL_MESSAGES @"splan_message_clear.php"

#define TENCENTYOUTU @"tencentYoutu/"
#define GET_SIGNATURE @"getsign.php"



typedef enum{
    FetchCenterGetOpCreatePlan,
    FetchCenterGetOpDeletePlan,
    FetchCenterGetOpUploadImage,
    FetchCenterGetOpCreateFeed,
    FetchCenterGetOpGetPlanList,
    FetchCenterGetOpSetPlanStatus,
    FetchCenterGetOpUpdatePlan,
    FetchCenterGetOpFollowingPlanList,
    FetchCenterGetOpFollowPlanAction,
    FetchCenterGetOpUnFollowPlanAction,
    FetchCenterGetOpLoginForUidAndUkey,
    FetchCenterGetOpCheckNewVersion,
    FetchCenterGetOpSetPersonalInfo,
    FetchCenterGetOpDiscoverPlans,
    FetchCenterGetOpLikeAFeed,
    FetchCenterGetOpUnLikeAFeed,
    FetchCenterGetOpDeleteFeed,
    FetchCenterGetOpCommentFeed,
    FetchCenterGetOpDeleteComment,
    FetchCenterGetOpGetFeedCommentList,
    FetchCenterGetOpGetFeedList,
    FetchCenterGetOpFeedBack,
    FetchCenterGetOpGetMessageList,
    FetchCenterGetOpGetMessageNotificationInfo,
    FetchCenterGetOpClearAllMessages,
    FetchCenterGetOpGetSignature,
    FetchCenterGetOpGetAccessTokenAndOpenIdWithWechatCode
}FetchCenterGetOp;

typedef void(^FetchCenterImageUploadCompletionBlock)(NSString *fetchedId); //上传图像成功
typedef void(^FetchCenterGetRequestCompletionBlock)(NSDictionary *responseJson); //请求成功

@interface FetchCenter ()
@property (nonatomic,strong) NSString *baseUrl;
@property (nonatomic,strong) Reachability *reachability;
@property (nonatomic,strong) NSDictionary *backendErrorCode;
@property (nonatomic,strong) NSURLSession *session;
@end
@implementation FetchCenter

#pragma mark - 圈子
#define TOOLCGIKEY @"123$%^abc"

- (void)joinCircle:(NSString *)invitationCode completion:(FetchCenterGetRequestJoinCircleCompleted)completionBlock{
    if (invitationCode) {
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,JOINT_CIRCLE];
        [self getRequest:rqtStr
               parameter:@{@"addCode":invitationCode}
        includeArguments:YES
              completion:^(NSDictionary *responseJson) {
                  NSLog(@"%@",responseJson);
                  NSString *circleId = [responseJson valueForKeyPath:@"quanInfo.id"];
                  if (circleId){
                      [User updateAttributeFromDictionary:@{CURRENT_CIRCLE_ID:circleId}];
                  }
                  NSLog(@"成功加入圈子id %@",[User currentCircleId]);
                  if (completionBlock) completionBlock(circleId);
              }];
    }
}

//MARK: 切换圈子
- (void)switchToCircle:(NSString *)circleId completion:(FetchCenterGetRequestSwithCircleCompleted)completionBlock{
    if (circleId) {
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,TOOL,SWITCH_CIRCLE];
        [self getRequest:rqtStr
               parameter:@{@"key":[TOOLCGIKEY stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"id":circleId,
                           @"manId":[User uid],
                           @"operate":[@"add" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]}
        includeArguments:NO
              completion:^(NSDictionary *responseJson) {
                  NSLog(@"%@",responseJson);
                  //缓存当前圈子id
                  [User updateAttributeFromDictionary:@{CURRENT_CIRCLE_ID:circleId}];
                  if (completionBlock) {
                      completionBlock();
                  }
              }];
    }
}

//MARK: 获取圈子列表
- (void)getCircleList:(FetchCenterGetRequestGetCircleListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,TOOL,GET_CIRCLE_LIST];
    [self getRequest:rqtStr
           parameter:@{@"key":[TOOLCGIKEY stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]}
    includeArguments:NO
          completion:^(NSDictionary *responseJson) {
              NSArray *circleInfo = [responseJson valueForKey:@"data"];
              NSMutableArray *circles = [NSMutableArray arrayWithCapacity:circleInfo.count];
              for (NSDictionary *info in circleInfo) {
                  [circles addObject:[Circle updateCircleWithInfo:info]];
              }
//              NSLog(@"%@",circles);
              if (completionBlock) {
                  completionBlock(circles);
              }
          }];
}

#pragma mark - 万象优图

- (TXYUploadManager *)uploadManager{
    if (!_uploadManager) {
        _uploadManager = [[TXYUploadManager alloc] initWithCloudType:TXYCloudTypeForImage
                                                       persistenceId:@"QCFileUpload"
                                                               appId:YOUTU_APP_ID];
    }
    return _uploadManager;
}

- (void)requestSignature:(FetchCenterGetRequestGetYoutuSignatureCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,TENCENTYOUTU,GET_SIGNATURE];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSString *signature = [responseJson valueForKey:@"sign"];
        if (signature) {
            [User storeSignature:signature];
        }
        if (completionBlock) {
            completionBlock(signature);
        }
        
    }];
}

#pragma mark - 消息

- (void)clearAllMessages{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,CLEAR_ALL_MESSAGES];
    [self getRequest:rqtStr parameter:nil operation:FetchCenterGetOpClearAllMessages entity:nil];
}


- (void)getMessageList{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,GET_MESSAGE_LIST];
    [self getRequest:rqtStr parameter:@{@"id":[User uid]}
           operation:FetchCenterGetOpGetMessageList entity:nil];

}

- (void)getMessageNotificationInfo{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,GET_MESSAGE_NOTIFICATION];
    [self getRequest:rqtStr parameter:nil operation:FetchCenterGetOpGetMessageNotificationInfo entity:nil];
}

#pragma mark - 评论和回复

- (void)deleteComment:(Comment *)comment{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,DELETE_COMMENT];
    [self getRequest:rqtStr parameter:@{@"id":comment.commentId,@"feedsId":comment.feed.feedId}
           operation:FetchCenterGetOpDeleteComment
              entity:comment];
}
- (void)getCommentListForFeed:(NSString *)feedId pageInfo:(NSDictionary *)info{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,GET_FEED_COMMENTS];
    NSString *infoStr = info ? [self convertDictionaryToString:info] : @"";
    
    NSDictionary *args = @{@"feedsId":feedId,
                           @"attachInfo":infoStr};
    [self getRequest:rqtStr
           parameter:args
           operation:FetchCenterGetOpGetFeedCommentList
              entity:nil];
}

- (void)commentOnFeed:(Feed *)feed content:(NSString *)text{
    [self replyAtFeed:feed content:text toOwner:nil];
}

- (void)replyAtFeed:(Feed *)feed content:(NSString *)text toOwner:(Owner *)owner{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,COMMENT_FEED];
    NSDictionary *args = @{@"feedsId":feed.feedId,
                           @"content":[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"commentTo": (owner ? owner.ownerId : @"")};
    
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        //increase comment count by one
        NSString *commentId = [responseJson valueForKeyPath:@"data.id"];
        
        if (owner){ //回复
            [Comment replyToOwner:owner
                          content:text
                        commentId:commentId
                          forFeed:feed];
        }else{ //评论
            [Comment createComment:text
                         commentId:commentId
                           forFeed:feed];
        }
        //update feed count
        feed.commentCount = @(feed.commentCount.integerValue + 1);
        if ([self.delegate respondsToSelector:@selector(didFinishCommentingFeed:commentId:)]) {
            [self.delegate didFinishCommentingFeed:feed commentId:commentId];
        }

    }];
}


#pragma mark - 事件动态，又称事件片段，Feed
//superplan/feeds/splan_feeds_delete_id.php
- (void)deleteFeed:(Feed *)feed completion:(FetchCenterGetRequestDeleteFeedCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,DELETE_FEED];
    NSDictionary *args = @{@"id":feed.feedId,
                           @"picId":feed.imageId,
                           @"planId":feed.plan.planId};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSLog(@"delete feed successed, ID:%@",feed.feedId);
        if (completionBlock) {
            completionBlock();
        }
    }];
}


- (void)loadFeedsListForPlan:(Plan *)plan pageInfo:(NSDictionary *)info{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,LOAD_FEED_LIST];
    NSString *infoStr = info ? [self convertDictionaryToString:info] : @"";
    NSDictionary *args = @{@"id":plan.planId,@"attachInfo":infoStr};
    [self getRequest:rqtStr
           parameter:args
           operation:FetchCenterGetOpGetFeedList
              entity:plan];
}

- (NSString*)convertDictionaryToString:(NSDictionary*)dict{
    NSError* error;
    //giving error as it takes dic, array,etc only. not custom object.
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)uploadToCreateFeed:(Feed *)feed
           fetchedImageIds:(NSArray *)imageIds
                completion:(FetchCenterGetRequestUploadFeedCompleted)completionBlock{
    if (feed.plan.planId && feed.feedTitle) {
        
        //设置Feed的封面
        feed.imageId = imageIds.firstObject;
        
        //设置事件封面
        feed.plan.backgroundNum = feed.imageId;
        
        //设置feed的类型
        feed.type = @(imageIds.count > 1 ? FeedTypeMultiplePicture : FeedTypeSinglePicture);
        
        //设置多图id
        feed.picUrls = [imageIds componentsJoinedByString:@","];
        
        //设置请求参数
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,CREATE_FEED];
        NSDictionary *args = @{@"picurl":feed.imageId, //兼容背影图
                               @"content":[feed.feedTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               @"planId":feed.plan.planId,
                               @"picurls":feed.picUrls,
                               @"feedsType":feed.type};
        
        [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
            NSString *fetchedFeedID = [responseJson valueForKeyPath:@"data.id"];
            feed.feedId = fetchedFeedID;
            [feed.plan updateTryTimesOfPlan:YES];
            if (completionBlock) {
                completionBlock(feed);
                NSLog(@"upload feed successed, ID: %@",feed.feedId);
            }
        }];
    }

}

- (void)uploadImages:(NSArray *)images toCreateFeed:(Feed *)feed{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSMutableDictionary *imageIdMaps = [NSMutableDictionary dictionary];
        dispatch_apply(images.count, queue, ^(size_t index){
            [self postImageWithOperation:images[index]
                           managedObject:feed
                                complete:^(NSString *fetchedId)
             {
                 dispatch_main_async_safe(^{
                     if (fetchedId){
                         [imageIdMaps addEntriesFromDictionary:@{fetchedId:@(index)}];
                         if (imageIdMaps.allKeys.count == images.count) {
                             NSLog(@"%@",imageIdMaps);
                             NSArray *sorted = [[imageIdMaps allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                                 return [imageIdMaps[obj1] compare:imageIdMaps[obj2]];
                             }];
                             NSLog(@"\n%@\n",sorted);
                             
                             [self.delegate didFinishUploadingImage:sorted forFeed:feed];
                         }else{
                             if ([self.delegate respondsToSelector:@selector(didReceivedCurrentProgressForUploadingImage:)]) {
                                 CGFloat progress = (imageIdMaps.allKeys.count - 1e-3) / images.count;
                                 [self.delegate didReceivedCurrentProgressForUploadingImage:progress];
                             }
                         }
                     }
                 });
             }];
        });
    });
    
}

- (void)likeFeed:(Feed *)feed completion:(FetchCenterGetRequestLikeFeedCompleted)completionBlock{
    if (feed.feedId){
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,LIKE_FEED];
        [self getRequest:rqtStr parameter:@{@"id":feed.feedId} includeArguments:YES completion:^(NSDictionary *responseJson) {
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
}

- (void)unLikeFeed:(Feed *)feed completion:(FetchCenterGetRequestUnLikeFeedCompleted)completionBlock{
    if (feed.feedId){
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,UNLIKE_FEED];
        [self getRequest:rqtStr parameter:@{@"id":feed.feedId} includeArguments:YES completion:^(NSDictionary *responseJson) {
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
}

#pragma mark - 事件关注

- (void)followPlan:(Plan *)plan completion:(FetchCenterGetRequestFollowPlanCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FOLLOW,FOLLOW_PLAN];
    [self getRequest:rqtStr parameter:@{@"planId":plan.planId} includeArguments:YES completion:^(NSDictionary *responseJson) {
        plan.followCount = @(plan.followCount.integerValue + 1);
        plan.isFollowed = @(YES);
        NSLog(@"followed plan ID %@",plan.planId);
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)unFollowPlan:(Plan *)plan completion:(FetchCenterGetRequestUnFollowPlanCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FOLLOW,UNFOLLOW_PLAN];
    [self getRequest:rqtStr parameter:@{@"planId":plan.planId} includeArguments:YES completion:^(NSDictionary *responseJson) {
        plan.followCount = @(plan.followCount.integerValue - 1);
        plan.isFollowed = @(NO);
        NSLog(@"unfollowed plan ID %@",plan.planId);
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)getFollowingPlanList:(FetchCenterGetRequestGetFollowingPlanListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FOLLOW,GET_FOLLOW_LIST];
    
    [self getRequest:rqtStr parameter:@{@"id":[User uid]} includeArguments:YES completion:^(NSDictionary *responseJson) {
        for (NSDictionary *planItem in [responseJson valueForKeyPath:@"data.planList"]) {
            NSDictionary *userInfo = [responseJson valueForKeyPath:[NSString stringWithFormat:@"data.manList.%@",planItem[@"ownerId"]]];
            Plan *plan = [Plan updatePlanFromServer:planItem ownerInfo:userInfo];
            
            if (![plan.isFollowed isEqualToNumber:@(YES)]){
                plan.isFollowed = @(YES);
            }
            
            NSArray *feedsList = planItem[@"feedsList"];
            if (feedsList.count) {
                //create all feeds
                for (NSDictionary *feedItem in feedsList) {
                    [Feed updateFeedWithInfo:feedItem forPlan:plan];
                    //use alternative way to load and cache image
                }
            }
        }
        if (completionBlock){
            NSArray *planIds = [responseJson valueForKeyPath:@"data.planList.id"];
            completionBlock(planIds);
        }

    }];
}

#pragma mark - 发现事件

- (void)getDiscoveryList:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,DISCOVER,GET_DISCOVER_LIST];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {

        NSMutableArray *plans = [NSMutableArray array];
        NSArray *planList = [responseJson valueForKeyPath:@"data.planList"];
        NSDictionary *manList = [responseJson valueForKeyPath:@"data.manList"];
        NSString *title = [responseJson valueForKeyPath:@"data.quanInfo.name"];
        
        //缓存并更新本地事件
        if (planList && manList){
            [planList enumerateObjectsUsingBlock:^(NSDictionary * planInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                Plan *plan = [Plan updatePlanFromServer:planInfo
                                              ownerInfo:[manList valueForKey:planInfo[@"ownerId"]]];
                plan.discoverIndex = @(idx); //记录索引方便显示服务器上的顺序
                [plans addObject:plan];
//                NSLog(@"%@, mask : %@, index %@",plan.planTitle,plan.cornerMask,plan.discoverIndex);
            }];
        }
        completionBlock(plans,title);
    }];
}


#pragma mark - 反馈，版本检测

- (void)sendFeedback:(NSString *)content
             content:(NSString *)email
          completion:(FetchCenterGetRequestSendFeedbackCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,OTHER,FEED_BACK];
    NSDictionary *args = @{@"title":[@"Feedback From iOS Client Application" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"content":[content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"moreInfo":[email ? email : @"User did not specify contact info" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSLog(@"反馈成功");
        if (completionBlock) {
            completionBlock();
        }
    }];
}
- (void)checkVersion:(FetchCenterGetRequestCheckVersionCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,OTHER,CHECK_NEW_VERSION];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        if (completionBlock) {
            BOOL hasNewVersion = [[responseJson valueForKeyPath:@"data.haveNew"] boolValue];
            NSLog(@"%@",hasNewVersion ? @"有新版本" : @"无新版本");
            completionBlock(hasNewVersion);
        }
    }];
}

#pragma mark - 个人信息

- (void)uploadNewProfilePicture:(UIImage *)picture{
    __weak typeof(self) weakSelf = self;
    [self postImageWithOperation:picture managedObject:nil complete:^(NSString *fetchedId) {
        if (fetchedId){
            [User updateAttributeFromDictionary:@{PROFILE_PICTURE_ID_CUSTOM:fetchedId}];
            NSLog(@"image uploaded %@",fetchedId);
            if ([weakSelf.delegate respondsToSelector:@selector(didFinishUploadingPictureForProfile)]) {
                [weakSelf.delegate didFinishUploadingPictureForProfile];
            }
        }
    }];
//    [self postImageWithOperation:picture managedObject:nil postOp:FetchCenterPostOpUploadImageForUpdaingProfile];
}

- (void)setPersonalInfo:(NSString *)nickName gender:(NSString *)gender imageId:(NSString *)imageId occupation:(NSString *)occupation personalInfo:(NSString *)info{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,SET_USER_INFO];
    
    NSString *ocpStr = occupation ? occupation : @"";
    NSString *infoStr = info ? info : @"";
    [self getRequest:rqtStr parameter:@{@"name":[nickName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        @"gender":[gender isEqualToString:@"男"] ? @(1):@(0),
                                        @"headUrl":imageId,
                                        @"profession":[ocpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        @"description":[infoStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]}
           operation:FetchCenterGetOpSetPersonalInfo
              entity:@[nickName,gender,imageId,ocpStr,infoStr]];
    
}

#pragma mark - 事件
- (void)updatePlan:(Plan *)plan completion:(FetchCenterGetRequestUpdatePlanCompleted)completionBlock{
    //输入样例：id=hello_1421235901&title=hello_title2&finishDate=3&backGroudPic=bg3&private=1&state=1&finishPercent=20
    //—— 每一项都可以单独更新
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,UPDATE_PLAN];
    NSDictionary *args = @{@"id":plan.planId,
                           @"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"private":plan.isPrivate,
                           @"description":plan.detailText ? [plan.detailText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)updateStatus:(Plan *)plan completion:(FetchCenterGetRequestUpdatePlanStatusCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,UPDATE_PLAN_STATUS];
    NSDictionary *args = @{@"id":plan.planId,
                           @"state":plan.planStatus};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSLog(@"%@",responseJson);
        if (completionBlock) {
            completionBlock();
        }
    }];
}
- (void)getPlanListForOwnerId:(NSString *)ownerId completion:(FetchCenterGetRequestGetPlanListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,GET_LIST];
    [self getRequest:rqtStr parameter:@{@"id":ownerId} includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSArray *plans = responseJson[@"data"];
        NSMutableArray *planEntities = [NSMutableArray arrayWithCapacity:plans.count];
        for (NSDictionary *planInfo in plans) {
            Plan * plan = [Plan updatePlanFromServer:planInfo ownerInfo:[Owner myWebInfo]];
            [planEntities addObject:plan];
        }
        if (completionBlock) {
            completionBlock(planEntities.mutableCopy);
        }
    }];

}

- (void)uploadToCreatePlan:(Plan *)plan completion:(FetchCenterGetRequestPlanCreationCompleted)completionBlock{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,CREATE_PLAN];
    NSDictionary *args = @{@"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"private":plan.isPrivate};
    [self getRequest:baseUrl parameter:args includeArguments:YES completion:^(NSDictionary *json) {
        NSString *fetchedPlanId = [json valueForKeyPath:@"data.id"];
        NSString *bgString = [json valueForKeyPath:@"data.backGroudPic"];
        if (fetchedPlanId && bgString) {
            plan.planId = fetchedPlanId;
            plan.backgroundNum = bgString;
            NSLog(@"create plan succeed, ID: %@",fetchedPlanId);
            completionBlock(plan);
        }
    }];
}


- (void)postToDeletePlan:(Plan *)plan completion:(FetchCenterGetRequestDeletePlanCompleted)completionBlock{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,DELETE_PLAN];
    NSDictionary *args = @{@"id":plan.planId};
    [self getRequest:baseUrl parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSLog(@"delete plan succeed, ID: %@",plan.planId);
        [plan.managedObjectContext save:nil];
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - 缓存请求日志

+ (NSString *)requestLogFilePath{ //this file gets remove in applicationWillTerminate Appdelegate
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"httpRequestLog.txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path]; //remove from path if file is too big
    if (data.length > 1024*1024 ){ //delete the file when is over 1MB
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return path;
}

- (void)appendRequest:(NSURLRequest *)request andResponse:(NSDictionary *)response{
    NSString *logPath = [self.class requestLogFilePath];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:logPath];

    NSString *content = [NSString stringWithFormat:@"[Date]: %@\n\n[Request]: %@\n\n[Response]: %@\n\n\n\n",[NSDate date],request,response];
    
    NSString *decodedContent = [NSString stringWithCString:[content cStringUsingEncoding:NSUTF8StringEncoding]
                                                  encoding:NSNonLossyASCIIStringEncoding];
    if (fileHandler){
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[decodedContent dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
    }else{
        [decodedContent writeToFile:logPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
}

#pragma mark - 网络检测

- (BOOL)hasActiveInternetConnection{
    return self.reachability.currentReachabilityStatus != NotReachable;
}

- (Reachability *)reachability{
    if (!_reachability) {
        _reachability = [Reachability reachabilityForInternetConnection];
    }
    return _reachability;
}

#pragma mark - 核心请求函数

- (NSString *)baseUrl{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK]) {
        _baseUrl = [NSString stringWithFormat:@"%@%@",INNER_NETWORK_URL,PROJECT];
    }else{
        _baseUrl = [NSString stringWithFormat:@"%@%@",OUTTER_NETWORK_URL,PROJECT];
    }
    //    NSLog(@"%@",_baseUrl);
    return _baseUrl;
}

/**
 * 将字典里的参数和值转换成 ‘参数1’=‘值1’&‘参数2’=‘值2... 的格式
 */
- (NSString *)argumentStringWithDictionary:(NSDictionary *)dict{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dict.allKeys.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }];
    return [array componentsJoinedByString:@"&"];
}

- (void)getRequest:(NSString *)baseURL parameter:(NSDictionary *)dict operation:(FetchCenterGetOp)op entity:(id)obj{
    
    //check internet connection
    //chekc internet
    if (![self hasActiveInternetConnection]) return;
    
    //base url with version
    baseURL = [baseURL stringByAppendingString:@"?"];
    baseURL = [self addGeneralArgumentsForBaseURL:baseURL];
    
    
    //content arguments
    NSString *rqtStr = [baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      @try {
                                          //递归过滤Json里含带的Null数据
                                          NSDictionary *rawJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                          
                                          NSDictionary *responseJson = [self recursiveNullRemove:rawJson];
                                          NSDictionary *timeOutDict = @{@"ret":@"Request Timeout",@"msg":@"Fail sending request to server"};
                                          NSDictionary *responseInfo = responseJson ? responseJson : timeOutDict;
                                          
                                          if (!error && ![responseJson[@"ret"] integerValue]){ //successed "ret" = 0;
                                              [self didFinishSendingGetRequest:responseJson operation:op entity:obj];
                                          }else{
                                              dispatch_main_async_safe((^{
                                                  [self alertWithBackendErrorCode:@([responseJson[@"ret"] integerValue])];
                                                  if ([self.delegate respondsToSelector:@selector(didFailSendingRequestWithInfo:entity:)]){
                                                      [self.delegate didFailSendingRequestWithInfo:responseInfo entity:obj];
                                                  }
                                              }));
                                              NSLog(@"Fail Get Request :%@\n op: %d \n baseUrl: %@ \n parameter: %@ \n response: %@ \n error:%@"
                                                    ,rqtStr,op,baseURL,dict,responseInfo,error);
                                              [self appendRequest:request andResponse:responseInfo];
                                          }
                                      }
                                      @catch (NSException *exception) {
                                          NSLog(@"%@",exception);
                                      }
                                  }];
    [task resume];
    
    
}


/**
 * 排查后面返回字典的参数里<Null>值，并将其替换成“”
 */
- (NSMutableDictionary *)recursiveNullRemove:(NSDictionary *)dictionaryResponse {
    
    NSMutableDictionary *dictionary = [dictionaryResponse mutableCopy];
    NSString *nullString = @"";
    for (NSString *key in [dictionary allKeys]) {
        id value = dictionary[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            dictionary[key] = [self recursiveNullRemove:(NSMutableDictionary*)value];
            
        }else if([value isKindOfClass:[NSArray class]]){
            
            NSMutableArray *newArray = [value mutableCopy];
            for (int i = 0; i < [value count]; ++i) {
                
                id value2 = [value objectAtIndex:i];
                
                if ([value2 isKindOfClass:[NSDictionary class]]) {
                    newArray[i] = [self recursiveNullRemove:(NSMutableDictionary*)value2];
                }
                else if ([value2 isKindOfClass:[NSNull class]]){
                    newArray[i] = nullString;
                }
            }
            dictionary[key] = newArray;
        }else if ([value isKindOfClass:[NSNull class]]){
            dictionary[key] = nullString;
        }
    }
    return dictionary;
}

#define IMAGE_PREFIX @"IOS-"
- (void)postImageWithOperation:(UIImage *)image
                 managedObject:(NSManagedObject *)managedObject
                      complete:(FetchCenterImageUploadCompletionBlock)completionBlock{ //obj :NSManagedObject or UIimage
    
    //chekc internet
    if (![self hasActiveInternetConnection]) return;

    //创建本地路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *uuidString = [NSUUID UUID].UUIDString;
    NSString *filePath = [paths[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uuidString]];
    
    //压缩图片
    CGFloat originalSize = UIImagePNGRepresentation(image).length/1024.0f; //in KB
    NSLog(@"original size %@ KB", @(originalSize));
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);
    NSLog(@"compressed size %@ KB", @(imageData.length/1024.0f));

    //缓存压缩图像
    NSAssert(imageData.length, @"0 size image");
    if ([imageData writeToFile:filePath atomically:YES]) {
        
        //构造TXYPhotoUploadTask上传任务,
        NSString *fileId = [NSString stringWithFormat:@"%@%@",IMAGE_PREFIX,uuidString];//自定义图像id
        NSString *signature = [User youtuSignature];
        NSAssert(![signature isEqualToString:@""], @"Invalid Youtu Signature");
        TXYPhotoUploadTask *uploadPhotoTask = [[TXYPhotoUploadTask alloc] initWithPath:filePath
                                                                                  sign:[User youtuSignature]
                                                                                bucket:@"shier"
                                                                           expiredDate:3600
                                                                            msgContext:@"picture upload successed from iOS"
                                                                                fileId:fileId];
        //调用TXYUploadManager的upload接口
        [self.uploadManager upload:uploadPhotoTask
                          complete:^(TXYTaskRsp *resp, NSDictionary *context)
         {
             //retCode大于等于0，表示上传成功
             if (resp.retCode >= 0) {
                 //得到图片上传成功后的回包信息
                 TXYPhotoUploadTaskRsp *photoResp = (TXYPhotoUploadTaskRsp *)resp;
                 
                 dispatch_main_async_safe(^{
                     completionBlock(photoResp.photoFileId);
                 });
                 
                 //缓存图片
//                 NSURL *url = [self urlWithImageID:photoResp.photoFileId size:FetchCenterImageSizeOriginal];
//                 SDWebImageManager *manager = [SDWebImageManager sharedManager];
//                 NSLog(@"orientation :%@",@(image.imageOrientation));
//                 [manager.imageCache storeImage:image forKey:[manager cacheKeyForURL:url]];
                 
             }else{
                 if ([self.delegate respondsToSelector:@selector(didFailUploadingImageWithInfo:entity:)]) {
                     dispatch_main_async_safe((^{
                         [self.delegate didFailUploadingImageWithInfo:@{@"ret":@"上传图片失败",@"msg":resp.descMsg}
                                                                   entity:managedObject];
                     }));

                 }
             }
             
             //NSLog(@"上传图片失败，code:%d desc:%@", resp.retCode, resp.descMsg);
             //删除缓存
             [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
             NSAssert(![[NSFileManager defaultManager] fileExistsAtPath:filePath],@"没有成功删除压缩缓存");

             
         }progress:^(int64_t totalSize, int64_t sendSize, NSDictionary *context){
             //进度
             //long progress = (long)(sendSize * 100.0f/totalSize);
             //NSLog(@"%@",[NSString stringWithFormat:@"上传进度: %ld%%",progress]);
             
         }stateChange:^(TXYUploadTaskState state, NSDictionary *context) {
             //上传状态
             switch (state) {
                 case TXYUploadTaskStateConnecting:
                     NSLog(@"Connecting..");
                     break;
                 case TXYUploadTaskStateSending:
                     NSLog(@"Sending...");
                     break;
                 case TXYUploadTaskStateFail:
                     NSLog(@"Failled");
                     break;
                 case TXYUploadTaskStateSuccess:
                     NSLog(@"Succeed!");
                     break;
                 case TXYUploadTaskStateWait:
                     NSLog(@"Waiting..");
                     break;
                 default:
                     break;
             }
         }];
    }
    
}

/**
 * 新版请求函数（测试阶段）
 * 目前正在使用该函数的功能: [评论和回复]
 */
- (void)getRequest:(NSString *)baseURL
         parameter:(NSDictionary *)dict
  includeArguments:(BOOL)shouldInclude //针对工具类的CGI不需要加统一参数
        completion:(FetchCenterGetRequestCompletionBlock)completionBlock{
    
    @try {
        //检测网络
        if (![self hasActiveInternetConnection]) return;
        
        //设置请求统一参数
        baseURL = [baseURL stringByAppendingString:@"?"];
        baseURL = shouldInclude ? [self addGeneralArgumentsForBaseURL:baseURL] : baseURL;
        
        //拼接参数
        NSString *rqtStr = [baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:30.0];
        request.HTTPMethod = @"GET";
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          dispatch_main_async_safe(^{
                                              //递归过滤Json里含带的Null数据
                                              NSDictionary *rawJson = [NSJSONSerialization JSONObjectWithData:data
                                                                                                      options:NSJSONReadingAllowFragments
                                                                                                        error:nil];
                                              NSDictionary *responseJson = [self recursiveNullRemove:rawJson];
                                              
                                              if (responseJson) {
                                                  if (!error && ![responseJson[@"ret"] integerValue]){ //成功
                                                      if (completionBlock) {
                                                          completionBlock(responseJson);
                                                      }
                                                  }else{ //失败
                                                      
                                                      //在委托中跳出后台的提示
                                                      [self alertWithBackendErrorCode:@([responseJson[@"ret"] integerValue])];
                                                      
                                                      //假失败写入请求日志
                                                      [self appendRequest:request andResponse:responseJson];
                                                      
                                                      NSLog(@"Fail Get Request :%@\n baseUrl: %@ \n parameter: %@ \n response: %@ \n error:%@"
                                                            ,rqtStr,baseURL,dict,responseJson,error);
                                                      
                                                      if ([self.delegate respondsToSelector:@selector(didFailSendingRequest)]){
                                                          [self.delegate didFailSendingRequest];
                                                      }
                                                  }
                                              }
                                          });

                                      }];
        [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}
#pragma mark - 请求统一参数

- (NSString *)buildVersion{
    if (!_buildVersion) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        _buildVersion = [NSString stringWithFormat:@"%@.%@",version,build];
    }
    return _buildVersion;
}

//return a new base url string with appened version argument
- (NSString *)addGeneralArgumentsForBaseURL:(NSString *)baseURL{
    NSMutableDictionary *dict = [@{@"version":self.buildVersion,@"loginType":[User loginType]} mutableCopy];
    
    //add user info
    if ([User uid].length > 0 && [User uKey].length > 0) {
        [dict addEntriesFromDictionary:@{@"uid":[User uid],@"ukey":[User uKey]}];
        //change login type
        dict[@"loginType"] = @"uid";
    }

    return [[baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]] stringByAppendingString:@"&"];
}

#pragma mark - 图片id转换成图片请求的函数

- (NSURL *)urlWithImageID:(NSString *)imageId size:(FetchCenterImageSize)size{
    NSString *url;
    if (imageId.length > 30) { //优图id
        NSString *base = [NSString stringWithFormat:@"http://shier-%@.image.myqcloud.com/%@",YOUTU_APP_ID,imageId];
        url = (size == FetchCenterImageSizeOriginal) ? base : [base stringByAppendingFormat:@"/%@",@(size)];
    }else{ //老id
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?",self.baseUrl,PIC,GET_IMAGE];
        url = [NSString stringWithFormat:@"%@id=%@",[self addGeneralArgumentsForBaseURL:rqtStr],imageId];
    }
    return [NSURL URLWithString:url];
}

#pragma mark - response handler

- (void)didFinishSendingGetRequest:(NSDictionary *)json operation:(FetchCenterGetOp)op entity:(id)obj{
    dispatch_main_async_safe((^{
        switch (op)
        {
            case FetchCenterGetOpGetPlanList:{
                //down load plan
                NSArray *plans = json[@"data"];
 
                for (NSDictionary *planInfo in plans) {
                    [Plan updatePlanFromServer:planInfo ownerInfo:@{@"headUrl":[User updatedProfilePictureId],@"id":[User uid],@"name":[User userDisplayName]}];
                }
            }
                break;
            case FetchCenterGetOpDeletePlan:{
                NSLog(@"deleted successed %@",json);
                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                [delegate saveContext];
            }
                break;
            case FetchCenterGetOpCreateFeed:{
                NSString *fetchedFeedID = [json valueForKeyPath:@"data.id"];
                if (fetchedFeedID){
                    Feed *feed = (Feed *)obj;
                    feed.feedId = fetchedFeedID;
                    [feed.plan updateTryTimesOfPlan:YES];
                    [self.delegate didFinishUploadingFeed:feed];
                    NSLog(@"upload feed successed, ID: %@",fetchedFeedID);
                }
            }
                break;
            case FetchCenterGetOpCreatePlan:{
                NSString *fetchedPlanId = [json valueForKeyPath:@"data.id"];
                NSString *bgString = [json valueForKeyPath:@"data.backGroudPic"];
                if (fetchedPlanId && bgString) {
                    Plan *plan = (Plan *)obj;
                    plan.planId = fetchedPlanId;
                    plan.backgroundNum = bgString;
                    [self.delegate didFinishUploadingPlan:plan];
                    NSLog(@"create plan succeed, ID: %@",fetchedPlanId);
                }
            }
                break;
            case FetchCenterGetOpSetPlanStatus:{
                NSLog(@"updated plan status (from server)");
                NSLog(@"updated status : %@",((Plan *)obj).planStatus);
            }
                break;
            case FetchCenterGetOpFollowingPlanList:{
                //            NSLog(@"FetchCenterOpGetFollowingPlanList \n %@",json);
                //save the response following plan list
                for (NSDictionary *planItem in [json valueForKeyPath:@"data.planList"]) {
                    NSDictionary *userInfo = [json valueForKeyPath:[NSString stringWithFormat:@"data.manList.%@",planItem[@"ownerId"]]];
                    Plan *plan = [Plan updatePlanFromServer:planItem ownerInfo:userInfo];
                    
                    if (![plan.isFollowed isEqualToNumber:@(YES)]){
                        plan.isFollowed = @(YES);
                    }

                    NSArray *feedsList = planItem[@"feedsList"];
                    if (feedsList.count) {
                        //create all feeds
                        for (NSDictionary *feedItem in feedsList) {
                            [Feed updateFeedWithInfo:feedItem forPlan:plan];
                            //use alternative way to load and cache image
                        }
                    }
                }
                NSArray *planIds = [json valueForKeyPath:@"data.planList.id"];
//                NSLog(@"%@",json);
                [self.delegate didFinishFetchingFollowingPlanList:planIds];
            }
                break;
            case FetchCenterGetOpLoginForUidAndUkey:{
                NSString *uid = [json valueForKeyPath:@"data.uid"];
                NSString *ukey = [json valueForKeyPath:@"data.ukey"];
                BOOL isNewUser = [[json valueForKeyPath:@"data.isNew"] boolValue];
                NSDictionary *userInfo = [json valueForKeyPath:@"data.maninfo"];
                
                //update local user info & UI
                NSDictionary *localUserInfo = @{UID:uid,UKEY:ukey};
                [User updateAttributeFromDictionary:localUserInfo];
                [self.delegate didFinishReceivingUidAndUKeyForUserInfo:userInfo isNewUser:isNewUser];
            }
                break;
            case FetchCenterGetOpUpdatePlan:{
                Plan *plan = (Plan *)obj;
                [self.delegate didFinishUpdatingPlan:plan];
            }
                break;
            case FetchCenterGetOpCheckNewVersion:{
                BOOL hasNewVersion = [[json valueForKeyPath:@"data.haveNew"] boolValue];
                [self.delegate didFinishCheckingNewVersion:hasNewVersion];
            }
                break;
            case FetchCenterGetOpSetPersonalInfo:{
                NSArray *info = (NSArray *)obj; // nickname,gender,imageId
                [User updateAttributeFromDictionary:@{USER_DISPLAY_NAME:info[0],
                                                      GENDER:info[1],
                                                      PROFILE_PICTURE_ID_CUSTOM:info[2],
                                                      OCCUPATION:info[3],
                                                      PERSONALDETAIL:info[4]}];
                NSLog(@"%@",[User getOwnerInfo]);
                [self.delegate didFinishSettingPersonalInfo];
            }
                break;
            case FetchCenterGetOpDiscoverPlans:{
                //stored the lastet
                NSMutableArray *plans = [NSMutableArray array];
                NSArray *planList = [json valueForKeyPath:@"data.planList"];
                NSDictionary *manList = [json valueForKeyPath:@"data.manList"];
                NSString *title = [json valueForKeyPath:@"data.quanInfo.name"];

                //缓存并更新本地事件
                if (planList && manList){
                    [planList enumerateObjectsUsingBlock:^(NSDictionary * planInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                        Plan *plan = [Plan updatePlanFromServer:planInfo
                                                      ownerInfo:[manList valueForKey:planInfo[@"ownerId"]]];
                        plan.discoverIndex = @(idx); //记录索引方便显示服务器上的顺序
                        [plans addObject:plan];
                        NSLog(@"%@, mask : %@, index %@",plan.planTitle,plan.cornerMask,plan.discoverIndex);
                    }];
                }
                
                //完成回调
                [self.delegate didfinishFetchingDiscovery:plans circleTitle:title];
            }
                
                break;
                
            case FetchCenterGetOpLikeAFeed:{
                Feed *feed = (Feed *)obj;
//                [self.delegate didFinishLikingFeed:feed];
                NSLog(@"liked feed ID %@",feed.feedId);
            }
                break;
            case FetchCenterGetOpUnLikeAFeed:{
                Feed *feed = (Feed *)obj;
//                [self.delegate didFinishUnLikingFeed:feed];
                NSLog(@"unliked feed ID %@",feed.feedId);
            }
                break;
            case FetchCenterGetOpDeleteComment:{
                //decrease feed's commentCount by 1
                NSLog(@"%@",json);
                [self.delegate didFinishDeletingComment:obj];
            }
                break;
                
            case FetchCenterGetOpCommentFeed:{
                //increase comment count by one
                Feed *feed = (Feed *)obj;
                NSString *commentId = [json valueForKeyPath:@"data.id"];
                [self.delegate didFinishCommentingFeed:feed commentId:commentId];
            }
                break;
            case FetchCenterGetOpGetFeedCommentList:{
                
                NSDictionary *ownerInfo = [json valueForKeyPath:@"data.manList"];
                BOOL hasNextPage = [[json valueForKeyPath:@"data.isMore"] boolValue];
                NSDictionary *pageInfo = [json valueForKeyPath:@"data.attachInfo"];
                NSDictionary *feedInfo = [json valueForKeyPath:@"data.feeds"];
                
                Feed *feed = [Feed updateFeedWithInfo:feedInfo forPlan:nil];
                
                NSArray *comments = [json valueForKeyPath:@"data.commentList"];
                
                if (comments.count > 0) {
                    for (NSDictionary *commentInfo in comments){
                        
                        //读取评论信息
                        Comment *comment = [Comment updateCommentWithInfo:commentInfo];
                        
                        //读取用户信息
                        NSDictionary *userInfo = comment.isMyComment.boolValue ? @{@"headUrl":[User updatedProfilePictureId],@"id":[User uid],@"name":[User userDisplayName]} : ownerInfo[commentInfo[@"ownerId"]];
                        Owner *owner = [Owner updateOwnerWithInfo:userInfo];
                        
                        //防止更新相同的评论数据
                        if (comment.owner != owner) {
                            comment.owner = owner;
                        }
                        if (comment.feed != feed) {
                            comment.feed = feed;
                        }
                        if (comment.idForReply) {
                            NSString *nameForReply = [ownerInfo[comment.idForReply] objectForKey:@"name"];
                            if (![comment.nameForReply isEqualToString:nameForReply]) {
                                comment.nameForReply = nameForReply;
                            }
                        }
                        
                        
                        
                    }

                }
                
                [self.delegate didFinishLoadingCommentList:pageInfo hasNextPage:hasNextPage forFeed:feed];
            }
                break;
            case FetchCenterGetOpDeleteFeed:{
                [self.delegate didFinishDeletingFeed:obj];
            }
                break;
            case FetchCenterGetOpGetFeedList:{
                
                NSArray *feeds = [json valueForKeyPath:@"data.feedsList"];
                NSDictionary *pageInfo = [json valueForKeyPath:@"data.attachInfo"];
                Plan *plan = (Plan *)obj;
                
                NSNumber *isFollowed  = @([[json valueForKeyPath:@"data.isFollowed"] boolValue]);
                if (![plan.isFollowed isEqualToNumber:isFollowed]){
                    plan.isFollowed = isFollowed;
                }

                for (NSDictionary *info in feeds){
                    [Feed updateFeedWithInfo:info forPlan:obj]; // obj is Plan*
                }
                
                NSArray *feedIds = [json valueForKeyPath:@"data.feedsList.id"];
//                NSLog(@"%@",feedIds);
                [self.delegate didFinishLoadingFeedList:pageInfo
                                            hasNextPage:[[json valueForKeyPath:@"data.isMore"] boolValue]
                                       serverFeedIdList:feedIds];
            }
                break;
                
            case FetchCenterGetOpFeedBack:
                [self.delegate didFinishSendingFeedBack];
                break;
                
            case FetchCenterGetOpFollowPlanAction:{
                Plan *plan = (Plan *)obj;
                plan.followCount = @(plan.followCount.integerValue + 1);
                plan.isFollowed = @(YES);
                [self.delegate didFinishFollowingPlan:plan];
            }
                break;
            case FetchCenterGetOpUnFollowPlanAction:{
                Plan *plan = (Plan *)obj;
                plan.followCount = @(plan.followCount.integerValue - 1);
                plan.isFollowed = @(NO);
                [self.delegate didFinishUnFollowingPlan:plan];
            }
                break;
            case FetchCenterGetOpGetMessageList:{
                NSArray *messagesArray = [json valueForKeyPath:@"data.messageList"];
                NSDictionary *owners = [json valueForKeyPath:@"data.manList"];
                for (NSDictionary *message in messagesArray){
                    NSDictionary *ownerInfo = owners[message[@"operatorId"]];
                    [Message updateMessageWithInfo:message ownerInfo:ownerInfo];
//                    NSLog(@"%@",a);
                }
            }
                break;
            case FetchCenterGetOpGetMessageNotificationInfo:{
                NSNumber *unreadFollowCount = @([[json valueForKeyPath:@"data.unreadCountFollow"] integerValue]);
                NSNumber *unreadMsgCount = @([[json valueForKeyPath:@"data.unreadCountMsg"] integerValue]);
                [self.delegate didFinishGettingMessageNotificationWithMessageCount:unreadMsgCount
                                                                       followCount:unreadFollowCount];
//                NSLog(@"%@",json);

            }
                break;
                
            case FetchCenterGetOpClearAllMessages:
                [self.delegate didFinishClearingAllMessages];
                break;
                
            case FetchCenterGetOpGetSignature:{
                NSString *signature = [json valueForKey:@"sign"];
                if (signature) {
                    [User storeSignature:signature];
                    [self.delegate didfinishGettingSignature];
                }
            }
                break;
                
            case FetchCenterGetOpGetAccessTokenAndOpenIdWithWechatCode:{
                //            NSString *refreshToken = json[@"refresh_token"];
                //            NSString *scope = json[@"scope"];
                //            NSString *unionId = json[@"unionid"];
                /**
                 此接口用于获取用户个人信息。开发者可通过OpenID来获取用户基本信息。特别需要注意的是，如果开发者拥有多个移动应用、网站应用和公众帐号，可通过获取用户基本信息中的unionid来区分用户的唯一性，因为只要是同一个微信开放平台帐号下的移动应用、网站应用和公众帐号，用户的unionid是唯一的。换句话说，同一用户，对同一个微信开放平台下的不同应用，unionid是相同的。
                 **/
                
                NSString *accessToken = json[@"access_token"];
                NSString *openId = json[@"openid"];
                
                //过期的参照点为当前请求的时刻
                NSDate *expireDate = [NSDate dateWithTimeInterval:[json[@"expires_in"] integerValue] sinceDate:[NSDate date]];
                
                [User updateAttributeFromDictionary:@{ACCESS_TOKEN:accessToken,
                                                      OPENID:openId,
                                                      EXPIRATION_DATE:expireDate}];

                [self getUidandUkeyWithOpenId:openId accessToken:accessToken completion:nil];
            }
                break;
                
            default:
                break;
        }
    }));
}

#pragma mark - 登陆相关

- (void)fetchWechatUserInfoWithOpenID:(NSString *)openID token:(NSString *)accessToken{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openID]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (!connectionError) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@",json);
            NSString *picUrl = json[@"headimgurl"];
            NSString *nickname = json[@"nickname"];
            NSString *gender = [json[@"sex"] integerValue] ? @"男" : @"女";
            [User updateAttributeFromDictionary:@{PROFILE_PICTURE_ID:picUrl,
                                                  USER_DISPLAY_NAME:nickname,
                                                  GENDER:gender}];
            NSLog(@"Fetched WeChat User Info \n%@",[User getOwnerInfo]);
            dispatch_main_async_safe(^{
                [self.delegate didFinishGettingWeChatUserInfo];
            });
        }
        
    }];
}

- (void)getUidandUkeyWithOpenId:(NSString *)openId
                    accessToken:(NSString *)token
                     completion:(FetchCenterGetRequestGetUidAndUkeyCompleted)completionBlock{
    //loginType在这个函数之前必段保留
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,GETUID];
    NSDictionary *args = @{@"openid":openId,
                           @"token":token};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSString *uid = [responseJson valueForKeyPath:@"data.uid"];
        NSString *ukey = [responseJson valueForKeyPath:@"data.ukey"];
        BOOL isNewUser = [[responseJson valueForKeyPath:@"data.isNew"] boolValue];
        NSDictionary *userInfo = [responseJson valueForKeyPath:@"data.maninfo"];
        
        //update local user info & UI
        NSDictionary *localUserInfo = @{UID:uid,UKEY:ukey};
        [User updateAttributeFromDictionary:localUserInfo];
        if (completionBlock) {
            completionBlock(userInfo,isNewUser);
        }
    }];
}

- (void)getAccessTokenWithWechatCode:(NSString *)code
                          completion:(FetchCenterGetRequestGetUidAndUkeyCompleted)completionBlock{
    if (code) {
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,GET_ACCESSTOKEN_OPENID];
        [self getRequest:rqtStr parameter:@{@"code":code} includeArguments:YES completion:^(NSDictionary *responseJson) {
            NSString *accessToken = responseJson[@"access_token"];
            NSString *openId = responseJson[@"openid"];
            
            //过期的参照点为当前请求的时刻
            NSDate *expireDate = [NSDate dateWithTimeInterval:[responseJson[@"expires_in"] integerValue]
                                                    sinceDate:[NSDate date]];
            
            [User updateAttributeFromDictionary:@{ACCESS_TOKEN:accessToken,
                                                  OPENID:openId,
                                                  EXPIRATION_DATE:expireDate}];
            
            [self getUidandUkeyWithOpenId:openId accessToken:accessToken completion:^(NSDictionary *userInfo, BOOL isNewUser) {
                if (completionBlock) {
                    completionBlock(userInfo,isNewUser);
                }
            }];
        }];
    }
}

#pragma mark - 后台错误码

- (NSDictionary *)backendErrorCode{
    if (!_backendErrorCode) {
        _backendErrorCode = @{
                              @(-100):@"数据库连接失败",
                              @(-101):@"数据库执行失败",
//                              @(-102):@"没有这个数据或数据原本就这样", //由于出现这条错误的频率较高，暂时不提示这条
                              @(-200):@"输入的参数没有想要的",
                              @(-201):@"输入参数缺少id",
                              @(-202):@"缺少想要的输入参数",
                              @(-203):@"Post Body部分是空的",
                              @(-204):@"登陆数据有误",
                              @(-205):@"缺少登录态数据",
                              @(-206):@"非法的登录信息，验证失败",
                              @(-207):@"错误的key，没有权限执行",
                              @(-301):@"删除plan时，在个人信息里planlist是空的",
                              @(-302):@"删除plan时，在planlist中没有找到",
//                              @(-303):@"arrayId是空的",  //数组里不存在任何信息，（例如：没有评论）
                              @(-304):@"列表是空的",
                              @(-305):@"版本的格式错误",
                              @(-306):@"版本太低，需要升级",
                              @(-307):@"版本为空",
                              @(-310):@"不应该到这里",
                              @(-320):@"检测到脏词",
                              @(-321):@"没有权限，因为不是主人",
                              @(-322):@"只有一条feeds，不允许删除",
                              @(-400):@"不能超过个人创建的上限",
                              @(-401):@"不能超过单个plan允许的feeds上限",
                              @(-402):@"列表满了"
                              };
    }
    return _backendErrorCode;
}

- (void)alertWithBackendErrorCode:(NSNumber *)errorCode{
    if ([self.backendErrorCode.allKeys containsObject:errorCode]) {
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            NSString *msg = self.backendErrorCode[errorCode];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"来自后台的提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            UIViewController *vc = (UIViewController *)self.delegate;
            [vc presentViewController:alert animated:YES completion:nil];
        }
    }
    
}


@end

