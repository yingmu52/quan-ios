//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"

#define PROJECT @"/superplan/"

#define PUSH @"push/"
#define SEND_DEVICETOKEN @"splan_push_token.php"

#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"
#define CREATE_PLAN @"splan_plan_create.php"
#define CREATE_PLAN_FEED @"splan_plan_create_v2.php" //优化创建事件和创建动态：先上传图片，然后直接创建事件和动态
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
#define GET_H5_INVITATION_URL @"splan_quan_invite.php"
#define JOINT_CIRCLE @"splan_quan_join.php"
#define GET_MEMBER_LIST @"splan_quan_get_manlist.php"
#define TOOL @"tool/"
#define GET_CIRCLE_LIST @"splan_quan_get_quanlist.php"
//#define GET_CIRCLE_LIST @"tool_quan_get.php"
#define DELETE_MEMBER @"splan_quan_man_del.php"
#define GET_CIRCLE_PLAN_LIST @"splan_quan_get_planlist.php"

#define SWITCH_CIRCLE @"tool_quan_man.php"
#define CREATE_CIRCLE @"splan_quan_create.php"
#define DELETE_CIRCLE @"splan_quan_delete_id.php"
#define UPDATE_CIRCLE @"splan_quan_update.php"


#define MESSAGE @"message/"
#define GET_MESSAGE_LIST @"splan_message_getlist.php"
#define GET_MESSAGE_NOTIFICATION @"splan_count_get.php"
#define CLEAR_ALL_MESSAGES @"splan_message_clear.php"

#define TENCENTYOUTU @"tencentYoutu/"
#define GET_SIGNATURE @"getsign.php"


#define SYSTEM @"sys/"
#define CHECK_WHITELIST @"whitelist.php"


@interface FetchCenter ()
@property (nonatomic,strong) NSString *baseUrl;
@property (nonatomic,strong) Reachability *reachability;
@property (nonatomic,strong) NSDictionary *backendErrorCode;
@property (nonatomic,weak) AppDelegate *appDelegate;
@end
@implementation FetchCenter

- (AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (NSManagedObjectContext *)workerContext{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = self.appDelegate.managedObjectContext;
    return context;
}

- (void)checkWhitelist:(FetchCenterGetRequestCheckWhitelistCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,SYSTEM,CHECK_WHITELIST];
    [self getRequest:rqtStr
           parameter:nil
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
     {
         BOOL isSuperUser = [responseJson[@"iswhite"] boolValue];
         if (![User isSuperUser] && isSuperUser) {
             [User updateAttributeFromDictionary:@{IS_SUPERUSER:@(isSuperUser)}];
         }
         if (completionBlock) {
             completionBlock(isSuperUser);
         }
     }];
}

- (void)sendDeviceToken:(NSString *)deviceToken
             completion:(FetchCenterPostRequestSendDeviceTokenCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PUSH,SEND_DEVICETOKEN];
    [self postRequest:rqtStr parameter:@{@"device_token":deviceToken} includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSLog(@"Uploaded Device Token: %@",deviceToken);
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - 圈子
#define TOOLCGIKEY @"123$%^abc"


- (void)getH5invitationUrlWithCircleId:(NSString *)circleId
                            completion:(FetchCenterGetRequestGetCircleInvitationURLCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,GET_H5_INVITATION_URL];
    NSDictionary *args = @{@"quanid":circleId};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSLog(@"%@",responseJson);
        NSString *urlString = [responseJson objectForKey:@"inviteurl"];
        
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock(urlString);
            });
        }
    }];
}

- (void)getPlanListInCircleId:(NSString *)circleId
                    localList:(NSArray *)localList 
                       onPage:(NSNumber *)page
                   completion:(FetchCenterGetRequestGetCirclePlanListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,GET_CIRCLE_PLAN_LIST];
    NSDictionary *inputParams = @{@"id":circleId};
    [self getRequest:rqtStr
           parameter:inputParams
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
     {
         
         NSManagedObjectContext *workerContext = [self workerContext];
         
         NSArray *planList = [responseJson valueForKeyPath:@"data.planList"];
         NSDictionary *manList = [responseJson valueForKeyPath:@"data.manList"];
         
         NSNumber *currentPage = @(1);
         NSNumber *totalPage = @(1);

         //设置圈子信息
         NSDictionary *circleInfo = [responseJson valueForKeyPath:@"data.quanInfo"];
         
         if (planList.count > 0 && manList.count > 0) {
             
             currentPage = [responseJson valueForKeyPath:@"data.page"];
             totalPage = [responseJson valueForKeyPath:@"data.totalpage"];
             Circle *circle = [Circle updateCircleWithInfo:circleInfo
                                      managedObjectContext:workerContext];
             
             //缓存并更新本地事件
             for (NSDictionary *planInfo in planList) {
                 Plan *plan = [Plan updatePlanFromServer:planInfo
                                               ownerInfo:[manList valueForKey:planInfo[@"ownerId"]]
                                    managedObjectContext:workerContext];
                 if (![plan.circle.circleId isEqualToString:circle.circleId]) {
                     plan.circle = circle;
                 }
             }
             
             //同步
             if (currentPage.integerValue == 1){
                 NSArray *serverList = [planList valueForKeyPath:@"id"];
                 [self syncEntity:@"Plan" idName:@"planId" localList:localList serverList:serverList];
             }
             
             
             [self.appDelegate saveContext:workerContext];
             
         }
         
         if (completionBlock) {
             dispatch_main_async_safe(^{
                 completionBlock(currentPage,totalPage);
             });
         }

         
     }];
    
    
}

