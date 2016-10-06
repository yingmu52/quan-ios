//
//  Plan+CoreDataClass.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Plan+CoreDataClass.h"
#import "Circle+CoreDataClass.h"
#import "Feed+CoreDataClass.h"
#import "Owner+CoreDataClass.h"
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
    
    Plan *plan = [Plan fetchID:dict[@"id"] inManagedObjectContext:context];
    
    if (!plan) {
        //insert new fetched plan
        plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                             inManagedObjectContext:context];
        plan.mCreateTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createTime"] integerValue]];
        plan.mUID = dict[@"id"];
        plan.owner = [Owner updateOwnerWithInfo:ownerInfo managedObjectContext:context];
    }
    
    NSString *ptitle = dict[@"title"];
    if (ptitle && ![plan.mTitle isEqualToString:ptitle]) {
        plan.mTitle = ptitle;
    }
    
    NSString *pDetail = dict[@"description"];
    if (pDetail && ![plan.mDescription isEqualToString:pDetail]) {
        plan.mDescription = pDetail;
    }
    
    NSString *pBackground = dict[@"backGroudPic"];
    if (pBackground && ![plan.mCoverImageId isEqualToString:pBackground]) {
        plan.mCoverImageId = pBackground;
    }
    
    NSString *pShareUrl = dict[@"share_url"];
    if (pShareUrl && ![plan.shareUrl isEqualToString:pShareUrl]) {
        plan.shareUrl = pShareUrl;
    }
    
    NSDate *pUpdateDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"updateTime"] integerValue]];
    if (pUpdateDate && ![plan.mUpdateTime isEqualToDate:pUpdateDate]) {
        plan.mUpdateTime = pUpdateDate;
    }
    
    NSNumber *pFollowCount = @([dict[@"followNums"] integerValue]);
    if (pFollowCount && ![plan.followCount isEqualToNumber:pFollowCount]){
        plan.followCount = pFollowCount;
    }
    
    NSNumber *pStatus = @([dict[@"state"] integerValue]);
    if (pStatus && ![plan.planStatus isEqualToNumber:pStatus]){
        plan.planStatus = pStatus;
    }
    
    NSNumber *pIsPrivate = @([dict[@"private"] boolValue]);
    if (pIsPrivate && ![plan.isPrivate isEqualToNumber:pIsPrivate]){
        plan.isPrivate = pIsPrivate;
    }
    
    NSNumber *pTryTime = @([dict[@"tryTimes"] integerValue]);
    if (pTryTime && ![plan.tryTimes isEqualToNumber:pTryTime]){
        plan.tryTimes = pTryTime;
    }
    
    NSString *cornerMask = dict[@"cornerMark"];
    if (cornerMask && ![plan.cornerMask isEqualToString:cornerMask]){
        plan.cornerMask = cornerMask;
    }
    
    id readCount = dict[@"readnums"];
    if (readCount && ![plan.readCount isEqualToNumber:@([readCount integerValue])]) {
        plan.readCount = @([readCount integerValue]);
    }
    
    plan.mLastReadTime = [NSDate date];
    return plan;
    
}

+ (Plan *)createPlan:(NSString *)planTitle
              planId:(NSString *)planId
        backgroundID:(NSString *)backGroundID
            inCircle:(NSString *)circleId inManagedObjectContext:(NSManagedObjectContext *)context{
    
    
    Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan"
                                               inManagedObjectContext:context];
    
    plan.mUID = planId;
    plan.mCoverImageId = backGroundID;
    plan.mTitle = planTitle;
    plan.isPrivate = @(YES);
    plan.mCreateTime = [NSDate date];
    
    //貌似数据不全会影响到FRC在列表上的展示？
    plan.mUpdateTime = [NSDate date];
    plan.discoverIndex = @(888);
    
    
    plan.planStatus = @(PlanStatusOnGoing);
    plan.owner = [Owner updateOwnerWithInfo:[Owner myWebInfo] managedObjectContext:context];
    Circle *circle = [Circle fetchID:circleId inManagedObjectContext:context];
    
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
    return ![self.owner.mUID isEqualToString:[User uid]] && !self.isFollowed.boolValue;
}

- (BOOL)hasDetailText{
    return self.mDescription && ![self.mDescription isEqualToString:@""];
}


@end
