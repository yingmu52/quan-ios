//
//  Circle.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-20.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "Circle.h"
#import "Plan.h"
#import "AppDelegate.h"
@implementation Circle

// Insert code here to add functionality to your managed object subclass
+ (Circle *)updateCircleWithInfo:(NSDictionary *)info{
    Circle *circle;
    
    NSArray *results = [Plan fetchWith:@"Circle"
                             predicate:[NSPredicate predicateWithFormat:@"circleId == %@",info[@"id"]]
                      keyForDescriptor:@"createDate"]; //utility method from Plan+PlanCRUD.h
    
    if (!results.count) {
        circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle"
                                                inManagedObjectContext:[AppDelegate getContext]];

        circle.circleId = info[@"id"];
        circle.createDate = [NSDate dateWithTimeIntervalSince1970:[info[@"createTime"] integerValue]];
        
    }else{
        NSAssert(results.count <= 1, @"Circle id must be a unique!");
        circle = results.lastObject;
    }
    
    if (![circle.circleName isEqualToString:info[@"name"]]) {
        circle.circleName = info[@"name"];
    }
    
    NSString *invitationCode = [NSString stringWithFormat:@"%@",info[@"addCode"]];
    if (![circle.invitationCode isEqualToString:invitationCode]) {
        circle.invitationCode = invitationCode;
    }


    return circle;

}

@end
