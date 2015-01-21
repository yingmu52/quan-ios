//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"
#import "AFHTTPRequestOperationManager.h"


#define BASE_URL @"http://182.254.167.228/superplan/"

#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"

@implementation FetchCenter

+ (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",BASE_URL,PLAN,GET_LIST];
    NSDictionary *args = @{@"id":ownerId};
    [[AFHTTPRequestOperationManager manager] GET:rqtStr parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"json:%@",responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"FAIL");
    }];
}

@end
