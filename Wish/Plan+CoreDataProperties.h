//
//  Plan+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 8/16/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Plan.h"

NS_ASSUME_NONNULL_BEGIN

@interface Plan (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *backgroundNum;
@property (nullable, nonatomic, retain) NSString *cornerMask;
@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSString *detailText;
@property (nullable, nonatomic, retain) NSNumber *discoverIndex;
@property (nullable, nonatomic, retain) NSNumber *followCount;
@property (nullable, nonatomic, retain) NSNumber *isFollowed;
@property (nullable, nonatomic, retain) NSNumber *isPrivate;
@property (nullable, nonatomic, retain) NSString *planId;
@property (nullable, nonatomic, retain) NSNumber *planStatus;
@property (nullable, nonatomic, retain) NSNumber *readCount;
@property (nullable, nonatomic, retain) NSString *planTitle;
@property (nullable, nonatomic, retain) NSString *rank;
@property (nullable, nonatomic, retain) NSNumber *tryTimes;
@property (nullable, nonatomic, retain) NSDate *updateDate;
@property (nullable, nonatomic, retain) NSString *shareUrl;
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
