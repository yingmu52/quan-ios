//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"
#import "AppDelegate.h"
#import "User.h"
#define BASE_URL @"http://182.254.167.228/superplan/"
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


#define FOLLOW @"follow/"
#define GET_FOLLOW_LIST @"splan_follow_get_feedslist.php"


#define USER @"man/"
#define GETUID @"splan_get_uid.php"


#define OTHER @"other/"
#define CHECK_NEW_VERSION @"splan_other_new_version.php"

typedef enum{
    FetchCenterGetOpCreatePlan = 0,
    FetchCenterGetOpDeletePlan,
    FetchCenterGetOpUploadImage,
    FetchCenterGetOpCreateFeed,
    FetchCenterGetOpGetPlanList,
    FetchCenterGetOpSetPlanStatus,
    FetchCenterGetOpUpdatePlan,
    FetchCenterGetOpFollowingPlanList,
    FetchCenterGetOpLoginForUidAndUkey,
    FetchCenterGetOpCheckNewVersion
}FetchCenterGetOp;

typedef enum{
    FetchCenterPostOpUploadImageForCreatingFeed = 0
}FetchCenterPostOp;

@implementation FetchCenter


- (void)checkVersion{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,OTHER,CHECK_NEW_VERSION];
    [self getRequest:rqtStr
           parameter:nil
           operation:FetchCenterGetOpCheckNewVersion
              entity:nil];
}
- (void)fetchFollowingPlanList{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,FOLLOW,GET_FOLLOW_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":[User uid]}
           operation:FetchCenterGetOpFollowingPlanList
              entity:nil];
}

#pragma mark - Login&out

- (void)fetchUidandUkeyWithOpenId:(NSString *)openId accessToken:(NSString *)token{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,USER,GETUID];
    [self getRequest:rqtStr
           parameter:@{@"openid":openId,
                       @"token":token}
           operation:FetchCenterGetOpLoginForUidAndUkey
              entity:nil];
}

#pragma mark - personal

- (void)updatePlan:(Plan *)plan{
    //输入样例：id=hello_1421235901&title=hello_title2&finishDate=3&backGroudPic=bg3&private=1&state=1&finishPercent=20
    //—— 每一项都可以单独更新
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,UPDATE_PLAN];
    [self getRequest:rqtStr parameter:@{@"id":plan.planId,
                                        @"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        @"finishDate":@([SystemUtil daysBetween:plan.createDate and:plan.finishDate]),
                                        @"private":plan.isPrivate}
           operation:FetchCenterGetOpUpdatePlan
              entity:plan];
   
}
- (void)updateStatus:(Plan *)plan{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,UPDATE_PLAN_STATUS];
    [self getRequest:rqtStr parameter:@{@"id":plan.planId,
                                        @"state":plan.planStatus}
           operation:FetchCenterGetOpSetPlanStatus entity:plan];

}
- (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,GET_LIST];
    [self getRequest:rqtStr parameter:@{@"id":ownerId} operation:FetchCenterGetOpGetPlanList entity:nil];

}

-(void)uploadToCreatePlan:(Plan *)plan{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,CREATE_PLAN];
    NSDictionary *args = @{@"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"finishDate":@([SystemUtil daysBetween:[NSDate date] and:plan.finishDate]),
                           @"private":plan.isPrivate};
    [self getRequest:baseUrl parameter:args operation:FetchCenterGetOpCreatePlan entity:plan];
}

- (void)uploadToCreateFeed:(Feed *)feed{
    [self postImageWithOperation:feed postOp:FetchCenterPostOpUploadImageForCreatingFeed];
}


- (void)postToDeletePlan:(Plan *)plan
{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,DELETE_PLAN];
    NSDictionary *args = @{@"id":plan.planId};
    [self getRequest:baseUrl parameter:args operation:FetchCenterGetOpDeletePlan entity:plan];
}



