//
//  Circle+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Circle+CoreDataProperties.h"

@implementation Circle (CoreDataProperties)

+ (NSFetchRequest<Circle *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Circle"];
}

@dynamic circleDescription;
@dynamic circleId;
@dynamic circleName;
@dynamic circleType;
@dynamic createDate;
@dynamic imageId;
@dynamic isFollowable;
@dynamic newPlanCount;
@dynamic nFans;
@dynamic nFansToday;
@dynamic ownerId;
@dynamic plans;

@end
