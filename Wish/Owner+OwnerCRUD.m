//
//  Owner+OwnerCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Owner+OwnerCRUD.h"
#import "AppDelegate.h"
#import "Plan+PlanCRUD.h"
@implementation Owner (OwnerCRUD)

+ (Owner *)updateOwnerWithInfo:(NSDictionary *)dict{
    NSManagedObjectContext *context = [AppDelegate getContext];
    Owner *owner;
    //check existance
    NSArray *checks = [Plan fetchWith:@"Owner"
                            predicate:[NSPredicate predicateWithFormat:@"ownerId == %@",dict[@"id"]]
                     keyForDescriptor:@"ownerId"];
    NSAssert(checks.count <= 1, @"ownerId must be a unique!");
    if (!checks.count) {
        //insert new fetched Owner
        owner = [NSEntityDescription insertNewObjectForEntityForName:@"Owner"
                                             inManagedObjectContext:context];
        owner.headUrl = dict[@"headUrl"];
        owner.ownerId = dict[@"id"];
        owner.ownerName = dict[@"name"];
        
    }else{
        //update existing plan
        owner = checks.lastObject;
    }
    return owner;
}
@end
