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
+ (Plan *)updatePlanFromServer:(NSDictionary *)dict ownerInfo:(NSDictionary *)ownerInfo{ //owner may be different !
    
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
        plan.createDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
        plan.planId = dict[@"id"];
        plan.owner = [Owner updateOwnerWithInfo:ownerInfo];
    }else{
        //update existing plan
        plan = checks.lastObject;
    }
    
    if (![plan.owner.ownerName isEqualToString:ownerInfo[@"name"]]){
        plan.owner.ownerName = ownerInfo[@"name"];
    }
    
    if (![plan.planTitle isEqualToString:dict[@"title"]]){
        plan.planTitle = dict[@"title"];
    }

    if (![plan.detailText isEqualToString:dict[@"description"]] && ![dict[@"description"] isKindOfClass:[NSNull class]] ){
        plan.detailText = dict[@"description"];
    }

    if (![plan.backgroundNum isEqualToString:dict[@"backGroudPic"]]) {
        plan.backgroundNum = dict[@"backGroudPic"];
    }
    
    if (![plan.updateDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[dict[@"updateTime"] integerValue]]]) {
        plan.updateDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"updateTime"] integerValue]];
    }

    if (![plan.followCount isEqualToNumber:@([dict[@"followNums"] integerValue])]){
        plan.followCount = @([dict[@"followNums"] integerValue]);
    }

    if (![plan.planStatus isEqualToNumber:@([dict[@"state"] integerValue])]){
        plan.planStatus = @([dict[@"state"] integerValue]);
    }


    if (![plan.isPrivate isEqualToNumber:@([dict[@"private"] boolValue])]){
        plan.isPrivate = @([dict[@"private"] boolValue]);
    }

    if (![plan.tryTimes isEqualToNumber:@([dict[@"tryTimes"] integerValue])]){
        plan.tryTimes = @([dict[@"tryTimes"] integerValue]);
    }
    
    if (![plan.cornerMask isEqualToString:dict[@"cornerMark"]] && ![dict[@"cornerMark"] isKindOfClass:[NSNull class]]) {
        plan.cornerMask = dict[@"cornerMark"];
    }
    
    return plan;

}
+ (Plan *)createPlan:(NSString *)title privacy:(BOOL)isPrivate image:(UIImage *)image{

    NSManagedObjectContext *context = [AppDelegate getContext];
    
    Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                               inManagedObjectContext:context];
    
    plan.planTitle = title;
    plan.isPrivate = @(isPrivate);
    plan.image = image;
    plan.createDate = [NSDate date];
    plan.planStatus = @(PlanStatusOnGoing);
    [plan addMyselfAsOwner];
    return plan;
}

- (void)deleteSelf
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (self.planId && [self.owner.ownerId isEqualToString:[User uid]]){
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

- (void)addMyselfAsOwner{
    self.owner = [Owner updateOwnerWithInfo:@{@"headUrl":[User updatedProfilePictureId],
                                                @"id":[User uid],
                                                @"name":[User userDisplayName]}];
}

- (BOOL)isDeletable{
    return ![self.owner.ownerId isEqualToString:[User uid]] && !self.isFollowed.boolValue;
}

- (BOOL)hasDetailText{
    return self.detailText && ![self.detailText isEqualToString:@""];
}
@end



