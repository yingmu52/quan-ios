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

typedef void(^FetchCenterImageUploadCompletionBlock)(NSString *fetchedId); //上传图像成功
typedef void(^FetchCenterGetRequestCompletionBlock)(NSDictionary *responseJson); //请求成功

@interface FetchCenter ()
@property (nonatomic,strong) NSString *baseUrl;
@property (nonatomic,strong) Reachability *reachability;
@property (nonatomic,strong) NSDictionary *backendErrorCode;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,weak) AppDelegate *appDelegate;
@end
@implementation FetchCenter

- (AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

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
                  if (completionBlock) {
                      dispatch_main_async_safe(^{
                          completionBlock(circleId);
                      });
                      
                  }
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
                      dispatch_main_async_safe(^{
                          completionBlock();
                      });
                      
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
                  [circles addObject:[Circle updateCircleWithInfo:info managedObjectContext:[AppDelegate getContext]]];
              }
//              NSLog(@"%@",circles);
              if (completionBlock) {
                  dispatch_main_async_safe(^{
                      completionBlock(circles);                      
                  });
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

- (void)clearAllMessages:(FetchCenterGetRequestClearMessageListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,CLEAR_ALL_MESSAGES];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}


- (void)getMessageList:(FetchCenterGetRequestGetMessageListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,GET_MESSAGE_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":[User uid]}
    includeArguments:YES completion:^(NSDictionary *responseJson) {
        
        __block NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workerContext.parentContext = self.appDelegate.managedObjectContext;
        
        NSArray *messagesArray = [responseJson valueForKeyPath:@"data.messageList"];
        NSDictionary *owners = [responseJson valueForKeyPath:@"data.manList"];
        for (NSDictionary *message in messagesArray){
            NSDictionary *ownerInfo = owners[message[@"operatorId"]];
            [Message updateMessageWithInfo:message ownerInfo:ownerInfo managedObjectContext:[AppDelegate getContext]];
        }
        //        NSLog(@"%@",responseJson);
        [self.appDelegate saveContext:workerContext];
        if (completionBlock) {
            NSArray *messageIds = [responseJson valueForKeyPath:@"data.messageList.messageId"];
            completionBlock(messageIds);
        }

        
    }];
}

- (void)getMessageNotificationInfo:(FetchCenterGetRequestGetMessageNotificationCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,GET_MESSAGE_NOTIFICATION];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSNumber *unreadFollowCount = @([[responseJson valueForKeyPath:@"data.unreadCountFollow"] integerValue]);
        NSNumber *unreadMsgCount = @([[responseJson valueForKeyPath:@"data.unreadCountMsg"] integerValue]);
        if (completionBlock) {
            completionBlock(unreadMsgCount,unreadFollowCount);
        }
    }];
}

#pragma mark - 评论和回复

- (void)deleteComment:(Comment *)comment
           completion:(FetchCenterGetRequestDeleteCommentCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,DELETE_COMMENT];
    NSDictionary *args = @{@"id":comment.commentId,@"feedsId":comment.feed.feedId};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        if (completionBlock) {
            NSLog(@"评论删除成功 %@",comment.commentId);
            completionBlock();
        }
    }];
}


- (void)getCommentListForFeed:(NSString *)feedId
                     pageInfo:(NSDictionary *)info
                   completion:(FetchCenterGetRequestGetCommentListCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,GET_FEED_COMMENTS];
    NSString *infoStr = info ? [self convertDictionaryToString:info] : @"";
    
    NSDictionary *args = @{@"feedsId":feedId,
                           @"attachInfo":infoStr};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        
        
        __block NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workerContext.parentContext = self.appDelegate.managedObjectContext;
        
        NSDictionary *ownerInfo = [responseJson valueForKeyPath:@"data.manList"];
        BOOL hasNextPage = [[responseJson valueForKeyPath:@"data.isMore"] boolValue];
        NSDictionary *pageInfo = [responseJson valueForKeyPath:@"data.attachInfo"];
        NSDictionary *feedInfo = [responseJson valueForKeyPath:@"data.feeds"];
        
        Feed *feed = [Feed updateFeedWithInfo:feedInfo forPlan:nil ownerInfo:nil managedObjectContext:workerContext];
        NSArray *comments = [responseJson valueForKeyPath:@"data.commentList"];
        NSMutableArray *localComments = [NSMutableArray arrayWithCapacity:comments.count];
        if (comments.count > 0) {
            for (NSDictionary *commentInfo in comments){
                //读取评论信息
                Comment *comment = [Comment updateCommentWithInfo:commentInfo managedObjectContext:workerContext];
                //读取用户信息
                NSDictionary *userInfo = comment.isMyComment.boolValue ? [Owner myWebInfo] : ownerInfo[commentInfo[@"ownerId"]];
                Owner *owner = [Owner updateOwnerWithInfo:userInfo managedObjectContext:workerContext];
                
                //防止更新相同的评论数据
                if (!comment.owner) {
                    comment.owner = owner;
                }
                if (!comment.feed) {
                    comment.feed = feed;
                }
                if (comment.idForReply) {
                    NSString *nameForReply = [ownerInfo[comment.idForReply] objectForKey:@"name"];
                    if (![comment.nameForReply isEqualToString:nameForReply]) {
                        comment.nameForReply = nameForReply;
                    }
                }
                [localComments addObject:comment];
                
            }
        }
        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock) {
            completionBlock(pageInfo,hasNextPage,localComments,feed);
        }
        
    }];
}

