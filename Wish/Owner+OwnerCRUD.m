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


#warning this func needs a better name
+ (Owner *)updateOwnerFromServer:(NSDictionary *)dict{
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
    }else{
        //update existing plan
        owner = checks.lastObject;
    }
    owner.headUrl = dict[@"headUrl"];
    owner.ownerId = dict[@"id"];
    owner.ownerName = dict[@"name"];
//    if ([context save:nil]) {
//        NSLog(@"updated owner info");
//    }
    return owner;
}
@end
