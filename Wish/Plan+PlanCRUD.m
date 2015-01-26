//
//  Plan+PlanCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan+PlanCRUD.h"
#import "FetchCenter.h"
@implementation Plan (PlanCRUD)



+ (Plan *)createPlan:(NSString *)title
                date:(NSDate *)date
             privacy:(BOOL)isPrivate
               image:(UIImage *)image
           inContext:(NSManagedObjectContext *)context{
    
    Plan *plan;
    
    //check existance
    NSArray *checks = [Plan fetchWith:@"Plan"
                            predicate:[NSPredicate predicateWithFormat:@"createDate = %@",date]
                     keyForDescriptor:@"createDate"
                            inContext:context];
    if (!checks.count) {
        plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                             inManagedObjectContext:context];
        
        plan.ownerId = [SystemUtil getOwnerId];
        plan.planTitle = title;
        plan.finishDate = date;
        plan.isPrivate = @(isPrivate);
        plan.image = image;
        plan.createDate = [NSDate date];
        
        if ([context save:nil]) {
            [FetchCenter uploadToCreatePlan:plan];
        }

    }
    return plan;
}

- (void)deleteSelf:(NSManagedObjectContext *)context
{
    if ([SystemUtil hasActiveInternetConnection]){     //active internet
        if (self.planId && [self.ownerId isEqualToString:[SystemUtil getOwnerId]]){
            [FetchCenter postToDeletePlan:self];
        }else{
            [context deleteObject:self];
            NSLog(@"deleting from loca, no need to post delete request");
        }
    }else{    //inactive internet
        self.userDeleted = @(YES);
    }
    [context save:nil];
    
}

+ (NSArray *)loadMyPlans:(NSManagedObjectContext *)context
{
    NSPredicate *notDeleted = [NSPredicate predicateWithFormat:@"userDeleted = NO OR userDeleted = nil"];
    return [Plan fetchWith:@"Plan"
                         predicate:notDeleted //fetch all non user deleted
                  keyForDescriptor:@"createDate"
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