- (void)commentOnFeed:(Feed *)feed
              content:(NSString *)text
           completion:(FetchCenterGetRequestCommentCompleted)completionBlock{
    [self replyAtFeed:feed content:text toOwner:nil completion:completionBlock];
}

- (void)replyAtFeed:(Feed *)feed
            content:(NSString *)text
            toOwner:(Owner *)owner
         completion:(FetchCenterGetRequestCommentCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,COMMENT_FEED];
    NSDictionary *args = @{@"feedsId":feed.feedId,
                           @"content":[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"commentTo": (owner ? owner.ownerId : @"")};
    
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        //increase comment count by one
        NSString *commentId = [responseJson valueForKeyPath:@"data.id"];
        Comment *comment;
        if (owner){ //回复
            comment = [Comment replyToOwner:owner content:text commentId:commentId forFeed:feed];
        }else{ //评论
            comment = [Comment createComment:text commentId:commentId forFeed:feed];
        }
        //update feed count
        feed.commentCount = @(feed.commentCount.integerValue + 1);
        if (completionBlock) {
            NSLog(@"评论完成%@",comment.commentId);
            completionBlock(comment);
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


- (void)loadFeedsListForPlan:(Plan *)plan
                    pageInfo:(NSDictionary *)info
                  completion:(FetchCenterGetRequestGetFeedsListCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,LOAD_FEED_LIST];
    NSString *infoStr = info ? [self convertDictionaryToString:info] : @"";
    NSDictionary *args = @{@"id":plan.planId,@"attachInfo":infoStr};
    [self getRequest:rqtStr
           parameter:args
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
    {
        
        __block NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workerContext.parentContext = self.appDelegate.managedObjectContext;

        NSArray *feeds = [responseJson valueForKeyPath:@"data.feedsList"];
        NSDictionary *pageInfo = [responseJson valueForKeyPath:@"data.attachInfo"];
        NSNumber *isFollowed  = @([[responseJson valueForKeyPath:@"data.isFollowed"] boolValue]);
        NSDictionary *planInfo = [responseJson valueForKeyPath:@"data.plan"];
        NSDictionary *ownerInfo = [responseJson valueForKeyPath:@"data.man"];
        if (![plan.isFollowed isEqualToNumber:isFollowed]){
            plan.isFollowed = isFollowed;
        }
        
        for (NSDictionary *feedInfo in feeds){
            [Feed updateFeedWithInfo:feedInfo
                             forPlan:planInfo
                           ownerInfo:ownerInfo
                managedObjectContext:workerContext];
        }
        
        NSArray *feedIds = [responseJson valueForKeyPath:@"data.feedsList.id"];
        BOOL hasNextPage = [[responseJson valueForKeyPath:@"data.isMore"] boolValue];
        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock) {
            completionBlock(pageInfo,hasNextPage,feedIds);
        }

    }];
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

- (void)uploadImages:(NSArray *)images completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSMutableDictionary *imageIdMaps = [NSMutableDictionary dictionary];
        dispatch_apply(images.count, queue, ^(size_t index){
            [self postImageWithOperation:images[index]
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
                             
                             if (completionBlock) {
                                 completionBlock(sorted);
                             }
//                             [self.delegate didFinishUploadingImage:sorted forFeed:feed];
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
        
        //increase feed like count
        feed.likeCount = @(feed.likeCount.integerValue + 1);
        feed.selfLiked = @(YES);

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
        
        //decrease feed like count
        feed.likeCount = @(feed.likeCount.integerValue - 1);
        feed.selfLiked = @(NO);

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
        
        __block NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workerContext.parentContext = self.appDelegate.managedObjectContext;
        
        for (NSDictionary *planInfo in [responseJson valueForKeyPath:@"data.planList"]) {
            NSDictionary *userInfo = [responseJson valueForKeyPath:[NSString stringWithFormat:@"data.manList.%@",planInfo[@"ownerId"]]];
            Plan *plan = [Plan updatePlanFromServer:planInfo
                                          ownerInfo:userInfo
                               managedObjectContext:workerContext];
            
            if (![plan.isFollowed isEqualToNumber:@(YES)]){
                plan.isFollowed = @(YES);
            }
            
            NSArray *feedsList = planInfo[@"feedsList"];
            if (feedsList.count) {
                //create all feeds
                for (NSDictionary *feedInfo in feedsList) {
                    [Feed updateFeedWithInfo:feedInfo
                                     forPlan:planInfo
                                   ownerInfo:userInfo
                        managedObjectContext:workerContext];
                    
                    //use alternative way to load and cache image
                }
            }
        }
        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock){
            NSArray *planIds = [responseJson valueForKeyPath:@"data.planList.id"];
            completionBlock(planIds);
        }
        
    }];
}