- (void)didFinishSendingPostRequest:(NSDictionary *)json operation:(FetchCenterPostOp)op entity:(NSManagedObject *)obj{
    switch (op){
        case FetchCenterPostOpUploadImageForCreatingFeed:{
            NSString *fetchedImageId = [json valueForKeyPath:@"data.id"];
            if (fetchedImageId){
                Feed *feed = (Feed *)obj;
                feed.imageId = fetchedImageId;
                NSLog(@"fetched image ID: %@",fetchedImageId);
                //upload feed
                NSString *baseURL = [NSString stringWithFormat:@"%@%@%@",BASE_URL,FEED,CREATE_FEED];
                NSDictionary *args;
                if (feed.plan.planId && feed.feedTitle) {
                    args = @{@"picurl":fetchedImageId,
                             @"content":[feed.feedTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"planId":feed.plan.planId};
                    [self getRequest:baseURL
                           parameter:args
                           operation:FetchCenterGetOpCreateFeed entity:obj];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)didFinishSendingGetRequest:(NSDictionary *)json operation:(FetchCenterGetOp)op entity:(NSManagedObject *)obj{
    switch (op)
    {
        case FetchCenterGetOpGetPlanList:
            //get plan list
            break;
        case FetchCenterGetOpDeletePlan:{
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            [delegate saveContext];
            NSLog(@"deleted successed %@",json);
        }
            break;
        case FetchCenterGetOpCreateFeed:{
            NSString *fetchedFeedID = [json valueForKeyPath:@"data.id"];
            if (fetchedFeedID){
                Feed *feed = (Feed *)obj;
                feed.feedId = fetchedFeedID;
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
                Plan *plan = [Plan updatePlanFromServer:planItem];
                NSDictionary *userInfo = [json valueForKeyPath:[NSString stringWithFormat:@"data.manList.%@",plan.ownerId]];
                plan.owner = [Owner updateOwnerFromServer:userInfo];
                NSArray *feedsList = planItem[@"feedsList"];
                if (feedsList.count) {
                    //create all feeds
                    for (NSDictionary *feedItem in feedsList) {
                        [Feed createFeedFromServer:feedItem forPlan:plan];
                        //use alternative way to load and cache image
                    }
                }
            }
            [self.delegate didFinishFetchingFollowingPlanList];
        }
            break;
        case FetchCenterGetOpLoginForUidAndUkey:{
            NSString *uid = [json valueForKeyPath:@"data.uid"];
            NSString *ukey = [json valueForKeyPath:@"data.ukey"];
            [self.delegate didFinishReceivingUid:uid uKey:ukey];
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
        default:
            break;
    }
    NSLog(@"%@",json);
}

#pragma mark - main get and post method

- (NSString *)argumentStringWithDictionary:(NSDictionary *)dict{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dict.allKeys.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }];
    return [array componentsJoinedByString:@"&"];
}

- (void)getRequest:(NSString *)baseURL parameter:(NSDictionary *)dict operation:(FetchCenterGetOp)op entity:(NSManagedObject *)obj{
    
    //base url with version
    baseURL = [baseURL stringByAppendingString:@"?"];
    baseURL = [self versionForBaseURL:baseURL operation:op];
    
    
    //content arguments
    NSString *rqtStr = [baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                      if ([responseJson[@"ret"] integerValue] == -305) {
                                          NSLog(@"-305: invalid system version");
                                          return;
                                      }
                                      if (!error && ![responseJson[@"ret"] boolValue]){ //successed "ret" = 0;
                                          [self didFinishSendingGetRequest:responseJson operation:op entity:obj];
                                      }else{
                                          NSLog(@"Fail Get Request :%@\n op: %d \n baseUrl: %@ \n parameter: %@ \n response: %@ \n error:%@",request,op,baseURL,dict,responseJson,error);
                                          [self.delegate didFailSendingRequestWithInfo:responseJson entity:obj];
                                      }
                                  }];
    [task resume];
    
    
}

- (void)postImageWithOperation:(NSManagedObject *)obj postOp:(FetchCenterPostOp)postOp{
    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@?",BASE_URL,PIC,UPLOAD_IMAGE];
    rqtUploadImage = [self versionForBaseURL:rqtUploadImage operation:-1];
    //upload image
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtUploadImage]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = @"POST";
    
    UIImage *image = [obj valueForKey:@"image"];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:UIImageJPEGRepresentation(image, 0.1)
                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                          {
                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingAllowFragments
                                                                                                     error:nil];
                                              
                                              if (!error && ![json[@"ret"] boolValue]){ //upload image successed
                                                  [self didFinishSendingPostRequest:json
                                                                          operation:FetchCenterPostOpUploadImageForCreatingFeed
                                                                             entity:obj];
                                              }else{
                                                  NSLog(@"fail to upload image \n response:%@",json);
                                                  [self.delegate didFailUploadingImageWithInfo:json entity:obj];
                                              }
                                          }];
    [uploadTask resume];
    
}

#pragma mark - version control 

//return a new base url string with appened version argument
- (NSString *)versionForBaseURL:(NSString *)baseURL operation:(FetchCenterGetOp)op{
    NSMutableDictionary *dict = [@{@"version":@"2.2.2",
                                   @"loginType":@"qq",
                                   @"sysVersion":[UIDevice currentDevice].systemVersion,
                                   @"sysModel":[UIDevice currentDevice].model} mutableCopy];
    if (op != FetchCenterGetOpLoginForUidAndUkey) {
        [dict addEntriesFromDictionary:@{@"uid":[User uid],@"ukey":[User uKey]}];
        dict[@"loginType"] = @"uid";
    }
    return [[baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]] stringByAppendingString:@"&"];
}

#pragma mark - get image url wraper

- (NSURL *)urlWithImageID:(NSString *)imageId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?",BASE_URL,PIC,GET_IMAGE];
    NSString *url = [NSString stringWithFormat:@"%@id=%@",[self versionForBaseURL:rqtStr operation:-1],imageId];
    return [NSURL URLWithString:url];
}
@end