- (void)deleteMember:(NSString *)memberID
            inCircle:(NSString *)circleID
          completion:(FetchCenterGetRequestDeleteMemberCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,DELETE_MEMBER];
    NSDictionary *inputParams = @{@"manId":memberID,
                                  @"quanId":circleID};
    [self getRequest:rqtStr
           parameter:inputParams
    includeArguments:YES
          completion:^(NSDictionary *responseJson){
              if (completionBlock) {
                  dispatch_main_async_safe(^{
                      completionBlock();
                  });
              }
          }
     ];
}

//目前只有圈主才可以看到成员
- (void)getMemberListForCircleId:(NSString *)circleId
                       localList:(NSArray *)localList
                      completion:(FetchCenterGetRequestGetMemberListCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,GET_MEMBER_LIST];
    NSDictionary *inputParams = @{@"id":circleId};
    [self getRequest:rqtStr
           parameter:inputParams
    includeArguments:YES
          completion:^(NSDictionary *responseJson){
              
              //后台在成员列表里没有返回主人ID，需要特别处理
              NSArray *manList = [responseJson valueForKeyPath:@"data.manList"];
              NSDictionary *manInfo = [responseJson valueForKeyPath:@"data.manData"];
              if (manList.count > 0) {
                  NSManagedObjectContext *workerContext = [self workerContext];
                  for (NSString *uid in manList) {
                      NSDictionary *ownerInfo = [manInfo valueForKey:uid];
                      [Owner updateOwnerWithInfo:ownerInfo managedObjectContext:workerContext];
                  }
                  //改成多对多的关系后对会用到同步
//                  [self syncEntity:@"Owner" idName:@"ownerId" localList:localList serverList:manList];
                  [self.appDelegate saveContext:workerContext];
              }
              
              
              if (completionBlock) {
                  dispatch_main_async_safe(^{
                      completionBlock(manList);
                  });
              }
          }
     ];
}
- (void)updateCircle:(NSString *)circleId
                name:(NSString *)circleName
         description:(NSString *)circleDescription
     backgroundImage:(NSString *)imageId
          completion:(FetchCenterGetRequestUpdateCircleCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,UPDATE_CIRCLE];
    
    if (circleId) {
        NSDictionary *inputParams = @{@"id":circleId,
                                      @"name":circleName ? [circleName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"",
                                      @"description":circleDescription ? [circleDescription stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"",
                                      @"backGroudPic":imageId ? imageId : @""};
        [self getRequest:rqtStr
               parameter:inputParams
        includeArguments:YES
              completion:^(NSDictionary *responseJson){
                  if (completionBlock) {
                      dispatch_main_async_safe(^{
                          completionBlock();
                      });
                  }
              }
         ];
    }
}

- (void)createCircle:(NSString *)circleName
         description:(NSString *)circleDescription
   backgroundImageId:(NSString *)imageId
          completion:(FetchCenterGetRequestCreateCircleCompleted)completionBlock{
    if (circleName) {
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,CREATE_CIRCLE];
        [self getRequest:rqtStr
               parameter:@{@"name":[circleName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"description":circleDescription ? [circleDescription stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"",
                           @"backGroudPic":imageId ? imageId : @""}
        includeArguments:YES
              completion:^(NSDictionary *responseJson)
        {
            NSString *circleId = [responseJson valueForKeyPath:@"data.id"];
            if (circleId) {
                //在本地数据库创建圈子实例
                NSManagedObjectContext *workerContext = [self workerContext];
                Circle *circle = [Circle createCircle:circleId
                                                 name:circleName
                                                 desc:circleDescription
                                              imageId:imageId
                                              context:workerContext];
                [self.appDelegate saveContext:workerContext];
                
                //完成
                if (completionBlock) {
                    dispatch_main_async_safe(^{
                        completionBlock(circle);
                    })
                }
            }
        }];
    }
}


- (void)deleteCircle:(NSString *)circleId
          completion:(FetchCenterGetRequestDeleteCircleCompleted)completionBlock{
    //TODO: 判断当前用户是否有删除圈子的权限
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,DELETE_CIRCLE];
    [self getRequest:rqtStr
           parameter:@{@"id":circleId}
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
    {
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
    
    
}

- (void)joinCircleId:(NSString *)circleId
         nonceString:(NSString *)noncestr
           signature:(NSString *)signature
          expireTime:(NSString *)expireTime
          inviteCode:(NSString *)code
          completion:(FetchCenterGetRequestJoinCircleCompleted)completionBlock
{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,JOINT_CIRCLE];
    NSDictionary *args = @{@"quanid":circleId,
                           @"noncestr":noncestr,
                           @"signature":signature,
                           @"expiretime":expireTime,
                           @"invitecode":code};
    [self getRequest:rqtStr
           parameter:args
    includeArguments:YES
          completion:^(NSDictionary *responseJson) {
              NSLog(@"%@",responseJson);
              NSDictionary *quanInfo = responseJson[@"quanInfo"];
              /*
              quanInfo =     {
                  backGroudPic = "";
                  createTime = 1469809666;
                  description = "the only one that";
                  id = quan579b8402f0fd2;
                  name = "I am a bit";
                  ownerId = 100045;
                  private = 1;
              };
              */
              NSManagedObjectContext *workerContext = [self workerContext];
              [Circle updateCircleWithInfo:quanInfo managedObjectContext:workerContext];
              [self.appDelegate saveContext:workerContext];
              if (completionBlock) {
                  dispatch_main_async_safe(^{
                      completionBlock(quanInfo[@"name"]);
                  });
                  
              }
          }];

}

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

- (void)getCircleList:(NSArray *)localList
               onPage:(NSNumber *)currentPage
           completion:(FetchCenterGetRequestGetCircleListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,CIRCLE,GET_CIRCLE_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":[User uid]}
         includeArguments:YES
          completion:^(NSDictionary *responseJson) {
              
              NSManagedObjectContext *workerContext = [self workerContext];
              
              NSArray *circleList = [responseJson valueForKeyPath:@"data.quanlist"];
              NSNumber *currentPage = [responseJson valueForKeyPath:@"data.page"];
              NSNumber *totalPage = [responseJson valueForKeyPath:@"data.totalpage"];
              
              
              for (NSDictionary *info in circleList) {
                  [Circle updateCircleWithInfo:info managedObjectContext:workerContext];
              }
              
              
              if (currentPage.integerValue == 1) {
                  NSArray *serverList = [responseJson valueForKeyPath:@"data.quanlist.id"];
                  [self syncEntity:@"Circle" idName:@"circleId" localList:localList serverList:serverList];
              }
              
              
              [self.appDelegate saveContext:workerContext];
              
              if (completionBlock) {
                  dispatch_main_async_safe(^{
                      completionBlock(currentPage,totalPage);
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
            dispatch_main_async_safe(^{
                completionBlock(signature);
            });
        }
        
    }];
}

#pragma mark - 消息

- (void)clearAllMessages:(FetchCenterGetRequestClearMessageListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,CLEAR_ALL_MESSAGES];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
}



- (void)getMessageListWithLocalList:(NSArray *)localList
                             onPage:(NSNumber *)currentPage
                         completion:(FetchCenterGetRequestGetMessageListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,GET_MESSAGE_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":[User uid]}
    includeArguments:YES completion:^(NSDictionary *responseJson) {
        
        
        NSManagedObjectContext *workerContext = [self workerContext];
        
        NSArray *messagesArray = [responseJson valueForKeyPath:@"data.messageList"];
        NSDictionary *owners = [responseJson valueForKeyPath:@"data.manList"];
        
        NSNumber *currentPage = [responseJson valueForKeyPath:@"data.page"];
        NSNumber *totalPage = [responseJson valueForKeyPath:@"data.totalpage"];

        for (NSDictionary *message in messagesArray){
            NSDictionary *ownerInfo = owners[message[@"operatorId"]];
            [Message updateMessageWithInfo:message ownerInfo:ownerInfo managedObjectContext:workerContext];
        }

        
        if (currentPage.integerValue == 1) {
            NSArray *serverList = [responseJson valueForKeyPath:@"data.messageList.messageId"];
            [self syncEntity:@"Message" idName:@"messageId" localList:localList serverList:serverList];
        }
        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock(currentPage,totalPage);
            });
            
        }
        
        
    }];
}

