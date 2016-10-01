//
//  Circle+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 8/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Circle.h"

NS_ASSUME_NONNULL_BEGIN

@interface Circle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *circleDescription;
@property (nullable, nonatomic, retain) NSString *circleId;
@property (nullable, nonatomic, retain) NSString *circleName;
@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSString *imageId;
@property (nullable, nonatomic, retain) NSString *ownerId;
@property (nullable, nonatomic, retain) NSNumber *nFans;
@property (nullable, nonatomic, retain) NSNumber *nFansToday;
@property (nullable, nonatomic, retain) NSNumber *circleType;
@property (nullable, nonatomic, retain) NSNumber *isFollowable;
@property (nullable, nonatomic, retain) NSSet<Plan *> *plans;

@end

@interface Circle (CoreDataGeneratedAccessors)

- (void)addPlansObject:(Plan *)value;
- (void)removePlansObject:(Plan *)value;
- (void)addPlans:(NSSet<Plan *> *)values;
- (void)removePlans:(NSSet<Plan *> *)values;

@end

NS_ASSUME_NONNULL_END
