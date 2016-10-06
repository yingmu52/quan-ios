//
//  Task+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Task"];
}

@dynamic imageLocalIdentifiers;
@dynamic planID;
@dynamic isFinished;

@end
