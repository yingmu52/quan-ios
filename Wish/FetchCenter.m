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

#define FEED @"feeds/"
#define PIC @"pic/"
#define UPLOAD_IMAGE @"splan_pic_upload.php"
#define CREATE_FEED @"splan_feeds_create.php"

typedef enum{
    FetchCenterOpCreatePlan = 0,
    FetchCenterOpDeletePlan,
    FetchCenterOpUploadImage,
    FetchCenterOpCreateFeed,
    FetchCenterOpGetPlanList,
}FetchCenterGetOp;

typedef enum{
    FetchCenterPostOpUploadImageForCreatingFeed = 0
}FetchCenterPostOp;

@implementation FetchCenter


- (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?id=%@",BASE_URL,PLAN,GET_LIST,ownerId];
    [self getRequest:rqtStr parameter:@{@"id":ownerId} operation:FetchCenterOpGetPlanList entity:nil];

}

-(void)uploadToCreatePlan:(Plan *)plan{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,CREATE_PLAN];
    NSDictionary *args = @{@"ownerId":[SystemUtil getOwnerId],
                           @"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"finishDate":@([SystemUtil daysBetween:[NSDate date] and:plan.finishDate]),
                           @"private":plan.isPrivate};
    [self getRequest:baseUrl parameter:args operation:FetchCenterOpCreatePlan entity:plan];
}

- (void)uploadToCreateFeed:(Feed *)feed{
//    NSLog(@"%@",feed);
//    NSLog(@"%@",feed.plan);
    [self postImageWithOperation:feed postOp:FetchCenterPostOpUploadImageForCreatingFeed];
}


- (void)postToDeletePlan:(Plan *)plan
{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,CREATE_PLAN];
    NSDictionary *args = @{@"id":plan.planId,
                           @"ownerId":plan.ownerId};
    [self getRequest:baseUrl parameter:args operation:FetchCenterOpDeletePlan entity:plan];
}

- (void)getRequest:(NSString *)baseURL parameter:(NSDictionary *)dict operation:(FetchCenterGetOp)op entity:(NSManagedObject *)obj{
    baseURL = [baseURL stringByAppendingString:@"?"];
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
        NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:nil];
        
        if (!error && ![responseJson[@"ret"] boolValue]){ //successed "ret" = 0;
//            NSLog(@"GET successed \n request:%@ \n response:%@ \n",rqtStr,responseJson);
            [self didFinishSendingGetRequest:responseJson operation:op entity:obj];
        }else{
            NSLog(@"Fail Get Request \n op: %d \n baseUrl: %@ \n parameter: %@ \n response: %@",op,baseURL,dict,responseJson);
        }
    }];
    [task resume];


}

- (void)postImageWithOperation:(NSManagedObject *)obj postOp:(FetchCenterPostOp)postOp{
    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PIC,UPLOAD_IMAGE];
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
              [self didFinishSendingPostRequest:json operation:FetchCenterPostOpUploadImageForCreatingFeed entity:obj];
          }else{
              NSLog(@"fail to upload image");
          }
      }];
    [uploadTask resume];

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
                    [self getRequest:baseURL parameter:args operation:FetchCenterOpCreateFeed entity:obj];
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
        case FetchCenterOpGetPlanList:
            //get plan list
            break;
        case FetchCenterOpDeletePlan:
            if ([obj.managedObjectContext save:nil]) {  //commited delete
                NSLog(@"deleted successed");
            }
            break;
        case FetchCenterOpCreateFeed:{
            NSString *fetchedFeedID = [json valueForKeyPath:@"data.id"];
            if (fetchedFeedID){
                Feed *feed = (Feed *)obj;
                feed.feedId = fetchedFeedID;
                NSLog(@"upload feed successed, ID: %@",fetchedFeedID);
                [feed.managedObjectContext save:nil];
            }
        }
            break;
        case FetchCenterOpCreatePlan:{
            NSString *fetchedPlanId = [json valueForKeyPath:@"data.id"];
            if (fetchedPlanId) {
                Plan *plan = (Plan *)obj;
                plan.planId = fetchedPlanId;
                [plan.managedObjectContext save:nil];
                NSLog(@"create plan succeed, ID: %@",fetchedPlanId);
            }
        }
            break;
        default:
            break;
            
    }
}
@end
