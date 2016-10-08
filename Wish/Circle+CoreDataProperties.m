//
//  Circle+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Circle+CoreDataProperties.h"

@implementation Circle (CoreDataProperties)

+ (NSFetchRequest<Circle *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Circle"];
}

@dynamic circleType;
@dynamic isFollowable;
@dynamic newPlanCount;
@dynamic nFans;
@dynamic nFansToday;
@dynamic ownerId;
@dynamic plans;

@end