- (void)getMessageNotificationInfo:(FetchCenterGetRequestGetMessageNotificationCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,MESSAGE,GET_MESSAGE_NOTIFICATION];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        NSNumber *unreadFollowCount = @([[responseJson valueForKeyPath:@"data.unreadCountFollow"] integerValue]);
        NSNumber *unreadMsgCount = @([[responseJson valueForKeyPath:@"data.unreadCountMsg"] integerValue]);
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock(unreadMsgCount,unreadFollowCount);
            });
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
            dispatch_main_async_safe(^{
                NSLog(@"评论删除成功 %@",comment.commentId);
                completionBlock();
            });
        }
    }];
}


- (void)getCommentListForFeed:(NSString *)feedId
                    localList:(NSArray *)localList
                  currentPage:(NSNumber *)localCurrentPage
                   completion:(FetchCenterGetRequestGetCommentListCompleted)completionBlock{


    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,GET_FEED_COMMENTS];
    
    
    NSDictionary *args = localCurrentPage ? @{@"feedsId":feedId,@"page":localCurrentPage} : @{@"feedsId":feedId};
    [self getRequest:rqtStr
           parameter:args
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
    {
        
        //读json数据
        NSArray *comments = [responseJson valueForKeyPath:@"data.commentList"];
        NSDictionary *feedInfo = [responseJson valueForKeyPath:@"data.feeds"];

        NSManagedObjectContext *workerContext = [self workerContext];
        
        Feed *feed = [Feed updateFeedWithInfo:feedInfo
                                      forPlan:nil
                                    ownerInfo:nil
                         managedObjectContext:workerContext];

        BOOL hasComments = comments.count > 0;
        NSNumber *currentPage = @(0);
        NSNumber *totalPage = @(0);

        if (hasComments && feed) {
            
            NSDictionary *ownerInfo = [responseJson valueForKeyPath:@"data.manList"];

            currentPage = [responseJson valueForKeyPath:@"data.page"];
            totalPage = [responseJson valueForKeyPath:@"data.totalpage"];

            
            
            for (NSDictionary *commentInfo in comments){
                //读取用户信息取评论信息
                NSDictionary *userInfo = ownerInfo[commentInfo[@"ownerId"]];
                [Comment updateCommentWithInfo:commentInfo
                                     ownerInfo:userInfo
                                        inFeed:feed
                          managedObjectContext:workerContext];
            }
        }
        
        //同步第一页数据
        if (currentPage.integerValue == 1) {
            NSArray *serverList = [comments valueForKey:@"id"];
            [self syncEntity:@"Comment" idName:@"commentId" localList:localList serverList:serverList];
        }

        [self.appDelegate saveContext:workerContext];


        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock(currentPage,totalPage,hasComments);
            });
        }
        
    }];
}

