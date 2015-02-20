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

+ (Plan *)updatePlanFromServer:(NSDictionary *)dict;

+ (Plan *)createPlan:(NSString *)title
                date:(NSDate *)date
             privacy:(BOOL)isPrivate
               image:(UIImage *)image;
+ (NSArray *)loadMyPlans;
- (void)deleteSelf;
- (NSNumber *)extractNumberFromString:(NSString *)string;
@end
