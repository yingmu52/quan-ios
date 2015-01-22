//
//  Plan+PlanCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
@implementation Plan (PlanCRUD)

+ (Plan *)createPlan:(NSString *)title
                date:(NSDate *)date
             privacy:(BOOL)isPrivate
               image:(UIImage *)image
           inContext:(NSManagedObjectContext *)context{
    
    Plan *plan;
    
    //check existance
    NSArray *checks = [Plan fetchWith:@"Plan"
                            predicate:[NSPredicate predicateWithFormat:@"finishDate = %@",date]
                     keyForDescriptor:@"finishDate"
                            inContext:context];
    if (!checks.count) {
        plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                             inManagedObjectContext:context];
        
        plan.ownerId = [AppDelegate getOwnerId];
        plan.planTitle = title;
        plan.finishDate = date;
        plan.isPrivate = @(isPrivate);
        plan.image = image;
        
        NSError *error;
        [context save:&error];

    }
    return plan;
}

- (void)deleteSelf:(NSManagedObjectContext *)context
{
    [context deleteObject:self];
    NSError *error;
    [context save:&error];
}

+ (NSArray *)loadMyPlans:(NSManagedObjectContext *)context
{
    
    return [Plan fetchWith:@"Plan"
                         predicate:nil //fetch all
                  keyForDescriptor:@"finishDate"
                         inContext:context];
}

+ (NSArray *)fetchWith:(NSString *)entityName
        predicate:(NSPredicate *)predicate
 keyForDescriptor:(NSString *)key
        inContext:(NSManagedObjectContext *)context{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
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


