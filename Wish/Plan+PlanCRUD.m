//
//  Plan+PlanCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan+PlanCRUD.h"
@import UIKit;
@implementation Plan (PlanCRUD)

+ (Plan *)createPlan:(NSString *)title
                date:(NSDate *)date
             privacy:(BOOL)isPrivate
               image:(UIImage *)image
           inContext:(NSManagedObjectContext *)context{
    Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                               inManagedObjectContext:context];
    plan.planTitle = title;
    plan.finishDate = date;
    plan.isPrivate = @(isPrivate);
    plan.image = image;

    return plan;
}
@end


