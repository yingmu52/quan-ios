//
//  MSBase.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/1/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSBase : NSManagedObject
+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
         inManagedObjectContext:(NSManagedObjectContext *)context;
@end

NS_ASSUME_NONNULL_END
