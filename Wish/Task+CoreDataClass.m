//
//  Task+CoreDataClass.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Task+CoreDataClass.h"

@implementation Task


- (NSArray *)localIDs{
    return [self.imageLocalIdentifiers componentsSeparatedByString:@","];
}

+ (Task *)insertTaskWithFeedTitle:(NSString *)feedTitle
                             planID:(NSString *)planId
                       locaImageIDs:(NSArray *)localImageIdentifiers
             inManagedObjectContext:(NSManagedObjectContext *)context{
    
    Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
    
    task.mUID = [NSUUID UUID].UUIDString;
    task.mCreateTime = [NSDate date];
    task.mTitle = feedTitle;
    task.planID = planId;
    task.imageLocalIdentifiers = [localImageIdentifiers componentsJoinedByString:@","];
    
    
    return task;
    
}

@end

