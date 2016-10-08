//
//  Plan+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Plan+CoreDataProperties.h"

@implementation Plan (CoreDataProperties)

+ (NSFetchRequest<Plan *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Plan"];
}

@dynamic cornerMask;
@dynamic discoverIndex;
@dynamic followCount;
@dynamic isFollowed;
@dynamic isPrivate;
@dynamic planStatus;
@dynamic rank;
@dynamic readCount;
@dynamic shareUrl;
@dynamic tryTimes;
@dynamic circle;
@dynamic feeds;
@dynamic owner;

@end
