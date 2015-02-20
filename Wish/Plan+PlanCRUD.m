//
//  Plan+PlanCRUD.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan+PlanCRUD.h"
#import "FetchCenter.h"
#import "AppDelegate.h"
@implementation Plan (PlanCRUD)

+ (Plan *)updatePlanFromServer:(NSDictionary *)dict{
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    Plan *plan;
    //check existance
    NSArray *checks = [Plan fetchWith:@"Plan"
                            predicate:[NSPredicate predicateWithFormat:@"planId = %@",dict[@"id"]]
                     keyForDescriptor:@"createDate"
                            inContext:context];
    NSAssert(checks.count <= 1, @"planId must be a unique!");
    if (!checks.count) {
        //insert new fetched plan
        plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                             inManagedObjectContext:context];
    }else{
        //update existing plan
        plan = checks.lastObject;
    }
    
    plan.planId = dict[@"id"];
    plan.ownerId = dict[@"ownerId"];
    plan.planTitle = dict[@"title"];
    plan.createDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
    
    plan.updateDate = [NSDate dateWithTimeInterval:[dict[@"updateTime"] integerValue]
                                         sinceDate:plan.createDate];
    plan.userDeleted = @(NO);
    if ([context save:nil]) {
        NSLog(@"updated plan list form server");
    }


    return plan;

}
+ (Plan *)createPlan:(NSString *)title
                date:(NSDate *)date
             privacy:(BOOL)isPrivate
               image:(UIImage *)image{

    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
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
        plan.image = UIImageJPEGRepresentation(image, 0.1);
        plan.createDate = [NSDate date];
        plan.userDeleted = @(NO);
        
        if ([context save:nil] && [SystemUtil hasActiveInternetConnection]) {
//            [FetchCenter uploadToCreatePlan:plan];
            [[[FetchCenter alloc] init] uploadToCreatePlan:plan];
        }

    }
    return plan;
}

- (void)deleteSelf
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.userDeleted = @(YES);
    if ([SystemUtil hasActiveInternetConnection]){     //active internet
        if (self.planId && [self.ownerId isEqualToString:[SystemUtil getOwnerId]]){
//            [FetchCenter postToDeletePlan:self];
            [[[FetchCenter alloc] init] postToDeletePlan:self];
        }else{
            NSLog(@"delete from local");
        }
    }
    [context deleteObject:self];    
}

+ (NSArray *)loadMyPlans
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;

    NSPredicate *notDeleted = [NSPredicate predicateWithFormat:@"userDeleted = NO"];
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

- (NSNumber *)extractNumberFromString:(NSString *)string{
    return @([[string substringFromIndex:2] integerValue]);
}
@end


