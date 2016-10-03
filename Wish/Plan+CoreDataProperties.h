//
//  Plan+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Plan.h"


NS_ASSUME_NONNULL_BEGIN

@interface Plan (CoreDataProperties)

+ (NSFetchRequest<Plan *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *backgroundNum;
@property (nullable, nonatomic, copy) NSString *cornerMask;
@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *detailText;
@property (nullable, nonatomic, copy) NSNumber *discoverIndex;
@property (nullable, nonatomic, copy) NSNumber *followCount;
@property (nullable, nonatomic, copy) NSNumber *isFollowed;
@property (nullable, nonatomic, copy) NSNumber *isPrivate;
@property (nullable, nonatomic, copy) NSString *planId;
@property (nullable, nonatomic, copy) NSNumber *planStatus;
@property (nullable, nonatomic, copy) NSString *planTitle;
@property (nullable, nonatomic, copy) NSString *rank;
@property (nullable, nonatomic, copy) NSNumber *readCount;
@property (nullable, nonatomic, copy) NSString *shareUrl;
@property (nullable, nonatomic, copy) NSNumber *tryTimes;
@property (nullable, nonatomic, copy) NSDate *updateDate;
@property (nullable, nonatomic, retain) Circle *circle;
@property (nullable, nonatomic, retain) NSSet<Feed *> *feeds;
@property (nullable, nonatomic, retain) Owner *owner;

@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet<Feed *> *)values;
- (void)removeFeeds:(NSSet<Feed *> *)values;

@end

NS_ASSUME_NONNULL_END
