//
//  Plan.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "Plan.h"
#import "Feed.h"
#import "Owner.h"
#import "FetchCenter.h"
#import "AppDelegate.h"
#import "User.h"

@implementation Plan

- (NSArray *)planStatusTags{
    return @[@"进行中",@"达成",@"放弃"];
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
+ (Plan *)updatePlanFromServer:(NSDictionary *)dict
                     ownerInfo:(NSDictionary *)ownerInfo
          managedObjectContext:(nonnull NSManagedObjectContext *)context{ //owner may be different !
    
    Plan *plan;
    //check existance
    NSArray *checks = [Plan fetchWith:@"Plan"
                            predicate:[NSPredicate predicateWithFormat:@"planId == %@",dict[@"id"]]
                     keyForDescriptor:@"createDate" managedObjectContext:context];

    if (!checks.count) {
        //insert new fetched plan
        plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                             inManagedObjectContext:context];
        plan.createDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
        plan.planId = dict[@"id"];
        plan.owner = [Owner updateOwnerWithInfo:ownerInfo managedObjectContext:context];
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

    if (![plan.shareUrl isEqualToString:dict[@"share_url"]]) {
        plan.shareUrl = dict[@"share_url"];
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
    
    NSString *cornerMask = dict[@"cornerMark"];
    if (![plan.cornerMask isEqualToString:cornerMask] &&
        [cornerMask isEqualToString:@"top"]){
        plan.cornerMask = cornerMask;
    }
    
    return plan;
    
}

+ (Plan *)createPlan:(NSString *)planTitle
              planId:(NSString *)planId
        backgroundID:(NSString *)backGroundID
            inCircle:(NSString *)circleId inManagedObjectContext:(NSManagedObjectContext *)context{
    
    
    Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                               inManagedObjectContext:context];
    
    plan.planId = planId;
    plan.backgroundNum = backGroundID;
    plan.planTitle = planTitle;
    plan.isPrivate = @(YES);
    plan.createDate = [NSDate date];
    
    //貌似数据不全会影响到FRC在列表上的展示？
    plan.updateDate = [NSDate date];
    plan.discoverIndex = @(888);
    
    
    plan.planStatus = @(PlanStatusOnGoing);
    plan.owner = [Owner updateOwnerWithInfo:[Owner myWebInfo] managedObjectContext:context];
    
    Circle *circle = [Plan fetchWith:@"Circle" predicate:[NSPredicate predicateWithFormat:@"circleId == %@",circleId]
                    keyForDescriptor:@"circleId"
                managedObjectContext:context].lastObject;
    plan.circle = circle;

    
    return plan;
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
             predicate:(NSPredicate  * _Nullable)predicate
      keyForDescriptor:(NSString *)key
  managedObjectContext:(nonnull NSManagedObjectContext *)context{
        
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

- (BOOL)isDeletable{
    return ![self.owner.ownerId isEqualToString:[User uid]] && !self.isFollowed.boolValue;
}

- (BOOL)hasDetailText{
    return self.detailText && ![self.detailText isEqualToString:@""];
}

@end