#pragma mark - 发现事件

- (void)getDiscoveryList:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,DISCOVER,GET_DISCOVER_LIST];
    [self getRequest:rqtStr
           parameter:nil
    includeArguments:YES
          completion:^(NSDictionary *responseJson) {
              
        __block NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workerContext.parentContext = self.appDelegate.managedObjectContext;

        NSMutableArray *plans = [NSMutableArray array];
        NSArray *planList = [responseJson valueForKeyPath:@"data.planList"];
        NSDictionary *manList = [responseJson valueForKeyPath:@"data.manList"];
        NSString *title = [responseJson valueForKeyPath:@"data.quanInfo.name"];

        //缓存并更新本地事件
        if (planList && manList){
          [planList enumerateObjectsUsingBlock:^(NSDictionary * planInfo, NSUInteger idx, BOOL * _Nonnull stop) {
              Plan *plan = [Plan updatePlanFromServer:planInfo
                                            ownerInfo:[manList valueForKey:planInfo[@"ownerId"]]
                                 managedObjectContext:workerContext];
              plan.discoverIndex = @(idx); //记录索引方便显示服务器上的顺序
              [plans addObject:plan];
              //                NSLog(@"%@, mask : %@, index %@",plan.planTitle,plan.cornerMask,plan.discoverIndex);
          }];
        }

        [self.appDelegate saveContext:workerContext];
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

- (void)uploadNewProfilePicture:(UIImage *)picture
                     completion:(FetchCenterPostRequestUploadImagesCompleted)completionBlock{
    [self postImageWithOperation:picture complete:^(NSString *fetchedId) {
        if (fetchedId){
            [User updateAttributeFromDictionary:@{PROFILE_PICTURE_ID_CUSTOM:fetchedId}];
            NSLog(@"image uploaded %@",fetchedId);
            if (completionBlock) {
                completionBlock(@[fetchedId]);
            }
        }
    }];
}

- (void)setPersonalInfo:(NSString *)nickName
                 gender:(NSString *)gender
                imageId:(NSString *)imageId
             occupation:(NSString *)occupation
           personalInfo:(NSString *)info
             completion:(FetchCenterGetRequestSetPersonalInfoCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,SET_USER_INFO];
    
    NSString *ocpStr = occupation ? occupation : @"";
    NSString *infoStr = info ? info : @"";
    NSDictionary *args = @{@"name":[nickName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"gender":[gender isEqualToString:@"男"] ? @(1):@(0),
                           @"headUrl":imageId,
                           @"profession":[ocpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"description":[infoStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        [User updateAttributeFromDictionary:@{USER_DISPLAY_NAME:nickName,
                                              GENDER:gender,
                                              PROFILE_PICTURE_ID_CUSTOM:imageId,
                                              OCCUPATION:occupation,
                                              PERSONALDETAIL:info}];
        NSLog(@"%@",[User getOwnerInfo]);
        if (completionBlock) {
            completionBlock();
        }
    }];
    
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
            Plan * plan = [Plan updatePlanFromServer:planInfo
                                           ownerInfo:[Owner myWebInfo]
                                managedObjectContext:[AppDelegate getContext]];
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
                 NSLog(@"上传失败");
                 if ([self.delegate respondsToSelector:@selector(didFailUploadingImage:)]) {
                     [self.delegate didFailUploadingImage:image];
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
                                          if (data){
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
                                          }
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

#pragma mark - 登陆相关

- (void)getWechatUserInfoWithOpenID:(NSString *)openID
                              token:(NSString *)accessToken
                         completion:(FetchCenterGetRequestGetWechatUserInfoCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo"];
    NSDictionary *args = @{@"access_token":accessToken,
                           @"openid":openID};
    [self getRequest:rqtStr parameter:args includeArguments:NO completion:^(NSDictionary *responseJson) {
        NSString *picUrl = responseJson[@"headimgurl"];
        NSString *nickname = responseJson[@"nickname"];
        NSString *gender = [responseJson[@"sex"] integerValue] ? @"男" : @"女";
        [User updateAttributeFromDictionary:@{PROFILE_PICTURE_ID:picUrl,
                                              USER_DISPLAY_NAME:nickname,
                                              GENDER:gender}];
        NSLog(@"Fetched WeChat User Info \n%@",[User getOwnerInfo]);
        if (completionBlock) {
            completionBlock();
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

