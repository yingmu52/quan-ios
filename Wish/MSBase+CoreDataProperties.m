//
//  MSBase+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase+CoreDataProperties.h"

@implementation MSBase (CoreDataProperties)

+ (NSFetchRequest<MSBase *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MSBase"];
}

@dynamic mLastReadTime;
@dynamic mTitle;
@dynamic mDescription;
@dynamic mCoverImageId;
@dynamic mUID;
@dynamic mCreateTime;
@dynamic mUpdateTime;

@end
