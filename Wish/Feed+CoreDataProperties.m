//
//  Feed+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/5/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Feed+CoreDataProperties.h"

@implementation Feed (CoreDataProperties)

+ (NSFetchRequest<Feed *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Feed"];
}

@dynamic commentCount;
@dynamic likeCount;
@dynamic picUrls;
@dynamic selfLiked;
@dynamic type;
@dynamic comments;
@dynamic plan;

@end
