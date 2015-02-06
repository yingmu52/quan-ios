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
@implementation FetchCenter


+ (NSURLRequest *)request:(NSString *)rqtStr method:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = method;

    return [request copy];
}

+ (NSURLSession *)session{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    return session;
}
+ (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?id=%@",BASE_URL,PLAN,GET_LIST,ownerId];
    
    NSURLRequest *request = [self.class request:rqtStr method:@"GET"];
    NSURLSessionDataTask *task = [[self.class session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
    }];
    [task resume];

}

+(void)uploadToCreatePlan:(Plan *)plan{
    NSString *rqtCreatePlan = [NSString stringWithFormat:@"%@%@%@?ownerId=%@&title=%@&finishDate=%@&private=%@",BASE_URL,PLAN,CREATE_PLAN,[SystemUtil getOwnerId],plan.planTitle,@([SystemUtil daysBetween:[NSDate date] and:plan.finishDate]),plan.isPrivate];
    rqtCreatePlan = [rqtCreatePlan stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLRequest *request = [self.class request:rqtCreatePlan method:@"GET"];
    NSURLSessionDataTask *creatTask = [[self.class session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *planJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

        if (!error && ![planJson[@"ret"] boolValue]) { //create plan success
            //get fetched plan id
            //update core data - cloud and local synchronization
            NSString *fetchedPlanID = [planJson valueForKeyPath:@"data.id"];
            plan.planId = fetchedPlanID;
            
            NSString *backGroundPic = [planJson valueForKeyPath:@"data.backGroudPic"];
            // i.e. bg3, means from 3
            plan.backgroundNum = [plan extractNumberFromString:backGroundPic];
            NSLog(@"upload plan successed, ID: %@, #BG: %@",fetchedPlanID,backGroundPic);
        }else{
            NSLog(@"Fail to create plan %@",planJson);
            
        }
    }];
    [creatTask resume];
}

+ (void)uploadToCreateFeed:(Feed *)feed{
//    NSLog(@"%@",feed);
//    NSLog(@"%@",feed.plan);
    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PIC,UPLOAD_IMAGE];
    //upload image
    NSData *imgData = UIImageJPEGRepresentation(feed.image, 0.1);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [self.class request:rqtUploadImage method:@"POST"];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:imgData
                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
      {
          NSDictionary *imgJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

          if (!error && ![imgJson[@"ret"] boolValue]){ //upload image successed
              //get image id
              NSString *fetchedImageId = [imgJson valueForKeyPath:@"data.id"];
              if (fetchedImageId){
                  feed.imageId = fetchedImageId;
                  NSLog(@"fetched image ID: %@",fetchedImageId);
                  
                  //****************create feed****************
                  NSString *rqtCreateFeed = [NSString stringWithFormat:@"%@%@%@?ownerId=%@&picurl=%@&content=%@&planId=%@",BASE_URL,FEED,CREATE_FEED,[SystemUtil getOwnerId],feed.imageId,feed.feedTitle,feed.plan.planId];
                  rqtCreateFeed = [rqtCreateFeed stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                  
                  NSURLRequest *request = [self.class request:rqtCreateFeed method:@"GET"];
                  NSURLSessionDataTask *creatTask = [[self.class session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                      
                      NSDictionary *feedJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                      
                      if (!error && ![feedJson[@"ret"] boolValue]) { //create feed success
                          //get fetched feed id
                          //update core data - cloud and local synchronization
                          NSString *fetchedFeedID = [feedJson valueForKeyPath:@"data.id"];
                          feed.feedId = fetchedFeedID;
                          NSLog(@"upload feed successed, ID: %@",fetchedFeedID);
                      }else{
                          NSLog(@"Fail to create feed %@",feedJson);
                          
                      }
                  }];
                  [creatTask resume];

                  
              }
          }
      }];
    [uploadTask resume];

}


+ (void)postToDeletePlan:(Plan *)plan
{
    NSString *rqtDeletePlan = [NSString stringWithFormat:@"%@%@%@?id=%@&ownerId=%@",BASE_URL,PLAN,DELETE_PLAN,plan.planId,plan.ownerId];
    NSURLRequest *request = [self.class request:rqtDeletePlan method:@"GET"];
    
    NSURLSessionDataTask *deleteTask = [[self.class session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:nil];

        if (!error && ![responseJson[@"ret"] boolValue]){ //delete successed "ret" = 0;
            NSLog(@"delete plan successed");
            [plan.managedObjectContext save:nil]; //commited delete
        }
    }];
    [deleteTask resume];

}
@end
