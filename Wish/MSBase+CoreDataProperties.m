//
//  MSBase+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase+CoreDataProperties.h"

@implementation MSBase (CoreDataProperties)

+ (NSFetchRequest<MSBase *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MSBase"];
}

@dynamic mCoverImageId;
@dynamic mCreateTime;
@dynamic mDescription;
@dynamic mLastReadTime;
@dynamic mSpecialTimestamp;
@dynamic mTitle;
@dynamic mTypeID;
@dynamic mUID;
@dynamic mUpdateTime;

@end