- (void)replyToFeedID:(NSString *)feedID
            content:(NSString *)text
            toOwnerID:(NSString *)ownerID
            ownerName:(NSString *)ownerName
         completion:(FetchCenterGetRequestCommentCompleted)completionBlock{
    
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,COMMENT_FEED];
    NSDictionary *args = @{@"feedsId":feedID,
                           @"content":[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"commentTo": (ownerID ? ownerID : @"")};
    
    [self getRequest:rqtStr
           parameter:args 
    includeArguments:YES 
          completion:^(NSDictionary *responseJson)
    {
              
        //increase comment count by one
        NSString *commentId = [responseJson valueForKeyPath:@"data.id"];
              
        Comment *comment;
        NSManagedObjectContext *workerContext = [self workerContext];
              
        if (ownerID){ //回复
            comment = [Comment replyToOwner:ownerID
                                  ownerName:ownerName
                                    content:text 
                                  commentId:commentId
                                  forFeedID:feedID
                     inManagedObjectContext:workerContext];
        }else{ //评论
            comment = [Comment createComment:text 
                                   commentId:commentId 
                                   forFeedID:feedID
                      inManagedObjectContext:workerContext];
        }
        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock) {
            dispatch_main_async_safe(^{
                NSLog(@"评论完成%@",comment.commentId);
                completionBlock();
            });
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
        
        NSManagedObjectContext *workerContext = [self workerContext];

        //Get Plan
        Plan *p = [Plan fetchWith:@"Plan"
                           predicate:[NSPredicate predicateWithFormat:@"planId == %@",feed.plan.planId]
                    keyForDescriptor:@"planId"
                managedObjectContext:workerContext].lastObject;
        //Get Feed
        Feed *f = [Plan fetchWith:@"Feed"
                           predicate:[NSPredicate predicateWithFormat:@"feedId == %@",feed.feedId]
                    keyForDescriptor:@"feedId"
                managedObjectContext:workerContext].lastObject;
        
        //Update Plan
        if (p.feeds.count == 1) {
            [workerContext deleteObject:p];
        }else if (p.feeds.count > 1){
            NSArray *sortedArray = [p.feeds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]]];
            Feed *first = [sortedArray firstObject];
            Feed *second = [sortedArray objectAtIndex:1];
            if ([f.feedId isEqualToString:first.feedId]){
                //delete plan image
                p.backgroundNum = second.imageId;
            }
            p.tryTimes = @(p.tryTimes.integerValue - 1);            
        }
        
        //Delete Feed
        [workerContext deleteObject:f];
        [self.appDelegate saveContext:workerContext];

        
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
}


- (void)getFeedsListForPlan:(NSString *)planId
                  localList:(NSArray *)localList
                     onPage:(NSNumber *)localPage
                 completion:(FetchCenterGetRequestGetFeedsListCompleted)completionBlock{


    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,LOAD_FEED_LIST];
    NSDictionary *args = localPage ? @{@"id":planId,@"page":localPage} : @{@"id":planId};

    [self getRequest:rqtStr
           parameter:args
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
    {
        
        NSManagedObjectContext *workerContext = [self workerContext];

        NSNumber *isFollowed  = @([[responseJson valueForKeyPath:@"data.isFollowed"] boolValue]);
        
        NSDictionary *planInfo = [responseJson valueForKeyPath:@"data.plan"];
        NSDictionary *ownerInfo = [responseJson valueForKeyPath:@"data.man"];
        
        NSArray *feeds = [responseJson valueForKeyPath:@"data.feedsList"];
        
        NSNumber *currentPage = [responseJson valueForKeyPath:@"data.page"];
        NSNumber *totalPage = [responseJson valueForKeyPath:@"data.totalpage"];

        for (NSDictionary *feedInfo in feeds){
            [Feed updateFeedWithInfo:feedInfo
                             forPlan:planInfo
                           ownerInfo:ownerInfo
                managedObjectContext:workerContext];
        }
        
        
        if (currentPage.integerValue == 1) {
            NSArray *serverList = [feeds valueForKey:@"id"];
            [self syncEntity:@"Feed" idName:@"feedId" localList:localList serverList:serverList];
        }
        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock(currentPage,totalPage,isFollowed);
            });
        }

    }];
}

