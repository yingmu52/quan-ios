//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"
@import Foundation;
#define BASE_URL @"http://182.254.167.228/superplan/"
#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"
#define PIC @"pic/"
#define CREATE_PLAN @"splan_plan_create.php"
#define UPLOAD_IMAGE @"splan_pic_upload.php"

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



+ (void)uploadToCreatePlan:(Plan *)plan{
    
    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PIC,UPLOAD_IMAGE];

    //upload image
    NSData *imgData = UIImageJPEGRepresentation(plan.image, 0.5);

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLRequest *request = [self.class request:rqtUploadImage method:@"POST"];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:imgData completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
    {
        if (!error){ //upload image successed
            
            NSDictionary *imgJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //get image id
            plan.imageId = imgJson[@"data.id"];
            
            NSString *rqtCreatePlan = [NSString stringWithFormat:@"%@%@%@?ownerId=%@title=%@finishDate=%dbackGroudNum=%dprivate=%@",BASE_URL,PLAN,CREATE_PLAN,plan.ownerId,plan.planTitle,[SystemUtil daysBetween:[NSDate date] and:plan.finishDate],1,plan.isPrivate];
            rqtCreatePlan = [rqtCreatePlan stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURLRequest *request = [self.class request:rqtCreatePlan method:@"GET"];
            NSURLSessionDataTask *creatTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (!error) { //create plan success
                    NSDictionary *planJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    //get fetched plan id
                    
                    //update core data - cloud and local synchronization
                    plan.planId = planJson[@"data.id"];
                    if([plan.managedObjectContext save:nil]){
                        NSLog(@"upload plan successed");
                    }

                }
            }];
            [creatTask resume];
            
        }
                                                    
    }];
    [uploadTask resume];
    
}
@end
