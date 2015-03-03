//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"
#define BASE_URL @"http://182.254.167.228/superplan/"
#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"
#define CREATE_PLAN @"splan_plan_create.php"
#define DELETE_PLAN @"splan_plan_delete_id.php"
#define UPDATE_PLAN_STATUS @"splan_plan_set_state.php"

#define FEED @"feeds/"
#define PIC @"pic/"
#define UPLOAD_IMAGE @"splan_pic_upload.php"
#define GET_IMAGE @"splan_pic_get.php"
#define kFetchedImage @"fetchedImage" // for constructing NSDictionary with image data
#define CREATE_FEED @"splan_feeds_create.php"


#define FOLLOW @"follow/"
#define GET_FOLLOW_LIST @"splan_follow_get_feedslist.php"
typedef enum{
    FetchCenterGetOpCreatePlan = 0,
    FetchCenterGetOpDeletePlan,
    FetchCenterGetOpUploadImage,
    FetchCenterGetOpCreateFeed,
    FetchCenterGetOpGetPlanList,
    FetchCenterGetOpSetPlanStatus,
    FetchCenterGetOpFollowingPlanList
}FetchCenterGetOp;

typedef enum{
    FetchCenterPostOpUploadImageForCreatingFeed = 0
}FetchCenterPostOp;

@implementation FetchCenter


- (void)fetchFollowingPlanList{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,FOLLOW,GET_FOLLOW_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":[SystemUtil getOwnerId]}
           operation:FetchCenterGetOpFollowingPlanList
              entity:nil];
}

#pragma mark -
#pragma mark - personal

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
    NSDictionary *args = @{@"ownerId":[SystemUtil getOwnerId],
                           @"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"finishDate":@([SystemUtil daysBetween:[NSDate date] and:plan.finishDate]),
                           @"private":plan.isPrivate};
    [self getRequest:baseUrl parameter:args operation:FetchCenterGetOpCreatePlan entity:plan];
}

- (void)uploadToCreateFeed:(Feed *)feed{
    [self postImageWithOperation:feed postOp:FetchCenterPostOpUploadImageForCreatingFeed];
}


- (void)postToDeletePlan:(Plan *)plan
{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,CREATE_PLAN];
    NSDictionary *args = @{@"id":plan.planId,
                           @"ownerId":plan.ownerId};
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
                    args = @{@"ownerId":[SystemUtil getOwnerId],
                             @"picurl":fetchedImageId,
                             @"content":[feed.feedTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"planId":feed.plan.planId};
                    [self getRequest:baseURL parameter:args operation:FetchCenterGetOpCreateFeed entity:obj];
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
        case FetchCenterGetOpDeletePlan:
            if ([obj.managedObjectContext save:nil]) {  //commited delete
                NSLog(@"deleted successed");
            }
            break;
        case FetchCenterGetOpCreateFeed:{
            NSString *fetchedFeedID = [json valueForKeyPath:@"data.id"];
            if (fetchedFeedID){
                Feed *feed = (Feed *)obj;
                feed.feedId = fetchedFeedID;
                if ([feed.managedObjectContext save:nil]) {
                    [self.delegate didFinishUploadingFeed:feed];
                    NSLog(@"upload feed successed, ID: %@",fetchedFeedID);
                }
            }
        }
            break;
        case FetchCenterGetOpCreatePlan:{
            NSString *fetchedPlanId = [json valueForKeyPath:@"data.id"];
            if (fetchedPlanId) {
                Plan *plan = (Plan *)obj;
                plan.planId = fetchedPlanId;
                if ([plan.managedObjectContext save:nil]){
                    [self.delegate didFinishUploadingPlan:plan];
                    NSLog(@"create plan succeed, ID: %@",fetchedPlanId);
                }
            }
        }
            break;
        case FetchCenterGetOpSetPlanStatus:{
            NSLog(@"updated plan status (from server)");
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
        default:
            break;
    }
}

#pragma mark - main get and post method

- (void)getRequest:(NSString *)baseURL parameter:(NSDictionary *)dict operation:(FetchCenterGetOp)op entity:(NSManagedObject *)obj{
    
    //base url with version
    baseURL = [baseURL stringByAppendingString:@"?"];
    baseURL = [self versionForBaseURL:baseURL];
    
    
    //content arguments
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dict.allKeys.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        
    }];
    NSString *rqtStr = [baseURL stringByAppendingString:[array componentsJoinedByString:@"&"]];
    
    
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
                                      }
                                  }];
    [task resume];
    
    
}

- (void)postImageWithOperation:(NSManagedObject *)obj postOp:(FetchCenterPostOp)postOp{
    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@?",BASE_URL,PIC,UPLOAD_IMAGE];
    rqtUploadImage = [self versionForBaseURL:rqtUploadImage];
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
                                              }
                                          }];
    [uploadTask resume];
    
}

#pragma mark - version control 

//return a new base url string with appened version argument
- (NSString *)versionForBaseURL:(NSString *)baseURL{
    return [baseURL stringByAppendingString:@"version=2.2.0&"];
}

#pragma mark - get image url wraper

- (NSURL *)urlWithImageID:(NSString *)imageId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?",BASE_URL,PIC,GET_IMAGE];
    NSString *url = [NSString stringWithFormat:@"%@id=%@",[self versionForBaseURL:rqtStr],imageId];
    return [NSURL URLWithString:url];
}
@end