- (NSString*)convertDictionaryToString:(NSDictionary*)dict{
    NSError* error;
    //giving error as it takes dic, array,etc only. not custom object.
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    return [[[NSString alloc] initWithData:jsonData
                                  encoding:NSUTF8StringEncoding]
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)createFeed:(NSString *)feedTitle
            planId:(NSString *)planId
   fetchedImageIds:(NSArray *)imageIds
        completion:(FetchCenterGetRequestUploadFeedCompleted)completionBlock{
    if (feedTitle && planId && imageIds.count > 0) {
        
        //设置请求参数
        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,CREATE_FEED];
        NSDictionary *args = @{@"picurl":imageIds.firstObject, //第一张为背影图
                               @"content":[feedTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               @"planId":planId,
                               @"picurls":[imageIds componentsJoinedByString:@","],
                               @"feedsType":@(imageIds.count > 1 ? FeedTypeMultiplePicture : FeedTypeSinglePicture)};
        
        [self getRequest:rqtStr
               parameter:args
        includeArguments:YES
              completion:^(NSDictionary *responseJson) {
                  NSString *fetchedFeedID = [responseJson valueForKeyPath:@"data.id"];
                  NSManagedObjectContext *workerContext = [self workerContext];
                  
                  [Feed createFeed:fetchedFeedID
                             title:feedTitle
                            images:imageIds
                            planID:planId
            inManagedObjectContext:workerContext];

                  [self.appDelegate saveContext:workerContext];
                  
                  if (completionBlock) {
                      dispatch_main_async_safe(^{
                          NSLog(@"upload feed successed, ID: %@",fetchedFeedID);
                          completionBlock(fetchedFeedID);
                      });
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
                 if (fetchedId){
                     [imageIdMaps addEntriesFromDictionary:@{fetchedId:@(index)}];
                     if (imageIdMaps.allKeys.count == images.count) {
                         NSLog(@"%@",imageIdMaps);
                         NSArray *sorted = [[imageIdMaps allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                             return [imageIdMaps[obj1] compare:imageIdMaps[obj2]];
                         }];
                         NSLog(@"\n%@\n",sorted);
                         
                         dispatch_main_async_safe(^{
                             if (completionBlock) {
                                 completionBlock(sorted);
                             }
                         });

                     }else{
                         if ([self.delegate respondsToSelector:@selector(didReceivedCurrentProgressForUploadingImage:)]) {
                             
                             dispatch_main_async_safe(^{
                                 CGFloat progress = (imageIdMaps.allKeys.count - 1e-3) / images.count;
                                 [self.delegate didReceivedCurrentProgressForUploadingImage:progress];
                             });
                             
                         }
                     }
                 }
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
                dispatch_main_async_safe(^{
                    completionBlock();
                });

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
                dispatch_main_async_safe(^{
                    completionBlock();
                });
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
            dispatch_main_async_safe(^{
                completionBlock();
            });
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
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
}

- (void)getFollowingList:(NSArray *)localList completion:(FetchCenterGetRequestGetFollowingPlanListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FOLLOW,GET_FOLLOW_LIST];
    
    [self getRequest:rqtStr parameter:@{@"id":[User uid]} includeArguments:YES completion:^(NSDictionary *responseJson) {
        
        NSManagedObjectContext *workerContext = [self workerContext];
        
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
        
        //同步
        NSArray *serverList = [responseJson valueForKeyPath:@"data.planList.id"];
        [self syncEntity:@"Plan"
                  idName:@"planId"
               localList:localList
              serverList:serverList];

        
        [self.appDelegate saveContext:workerContext];
        
        if (completionBlock){
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
        
    }];
}

#pragma mark - 发现事件

- (void)getDiscoveryList:(NSArray *)localList
                  onPage:(NSNumber *)page
              completion:(FetchCenterGetRequestGetDiscoverListCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,DISCOVER,GET_DISCOVER_LIST];
    [self getRequest:rqtStr
           parameter:page ? @{@"page":page} : nil
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
     {
         
         NSManagedObjectContext *workerContext = [self workerContext];
         
         NSArray *planList = [responseJson valueForKeyPath:@"data.planList"];
         NSDictionary *manList = [responseJson valueForKeyPath:@"data.manList"];
         NSNumber *currentPage = [responseJson valueForKeyPath:@"data.page"];
         NSNumber *totalPage = [responseJson valueForKeyPath:@"data.totalpage"];
         
         if (completionBlock) {
             dispatch_main_async_safe(^{
                 completionBlock(currentPage,totalPage);
             });
         }
         
         //缓存并更新本地事件
         if (planList && manList){
             [planList enumerateObjectsUsingBlock:^(NSDictionary * planInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                 [Plan updatePlanFromServer:planInfo
                                  ownerInfo:[manList valueForKey:planInfo[@"ownerId"]]
                       managedObjectContext:workerContext];
//                 plan.discoverIndex = @(idx + 1); //记录索引方便显示服务器上的顺序
             }];
         }
         
        //同步
         if (currentPage.integerValue == 1) { //同步服务器与本地第一页的数据
             NSArray *serverList = [planList valueForKey:@"id"];
              [self syncEntity:@"Plan" idName:@"planId" localList:localList serverList:serverList];
         }

         [self.appDelegate saveContext:workerContext];
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
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
}
- (void)checkVersion:(FetchCenterGetRequestCheckVersionCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,OTHER,CHECK_NEW_VERSION];
    [self getRequest:rqtStr parameter:nil includeArguments:YES completion:^(NSDictionary *responseJson) {
        if (completionBlock) {
            dispatch_main_async_safe(^{
                BOOL hasNewVersion = [[responseJson valueForKeyPath:@"data.haveNew"] boolValue];
                NSLog(@"%@",hasNewVersion ? @"有新版本" : @"无新版本");
                completionBlock(hasNewVersion);
            });
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
                dispatch_main_async_safe(^{
                    completionBlock(@[fetchedId]);
                });
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
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
    
}

#pragma mark - 事件

- (void)updatePlan:(NSString *)planId
             title:(NSString *)planTitle
         isPrivate:(BOOL)isPrivate
       description:(NSString *)planDescription
        completion:(FetchCenterGetRequestUpdatePlanCompleted)completionBlock{
    //输入样例：id=hello_1421235901&title=hello_title2&finishDate=3&backGroudPic=bg3&private=1&state=1&finishPercent=20
    //—— 每一项都可以单独更新
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,UPDATE_PLAN];
    NSDictionary *args = @{@"id":planId,
                           @"title":[planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"private":@(isPrivate),
                           @"description":planDescription ? [planDescription stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""};
    [self getRequest:rqtStr parameter:args includeArguments:YES completion:^(NSDictionary *responseJson) {

        //更新本地事件
        NSManagedObjectContext *workerContext = [self workerContext];
        Plan *plan = [[Plan fetchWith:@"Plan"
                           predicate:[NSPredicate predicateWithFormat:@"planId == %@",planId]
                    keyForDescriptor:@"planId"
                managedObjectContext:workerContext] lastObject];
        plan.planTitle = planTitle;
        plan.detailText = planDescription;
        plan.isPrivate = @(isPrivate);
        [self.appDelegate saveContext:workerContext];


        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
}

- (void)updatePlanId:(NSString *)planId
          planStatus:(PlanStatus)planStatus
          completion:(FetchCenterGetRequestUpdatePlanStatusCompleted)completionBlock{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,UPDATE_PLAN_STATUS];
    NSDictionary *args = @{@"id":planId,
                           @"state":@(planStatus)};
    [self getRequest:rqtStr
           parameter:args
    includeArguments:YES
          completion:^(NSDictionary *responseJson) {
              NSManagedObjectContext *workerContext = [self workerContext];
              Plan *plan = [[Plan fetchWith:@"Plan"
                                  predicate:[NSPredicate predicateWithFormat:@"planId == %@",planId]
                           keyForDescriptor:@"planId"
                       managedObjectContext:workerContext] lastObject];
              plan.planStatus = @(planStatus);
              plan.updateDate = [NSDate date];
              [self.appDelegate saveContext:workerContext];
//        NSLog(@"%@",responseJson);
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            });
        }
    }];
}

- (void)getPlanListForOwnerId:(NSString *)ownerId
                    localList:(NSArray *)localList
                   completion:(FetchCenterGetRequestGetPlanListCompleted)completionBlock
{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,GET_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":ownerId}
    includeArguments:YES
          completion:^(NSDictionary *responseJson)
    {

        
        NSManagedObjectContext *workerContext = [self workerContext];
        NSArray *plansList = responseJson[@"data"];
        
#warning data should return array even when it is empty
        if ([responseJson[@"data"] isKindOfClass:[NSArray class]]) { //non empty array
            for (NSDictionary *planInfo in plansList) {
                [Plan updatePlanFromServer:planInfo
                                 ownerInfo:[Owner myWebInfo]
                      managedObjectContext:workerContext];
            }
            
            NSArray *serverList = [responseJson valueForKeyPath:@"data.id"];
            [self syncEntity:@"Plan" idName:@"planId" localList:localList serverList:serverList];
            
            [self.appDelegate saveContext:workerContext];
            
            if (completionBlock) {
                dispatch_main_async_safe(^{
                    completionBlock();
                });
            }
        }
    }];

}


- (void)createPlan:(NSString *)planTitle
   planDescription:(NSString *)description
          circleID:(NSString *)circleId
           picurls:(NSArray *)picurls
         feedTitle:(NSString *)feedTitle
        completion:(FetchCenterPostRequestPlanAndFeedCreationCompleted)completionBlock{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,CREATE_PLAN_FEED];
    NSDictionary *args = @{@"title":planTitle,
                           @"description":description,
                           @"backGroudPic":picurls.firstObject,
                           @"private":@(1), //事件默认私密
                           @"quanId":circleId,
                           @"picurl":picurls.firstObject,
                           @"picurls":[picurls componentsJoinedByString:@","],
                           @"content":feedTitle};
    [self postRequest:baseUrl
            parameter:args
     includeArguments:YES
           completion:^(NSDictionary *responseJson) {
               NSString *planID = [responseJson valueForKeyPath:@"data.planId"];
               NSString *feedID = [responseJson valueForKeyPath:@"data.feedId"];
               
               NSManagedObjectContext *workerContext = [self workerContext];
               
               [Plan createPlan:planTitle
                         planId:planID
                   backgroundID:picurls.firstObject
                       inCircle:circleId
         inManagedObjectContext:workerContext];
               
               
               [Feed createFeed:feedID
                          title:feedTitle
                         images:picurls
                         planID:planID
         inManagedObjectContext:workerContext];
               
               [self.appDelegate saveContext:workerContext];
               
        if (completionBlock) {
            dispatch_main_async_safe((^{
                completionBlock(planID);
            }));
        }
    }];
    
}

- (void)deletePlanId:(NSString *)planId completion:(FetchCenterGetRequestDeletePlanCompleted)completionBlock{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,DELETE_PLAN];
    NSDictionary *args = @{@"id":planId};
    [self getRequest:baseUrl
           parameter:args 
    includeArguments:YES 
          completion:^(NSDictionary *responseJson) {
              NSManagedObjectContext *workerContext = [self workerContext];
              Plan *plan = [[Plan fetchWith:@"Plan"
                                  predicate:[NSPredicate predicateWithFormat:@"planId = %@",planId]
                           keyForDescriptor:@"planId"
                       managedObjectContext:workerContext] lastObject];
              [workerContext deleteObject:plan];
              [self.appDelegate saveContext:workerContext];
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            });
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

    NSString *content = [NSString stringWithFormat:@"[Date]: %@\n\n[Request]: %@\n\n[Response]: %@\n\n\n\n",[NSDate date],request,[self decodedOBject:response]];
    
    if (fileHandler){
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
    }else{
        [content writeToFile:logPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_TESTURL]) {
        _baseUrl = [NSString stringWithFormat:@"%@%@",TEST_URL,PROJECT];
    }else{
        _baseUrl = [NSString stringWithFormat:@"%@%@",PROD_URL,PROJECT];
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
                      complete:(FetchCenterImageUploadCompletionBlock)completionBlock{
    
    //chekc internet
    if (![self hasActiveInternetConnection]) return;

    //创建本地路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *uuidString = [NSUUID UUID].UUIDString;
    NSString *filePath = [paths[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uuidString]];
    
    //压缩图片
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);

#ifdef DEBUG
    CGFloat originalSize = UIImagePNGRepresentation(image).length/1024.0f; //in KB
    NSLog(@"original size %@ KB", @(originalSize));
    NSLog(@"compressed size %@ KB", @(imageData.length/1024.0f));
    NSAssert(imageData.length, @"0 size image");
#endif
    
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
                 
                 //缓存图片,此法保存图像的方向
                 NSURL *url = [self urlWithImageID:photoResp.photoFileId
                                              size:FetchCenterImageSizeOriginal];
                 SDWebImageManager *manager = [SDWebImageManager sharedManager];
                 [manager.imageCache storeImage:image
                           recalculateFromImage:NO
                                      imageData:UIImageJPEGRepresentation(image, 1.0f)
                                         forKey:[manager cacheKeyForURL:url]
                                         toDisk:NO];
                 

                 completionBlock(photoResp.photoFileId);
                 
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


- (void)getRequest:(NSString *)baseURL
         parameter:(NSDictionary *)dict
  includeArguments:(BOOL)shouldInclude //针对工具类的CGI不需要加统一参数
        completion:(FetchCenterGetRequestCompletionBlock)completionBlock{
    [self sendRequest:baseURL
            parameter:dict
     includeArguments:shouldInclude 
           httpMethod:@"GET"
           completion:completionBlock];
}

- (void)postRequest:(NSString *)baseURL
          parameter:(NSDictionary *)dict
   includeArguments:(BOOL)shouldInclude //针对工具类的CGI不需要加统一参数
         completion:(FetchCenterGetRequestCompletionBlock)completionBlock{
    [self sendRequest:baseURL
            parameter:dict
     includeArguments:shouldInclude
           httpMethod:@"POST"
           completion:completionBlock];
}


- (void)sendRequest:(NSString *)baseURL
          parameter:(NSDictionary *)dict
   includeArguments:(BOOL)shouldInclude //针对工具类的CGI不需要加统一参数
         httpMethod:(NSString *)method
         completion:(FetchCenterGetRequestCompletionBlock)completionBlock{
    @try {
        //检测网络
        if (![self hasActiveInternetConnection]) return;
        
        //设置请求统一参数
        baseURL = [baseURL stringByAppendingString:@"?"];
        baseURL = shouldInclude ? [self addGeneralArgumentsForBaseURL:baseURL] : baseURL;
        
        //拼接参数
        NSString *rqtStr = baseURL;
        if ([method isEqualToString:@"GET"]) {
             rqtStr = [baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:30.0];
        if ([method isEqualToString:@"POST"]) {
            NSString *bodyString = [self argumentStringWithDictionary:dict];
            NSData *bodyData = [[bodyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody = bodyData;
        }
        
        request.HTTPMethod = method;
        //        NSLog(@"%@",rqtStr);
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if (data){
                //递归过滤Json里含带的Null数据
                NSDictionary *rawJson = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
                NSDictionary *responseJson = [self recursiveNullRemove:rawJson];
                //                NSLog(@"%@",responseJson);
                if (responseJson) {
                    if (!error && ![responseJson[@"ret"] integerValue]){ //成功
                        if (completionBlock) {
                            //创建一个新线程，因为每个线程必须有自己的MOC
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                completionBlock(responseJson);
                            });
                        }
                    }else{ //失败
                        
                        //在委托中跳出后台的提示
                        [self alertWithBackendErrorCode:@([responseJson[@"ret"] integerValue])];
                        
                        //假失败写入请求日志
                        [self appendRequest:request andResponse:responseJson];

#ifdef DEBUG
                        NSLog(@"\n\n** 失败 ** \n baseUrl: %@ \n parameter: %@ \n responseJSON: %@ \n error:%@"
                              ,baseURL,dict,[self decodedOBject:responseJson],error);
#endif
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

- (NSString *)decodedOBject:(id)obj{
    const char *content = [[NSString stringWithFormat:@"%@",obj]
                           cStringUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithCString:content
                              encoding:NSNonLossyASCIIStringEncoding];
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
    NSMutableDictionary *dict = [@{@"version":self.buildVersion,
                                   @"loginType":[User loginType],
                                   @"device":@"ios"}
                                 mutableCopy];
    
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
    
    NSString *base = [NSString stringWithFormat:@"http://shier-%@.image.myqcloud.com/%@",YOUTU_APP_ID,imageId];
    NSString *url = (size == FetchCenterImageSizeOriginal) ? base : [base stringByAppendingFormat:@"/%@",@(size)];
//    if (imageId.length > 30) { //优图id
//    
//    }else{ //老id
//        NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?",self.baseUrl,PIC,GET_IMAGE];
//        url = [NSString stringWithFormat:@"%@id=%@",[self addGeneralArgumentsForBaseURL:rqtStr],imageId];
//    }
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
            dispatch_main_async_safe(^{
                completionBlock();
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
            dispatch_main_async_safe(^{
                completionBlock(userInfo,isNewUser);
            });
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
                    dispatch_main_async_safe(^{
                        completionBlock(userInfo,isNewUser);                        
                    });
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

- (void)syncEntity:(NSString *)entityName
            idName:(NSString *)uniqueID
         localList:(NSArray *)localList
        serverList:(NSArray *)serverList{
    //创建一个新线程，因为每个线程必须有自己的MOC
    dispatch_queue_t queue = dispatch_queue_create([NSUUID UUID].UUIDString.UTF8String,NULL);
    dispatch_async(queue, ^{
        NSMutableArray *trashIDs = [NSMutableArray array];
        for (NSString *uid in localList) {
            if (![serverList containsObject:uid]) {
                [trashIDs addObject:uid];
            }
        }
        if (trashIDs.count > 0) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
            request.predicate = [NSPredicate predicateWithFormat:@"%K IN %@",uniqueID,trashIDs];//user %K to have dynamic property name

            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:uniqueID ascending:NO]];
            
            NSManagedObjectContext *workerContext = [self workerContext];
            
            NSError *error;
            NSArray *results = [workerContext executeFetchRequest:request error:&error];
            if (results.count > 0) {
                for (NSManagedObject *entity in results) {
                    [workerContext deleteObject:entity];
                }
            }
            
            [self.appDelegate saveContext:workerContext];
        }

    });

}

//在数组随机选取N个，此法仅用于测试
- (NSArray *)randomSelectionWithCount:(NSUInteger)count fromArray:(NSArray *)array{
    if ([array count] < count) {
        return nil;
    } else if ([array count] == count) {
        return array;
    }
    
    NSMutableSet* selection = [[NSMutableSet alloc] init];
    
    while ([selection count] < count) {
        id randomObject = [array objectAtIndex: arc4random() % [array count]];
        [selection addObject:randomObject];
    }
    
    return [selection allObjects];
}

@end

