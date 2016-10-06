//
//  Circle+CoreDataClass.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Circle+CoreDataClass.h"
#import "Plan+CoreDataClass.h"
@implementation Circle

// Insert code here to add functionality to your managed object subclass
+ (Circle *)updateCircleWithInfo:(NSDictionary *)info managedObjectContext:(nonnull NSManagedObjectContext *)context{
    Circle *circle;
    
    NSArray *results = [Plan fetchWith:@"Circle"
                             predicate:[NSPredicate predicateWithFormat:@"mUID == %@",info[@"id"]]
                      keyForDescriptor:@"mCreateTime"
                  managedObjectContext:context]; //utility method from Plan+PlanCRUD.h
    
    if (!results.count) {
        circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle"
                                               inManagedObjectContext:context];
        
        circle.mUID = info[@"id"];
        circle.mCreateTime = [NSDate dateWithTimeIntervalSince1970:[info[@"createTime"] integerValue]];
    }else{
        circle = results.lastObject;
    }
    
    //圈名
    NSString *cTitle = info[@"name"];
    if (cTitle && ![circle.mTitle isEqualToString:cTitle]) {
        circle.mTitle = cTitle;
    }
    
    //圈子描述
    NSString *cDesc = info[@"description"];
    if (cDesc && ![circle.mDescription isEqualToString:cDesc]) {
        circle.mDescription = cDesc;
    }
    
    //背影图
    NSString *bg = info[@"backGroudPic"];
    if (bg && ![circle.mCoverImageId isEqualToString:bg]) {
        circle.mCoverImageId = bg;
    }
    
    //主人
    NSString *ownerId = info[@"ownerId"];
    if (ownerId && ![circle.ownerId isEqualToString:ownerId]) {
        circle.ownerId = ownerId;
    }
    
    id nFans = info[@"watch"];
    if (nFans && ![circle.nFans isEqualToNumber:@([nFans integerValue])]) {
        circle.nFans = @([nFans integerValue]);
    }
    
    id nFansToday = info[@"new_watch"];
    if (nFansToday && ![circle.nFansToday isEqualToNumber:@([nFansToday integerValue])]) {
        circle.nFansToday = @([nFansToday integerValue]);
    }
    
    
    id iswatch = info[@"iswatch"];
    if (iswatch) {
        circle.circleType = [iswatch boolValue] ? @(CircleTypeFollowed) : @(CircleTypeUndefine);
    }
    
    id iscanwatch = info[@"iscanwatch"];
    if (iscanwatch) {
        circle.isFollowable = [iscanwatch boolValue] ? @YES : @NO;
    }
    
    id planCounts = info[@"plancount"];
    if (planCounts && ![circle.newPlanCount isEqualToNumber:@([planCounts integerValue])]) {
        circle.newPlanCount = @([planCounts integerValue]);
    }
    
    return circle;
    
}

+ (Circle *)createCircle:(NSString *)circleId
                    name:(NSString *)circleName
                    desc:(NSString *)desc
                 imageId:(NSString *)imageId
                 context:(NSManagedObjectContext *)context{
    Circle *circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle"
                                                   inManagedObjectContext:context];
    circle.mUID = circleId;
    circle.mTitle = circleName;
    circle.mDescription = desc;
    circle.mCoverImageId = imageId;
    circle.mCreateTime = [NSDate date];
    circle.ownerId = [User uid];
    
    //以下参数的设置影响到是否能在“我加入的”tab展示
    NSNumber *t = @(CircleTypeJoined);
    circle.circleType = t;
    circle.mTypeID = [NSString stringWithFormat:@"%@_%@",circleId,t];
    
    return circle;
}


@end
