//
//  Feed+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Feed+CoreDataProperties.h"

@implementation Feed (CoreDataProperties)

+ (NSFetchRequest<Feed *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Feed"];
}

@dynamic commentCount;
@dynamic createDate;
@dynamic feedId;
@dynamic feedTitle;
@dynamic imageId;
@dynamic likeCount;
@dynamic picUrls;
@dynamic selfLiked;
@dynamic type;
@dynamic comments;
@dynamic plan;

@end
