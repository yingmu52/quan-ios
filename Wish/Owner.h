//
//  Owner.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plan;

@interface Owner : NSManagedObject

@property (nonatomic, retain) NSString * headUrl;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSSet *plans;
@end

@interface Owner (CoreDataGeneratedAccessors)

- (void)addPlansObject:(Plan *)value;
- (void)removePlansObject:(Plan *)value;
- (void)addPlans:(NSSet *)values;
- (void)removePlans:(NSSet *)values;

@end
