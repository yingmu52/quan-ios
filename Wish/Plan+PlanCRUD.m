//
//  Plan+PlanCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan+PlanCRUD.h"
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

+ (NSArray *)loadMyPlans:(NSManagedObjectContext *)context
{
    return [[self class] fetchWith:@"Plan"
                         predicate:nil //fetch all
                  keyForDescriptor:@"finishDate"
                         inContext:context];
}

+ (NSArray *)fetchWith:(NSString *)entityName
        predicate:(NSPredicate *)predicate
 keyForDescriptor:(NSString *)key
        inContext:(NSManagedObjectContext *)context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
    
}
@end


