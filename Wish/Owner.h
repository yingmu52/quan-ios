//
//  Owner.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Message, Plan;

NS_ASSUME_NONNULL_BEGIN

@interface Owner : NSManagedObject

+ (Owner *)updateOwnerWithInfo:(NSDictionary *)dict;
+ (NSDictionary *)myWebInfo;
@end

NS_ASSUME_NONNULL_END

#import "Owner+CoreDataProperties.h"
