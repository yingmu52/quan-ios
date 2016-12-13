//
//  Plan+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 13/12/2016.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Plan+CoreDataProperties.h"

@implementation Plan (CoreDataProperties)

+ (NSFetchRequest<Plan *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Plan"];
}

@dynamic cornerMask;
@dynamic followCount;
@dynamic isPrivate;
@dynamic planStatus;
@dynamic rank;
@dynamic readCount;
@dynamic shareUrl;
@dynamic tryTimes;
@dynamic lastDiscoverTime;
@dynamic circle;
@dynamic feeds;
@dynamic owner;

@end
