//
//  Owner.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "Owner.h"
#import "Comment.h"
#import "Message.h"
#import "Plan.h"
#import "AppDelegate.h"

@implementation Owner

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
        owner.ownerId = dict[@"id"];
        
    }else{
        //update existing plan
        owner = checks.lastObject;
    }
    
    if (![owner.headUrl isEqualToString:dict[@"headUrl"]]){
        owner.headUrl = dict[@"headUrl"];
    }
    
    if (![owner.ownerName isEqualToString:dict[@"name"]]){
        owner.ownerName = dict[@"name"];
    }
    
    
    return owner;
}

+ (NSDictionary *)myWebInfo{
    return @{@"headUrl":[User updatedProfilePictureId],
             @"id":[User uid],
             @"name":[User userDisplayName]};
}
@end


