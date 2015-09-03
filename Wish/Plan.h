//
//  Plan.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed, Owner;

@interface Plan : NSManagedObject

@property (nonatomic, retain) NSString * backgroundNum;
@property (nonatomic, retain) NSString * cornerMask;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * detailText;
@property (nonatomic, retain) NSNumber * discoverIndex;
@property (nonatomic, retain) NSNumber * followCount;
@property (nonatomic, retain) NSNumber * isFollowed;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * planId;
@property (nonatomic, retain) NSNumber * planStatus;
@property (nonatomic, retain) NSString * planTitle;
@property (nonatomic, retain) NSNumber * tryTimes;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *feeds;
@property (nonatomic, retain) Owner *owner;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
