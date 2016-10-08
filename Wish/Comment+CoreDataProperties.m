//
//  Comment+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Comment+CoreDataProperties.h"

@implementation Comment (CoreDataProperties)

+ (NSFetchRequest<Comment *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
}

@dynamic idForReply;
@dynamic nameForReply;
@dynamic feed;
@dynamic owner;

@end
