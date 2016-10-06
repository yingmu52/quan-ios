//
//  Owner+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBase+CoreDataClass.h"

@class Comment, Message, Plan;

NS_ASSUME_NONNULL_BEGIN

@interface Owner : MSBase

+ (Owner *)updateOwnerWithInfo:(NSDictionary *)dict
          managedObjectContext:(NSManagedObjectContext *)context;
+ (NSDictionary *)myWebInfo;

@end

NS_ASSUME_NONNULL_END

#import "Owner+CoreDataProperties.h"
