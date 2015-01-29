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

+ (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?id=%@",BASE_URL,PLAN,GET_LIST,ownerId];

    NSURLSession *sesstion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *request = [self.class request:rqtStr method:@"GET"];
    NSURLSessionDataTask *task = [sesstion dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
    }];
    [task resume];

}



//+ (void)uploadToCreatePlan:(Plan *)plan{
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
//                plan.imageId = fetchedImageId;
//                NSLog(@"fetched image ID: %@",fetchedImageId);
//                NSString *rqtCreatePlan = [NSString stringWithFormat:@"%@%@%@?ownerId=%@&title=%@&finishDate=%lu&backGroudNum=%d&private=%@",BASE_URL,PLAN,CREATE_PLAN,[SystemUtil getOwnerId],plan.planTitle,(unsigned long)[SystemUtil daysBetween:[NSDate date] and:plan.finishDate],1,plan.isPrivate];
//                rqtCreatePlan = [rqtCreatePlan stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                
//                NSURLRequest *request = [self.class request:rqtCreatePlan method:@"GET"];
//                NSURLSessionDataTask *creatTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                    
//                    if (!error) { //create plan success
//                        NSDictionary *planJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                        //get fetched plan id
//                        
//                        //update core data - cloud and local synchronization
//                        NSString *fetchedPlanID = [planJson valueForKeyPath:@"data.id"];
//                        plan.planId = fetchedPlanID;
//                        
//                        if([plan.managedObjectContext save:nil] && fetchedPlanID){
//                            NSLog(@"fetched plan ID %@",fetchedPlanID);
//                            NSLog(@"upload plan successed");
//                        }
//                        
//                    }
//                }];
//                [creatTask resume];
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
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *deleteTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                        {
                                            if (!error){ //delete successed
                                                [plan.managedObjectContext deleteObject:plan];
                                                NSLog(@"delete plan successed (both)");
                                            }else{
                                                plan.userDeleted = @(YES);
                                                NSLog(@"delete plan successed (only local)");
                                            }
                                            [plan.managedObjectContext save:nil];
                                        }];
    [deleteTask resume];

}
@end
