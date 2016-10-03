//
//  MSBase+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSBase (CoreDataProperties)

+ (NSFetchRequest<MSBase *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *mLastReadTime;
@property (nullable, nonatomic, copy) NSString *mTitle;
@property (nullable, nonatomic, copy) NSString *mDescription;
@property (nullable, nonatomic, copy) NSString *mCoverImageId;
@property (nullable, nonatomic, copy) NSString *mUID;

@end

NS_ASSUME_NONNULL_END
