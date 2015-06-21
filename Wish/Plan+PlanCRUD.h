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

typedef enum {
    PlanStatusOnGoing = 0,
    PlanStatusFinished,
    PlanStatusGiveTheFuckingUp
}PlanStatus;

- (void)updatePlanStatus:(PlanStatus)planStatus;

+ (Plan *)updatePlanFromServer:(NSDictionary *)dict ownerInfo:(NSDictionary *)ownerInfo;

+ (Plan *)createPlan:(NSString *)title privacy:(BOOL)isPrivate image:(UIImage *)image;

- (void)deleteSelf;

- (void)addMyselfAsOwner;


- (Feed *)fetchLastUpdatedFeed;

- (void)updateTryTimesOfPlan:(BOOL)assending;

+ (NSArray *)fetchWith:(NSString *)entityName
             predicate:(NSPredicate *)predicate
      keyForDescriptor:(NSString *)key;
@end
