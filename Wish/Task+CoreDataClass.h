//
//  Task+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBase+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Task : MSBase
- (NSArray *)localIDs;

+ (Task *)insertTaskWithFeedTitle:(NSString *)feedTitle
                             planID:(NSString *)planId
                       locaImageIDs:(NSArray *)localImageIdentifiers
            inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Task+CoreDataProperties.h"
