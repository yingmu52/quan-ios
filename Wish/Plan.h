//
//  Plan.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed, Owner, Circle;

NS_ASSUME_NONNULL_BEGIN

@interface Plan : NSManagedObject

@property (nonatomic,strong,readonly) NSArray *planStatusTags; //array of strings
@property (nonatomic,readonly) BOOL hasDetailText;
typedef enum {
    PlanStatusOnGoing = 0,
    PlanStatusFinished,
}PlanStatus;

+ (Plan *)updatePlanFromServer:(NSDictionary *)dict
                     ownerInfo:(NSDictionary *)ownerInfo
          managedObjectContext:(NSManagedObjectContext *)context;

+ (Plan *)createPlan:(NSString *)planTitle
              planId:(NSString *)planId
        backgroundID:(NSString *)backGroundID
            inCircle:(NSString *)circleId inManagedObjectContext:(NSManagedObjectContext *)context;


- (void)addMyselfAsOwner;


- (Feed *)fetchLastUpdatedFeed;

- (void)updateTryTimesOfPlan:(BOOL)assending;

+ (NSArray *)fetchWith:(NSString *)entityName
             predicate:(NSPredicate  * _Nullable )predicate
      keyForDescriptor:(NSString *)key
  managedObjectContext:(NSManagedObjectContext *)context;

/**
 * 能被删除的事件要符合2个条件：
 * 1：不属于自己的事件（从而不影响事儿页）
 * 2：不受关注的事件（从而不影响关注页）
 */
- (BOOL)isDeletable;

@end

NS_ASSUME_NONNULL_END

#import "Plan+CoreDataProperties.h"
