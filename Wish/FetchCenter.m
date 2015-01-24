//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"
#define BASE_URL @"http://182.254.167.228/superplan/"

#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"
#define PIC @"pic/"
#define CREATE_PLAN @"splan_plan_create.php"
#define UPLOAD_IMAGE @"splan_pic_upload.php"

@implementation FetchCenter


+ (AFHTTPRequestOperationManager *)launchManager{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //important !!!
    return manager;
}

+ (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,GET_LIST];
    NSDictionary *args = @{@"id":ownerId};

    
    AFHTTPRequestOperationManager *manager = [[self class] launchManager];
    [manager GET:rqtStr
      parameters:args
         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
             NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



+ (void)uploadToCreatePlan:(Plan *)plan{
    
    NSString *rqtCreatePlan = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,CREATE_PLAN];
    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PIC,UPLOAD_IMAGE];


    //upload image
    AFHTTPRequestOperationManager *manager = [[self class] launchManager];
    
    AFHTTPRequestOperation *op = [manager POST:rqtUploadImage
                                    parameters:nil
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                         [formData appendPartWithFileData:UIImageJPEGRepresentation(plan.image, 0.2)
                                    name:@"name"
                                fileName:@"fileName"
                                mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, NSDictionary *imgResponse) {
//        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        
        //get image id
        NSString *fetchedImageId = imgResponse[@"data.id"];
        NSUInteger daysToFinish = [SystemUtil daysBetween:[NSDate date]
                                                      and:plan.finishDate];
        NSDictionary *createPlanArgs = @{@"ownerId":plan.ownerId,
                                         @"title":plan.planTitle,
                                         @"finishDate":@(daysToFinish),
#warning background num selection in fetch center
                                         @"backGroudNum":@1,
                                         @"private":plan.isPrivate,
#warning fetch tasks (Tasks obj)
                                         @"subPlanList":@[]};
        
        //create plan and get plan id
        [manager GET:rqtCreatePlan
          parameters:createPlanArgs
             success:^(AFHTTPRequestOperation *createPlan, NSDictionary *planResponse) {
                 
                 //get fetched plan id
                 NSString *fetchedPlanId = planResponse[@"data.id"];
                 
                 //update core data - cloud and local synchronization
                 plan.imageId = fetchedImageId;
                 plan.planId = fetchedPlanId;
                 [plan.managedObjectContext save:nil];
                 
                 NSLog(@"image id %@",fetchedImageId);
                 NSLog(@"plan id %@",fetchedPlanId);
                 
             }failure:^(AFHTTPRequestOperation *createPlan, NSError *error) {
                 NSLog(@"Fail to create plan: %@", error);
             }];
        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
    
    
    
    
}




@end
