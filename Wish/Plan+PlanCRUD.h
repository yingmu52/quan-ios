//
//  Plan+PlanCRUD.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan.h"
@import UIKit;

@interface Plan (PlanCRUD)
@property (nonatomic,strong,readonly) NSArray *planStatusTags; //array of strings
@property (nonatomic,readonly) BOOL hasDetailText;
typedef enum {
    PlanStatusOnGoing = 0,
    PlanStatusFinished,
    PlanStatusGiveTheFuckingUp
}PlanStatus;

- (void)updatePlanStatus:(PlanStatus)planStatus;

+ (Plan *)updatePlanFromServer:(NSDictionary *)dict ownerInfo:(NSDictionary *)ownerInfo;

+ (Plan *)createPlan:(NSString *)title privacy:(BOOL)isPrivate;

- (void)deleteSelf;

- (void)addMyselfAsOwner;


- (Feed *)fetchLastUpdatedFeed;

- (void)updateTryTimesOfPlan:(BOOL)assending;

+ (NSArray *)fetchWith:(NSString *)entityName
             predicate:(NSPredicate *)predicate
      keyForDescriptor:(NSString *)key;

/**
 * 能被删除的事件要符合2个条件：
 * 1：不属于自己的事件（从而不影响事儿页）
 * 2：不受关注的事件（从而不影响关注页）
*/
- (BOOL)isDeletable;
@end
