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
#define PIC @"pic/"
#define CREATE_PLAN @"splan_plan_create.php"
#define UPLOAD_IMAGE @"splan_pic_upload.php"
#define DELETE_PLAN @"splan_plan_delete_id.php"
@implementation FetchCenter


+ (NSURLRequest *)request:(NSString *)rqtStr method:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = method;

    return [request copy];
}

+ (NSURLSession *)session{

//    static NSURLSession *session = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken,^{
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        [configuration setHTTPMaximumConnectionsPerHost:1];
//        session = [NSURLSession sessionWithConfiguration:configuration];
//    });
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
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
            plan.backgroundNum = @([[backGroundPic substringFromIndex:2] integerValue]);
            
            NSLog(@"fetched plan ID %@",fetchedPlanID);
            NSLog(@"background num %@",backGroundPic);
            NSLog(@"upload plan successed");
            
        }
    }];
    [creatTask resume];
}

//+ (void)uploadToCreatePlan1:(Plan *)plan{
//    
//    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PIC,UPLOAD_IMAGE];
//    //upload image
//    NSData *imgData = UIImageJPEGRepresentation(plan.image, 0.5);
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSURLRequest *request = [self.class request:rqtUploadImage method:@"POST"];
//    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:imgData completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
//    {
//        if (!error){ //upload image successed
//            
//            NSDictionary *imgJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//            //get image id
//            NSString *fetchedImageId = [imgJson valueForKeyPath:@"data.id"];
//            if (fetchedImageId){
////                plan.imageId = fetchedImageId;
//                NSLog(@"fetched image ID: %@",fetchedImageId);
//
//                
//               
//            }
//        }
//    }];
//    [uploadTask resume];
//    
//}


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
