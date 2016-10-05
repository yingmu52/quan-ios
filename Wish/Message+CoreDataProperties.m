//
//  Message+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/5/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic feedsId;
@dynamic targetOwnerId;
@dynamic userDeleted;
@dynamic owner;
@dynamic commentId;

@end
