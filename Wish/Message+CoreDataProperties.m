//
//  Message+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic commentId;
@dynamic content;
@dynamic createTime;
@dynamic feedsId;
@dynamic messageId;
@dynamic picurl;
@dynamic targetOwnerId;
@dynamic userDeleted;
@dynamic owner;

@end
