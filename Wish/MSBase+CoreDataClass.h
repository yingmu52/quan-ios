//
//  MSBase+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSBase : NSManagedObject

+ (NSArray *)fetchWithPredicate:(nullable NSPredicate *)predicate
         inManagedObjectContext:(NSManagedObjectContext *)context;

+ (id)fetchID:(NSString *)entityID inManagedObjectContext:(NSManagedObjectContext *)context;


@end

NS_ASSUME_NONNULL_END

#import "MSBase+CoreDataProperties.h"
