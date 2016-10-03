//
//  Plan+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Plan+CoreDataProperties.h"

@implementation Plan (CoreDataProperties)

+ (NSFetchRequest<Plan *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Plan"];
}

@dynamic backgroundNum;
@dynamic cornerMask;
@dynamic createDate;
@dynamic detailText;
@dynamic discoverIndex;
@dynamic followCount;
@dynamic isFollowed;
@dynamic isPrivate;
@dynamic planId;
@dynamic planStatus;
@dynamic planTitle;
@dynamic rank;
@dynamic readCount;
@dynamic shareUrl;
@dynamic tryTimes;
@dynamic updateDate;
@dynamic circle;
@dynamic feeds;
@dynamic owner;

@end
