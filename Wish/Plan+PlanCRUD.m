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

- (NSArray *)planStatusTags{
    return @[@"进行中",@"达成",@"放弃"];
}
- (void)updatePlanStatus:(PlanStatus)planStatus{
    NSAssert1(planStatus == PlanStatusOnGoing || planStatus == PlanStatusFinished || planStatus == PlanStatusGiveTheFuckingUp,@"invalid plan status %d", planStatus);
    self.planStatus = @(planStatus);
    self.updateDate = [NSDate date];
    if ([self.managedObjectContext save:nil] && self.planId) {
        NSLog(@"updated status : %d",planStatus);
        //update status to server
        [[FetchCenter alloc] updateStatus:self];
    }else{
        NSLog(@"failed to save or null planId");
    }
}

+ (Plan *)updatePlanFromServer:(NSDictionary *)dict{
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
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
    plan.backgroundNum = [plan extractNumberFromString:dict[@"backGroudPic"]];
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
                     keyForDescriptor:@"createDate"];
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
        plan.planStatus = @(PlanStatusOnGoing);
    }
    return plan;
}

- (void)deleteSelf
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.userDeleted = @(YES);
    if (self.planId && [self.ownerId isEqualToString:[SystemUtil getOwnerId]]){
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
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
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


