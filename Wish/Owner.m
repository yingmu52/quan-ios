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

+ (Owner *)updateOwnerWithInfo:(NSDictionary *)dict
          managedObjectContext:(nonnull NSManagedObjectContext *)context{

    Owner *owner;
    //check existance
    NSArray *checks = [Plan fetchWith:@"Owner"
                            predicate:[NSPredicate predicateWithFormat:@"mUID == %@",dict[@"id"]]
                     keyForDescriptor:@"mUID"
                 managedObjectContext:context];
    
    if (!checks.count) {
        //insert new fetched Owner
        owner = [NSEntityDescription insertNewObjectForEntityForName:@"Owner"
                                              inManagedObjectContext:context];
        owner.mUID = dict[@"id"];
        
    }else{
        //update existing plan
        owner = checks.lastObject;
    }
    
    NSString *headUrl = dict[@"headUrl"];
    if (headUrl && ![owner.mCoverImageId isEqualToString:headUrl]){
        owner.mCoverImageId = headUrl;
    }
    
    NSString *ownerName = dict[@"name"];
    if (ownerName && ![owner.mTitle isEqualToString:ownerName]){
        owner.mTitle = ownerName;
    }
    
    owner.mLastReadTime = [NSDate date];
    
    return owner;
}

+ (NSDictionary *)myWebInfo{
    return @{@"headUrl":[User updatedProfilePictureId],
             @"id":[User uid],
             @"name":[User userDisplayName]};
}
@end


