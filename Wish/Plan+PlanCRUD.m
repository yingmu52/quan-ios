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
#import "User.h"
@implementation Plan (PlanCRUD)

- (NSArray *)planStatusTags{
    return @[@"进行中",@"达成",@"放弃"];
}

- (void)updatePlan:(NSString *)newTitle finishDate:(NSDate *)date isPrivated:(BOOL)isPrivated{
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    [delegate saveContext];

    self.planTitle = newTitle;
    self.finishDate = date;
    self.isPrivate = @(isPrivated);
    
}

- (void)updatePlanStatus:(PlanStatus)planStatus{
    
//    [managedObjectContext rollback] will discard any changes made to the context since the last save. If you want finer grain control add an NSUndoManager to the context and break out the docs! :)

    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveContext];

    NSAssert1(planStatus == PlanStatusOnGoing || planStatus == PlanStatusFinished || planStatus == PlanStatusGiveTheFuckingUp,@"invalid plan status %d", planStatus);
    self.planStatus = @(planStatus);
    self.updateDate = [NSDate date];
    
    NSAssert(self.planId, @"nil plan id");
    
    //update status to server
    [[FetchCenter new] updateStatus:self];
}


- (void)updateTryTimesOfPlan:(BOOL)assending{
    NSInteger attempts = self.tryTimes.integerValue;
    if (assending) {
        attempts += 1;
    }else{
        attempts -= 1;
    }
    self.tryTimes = @(attempts);
}
+ (Plan *)updatePlanFromServer:(NSDictionary *)dict{
    
    NSManagedObjectContext *context = [AppDelegate getContext];
    Plan *plan;
    //check existance
    NSArray *checks = [Plan fetchWith:@"Plan"
                            predicate:[NSPredicate predicateWithFormat:@"planId == %@",dict[@"id"]]
                     keyForDescriptor:@"createDate"];
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
    plan.updateDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"updateTime"] integerValue]];
    plan.finishDate = [NSDate dateWithTimeInterval:[dict[@"finishDate"] integerValue] * 24 * 60 * 60
                                         sinceDate:plan.createDate];
    plan.followCount = @([dict[@"followNums"] integerValue]);
    plan.userDeleted = @(NO);
    plan.planStatus = @([dict[@"state"] integerValue]);
    plan.backgroundNum = dict[@"backGroudPic"];
    plan.isPrivate = @([dict[@"private"] boolValue]);
    plan.tryTimes = @([dict[@"tryTimes"] integerValue]);
    
//    if ([context save:nil]) {
//        NSLog(@"updated plan list form server");
//    }


    return plan;

}
+ (Plan *)createPlan:(NSString *)title
                date:(NSDate *)date
             privacy:(BOOL)isPrivate
               image:(UIImage *)image{

    NSManagedObjectContext *context = [AppDelegate getContext];
    
    Plan *plan;
    //check existance
    NSArray *checks = [Plan fetchWith:@"Plan"
                            predicate:[NSPredicate predicateWithFormat:@"createDate = %@",date]
                     keyForDescriptor:@"createDate"];
    if (!checks.count) {
        plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                             inManagedObjectContext:context];

        plan.ownerId = [User uid];
        plan.planTitle = title;
        plan.finishDate = date;
        plan.isPrivate = @(isPrivate);
        plan.image = UIImageJPEGRepresentation(image, 0.1);
        plan.createDate = [NSDate date];
        plan.userDeleted = @(NO);
        plan.planStatus = @(PlanStatusOnGoing);
    }
    return plan;
}

- (void)deleteSelf
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    self.userDeleted = @(YES);
    if (self.planId && [self.ownerId isEqualToString:[User uid]]){
        //            [FetchCenter postToDeletePlan:self];
        [[[FetchCenter alloc] init] postToDeletePlan:self];
    }else{
        NSLog(@"delete from local");
    }
    [context deleteObject:self];
}

- (Feed *)fetchLastUpdatedFeed{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    request.predicate = [NSPredicate predicateWithFormat:@"plan = %@",self];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES]];
    request.fetchLimit = 1;
    
    NSArray *feeds = [self.managedObjectContext executeFetchRequest:request error:nil];
    return feeds.lastObject;
}

+ (NSArray *)fetchWith:(NSString *)entityName
        predicate:(NSPredicate *)predicate
 keyForDescriptor:(NSString *)key{
    
    NSManagedObjectContext *context = [AppDelegate getContext];
    
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


