//
//  Circle+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Circle+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Circle (CoreDataProperties)

+ (NSFetchRequest<Circle *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *circleType;
@property (nullable, nonatomic, copy) NSNumber *isFollowable;
@property (nullable, nonatomic, copy) NSNumber *newPlanCount;
@property (nullable, nonatomic, copy) NSNumber *nFans;
@property (nullable, nonatomic, copy) NSNumber *nFansToday;
@property (nullable, nonatomic, copy) NSString *ownerId;
@property (nullable, nonatomic, retain) NSSet<Plan *> *plans;

@end

@interface Circle (CoreDataGeneratedAccessors)

- (void)addPlansObject:(Plan *)value;
- (void)removePlansObject:(Plan *)value;
- (void)addPlans:(NSSet<Plan *> *)values;
- (void)removePlans:(NSSet<Plan *> *)values;

@end

NS_ASSUME_NONNULL_END
