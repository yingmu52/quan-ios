//
//  Plan.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;

@interface Plan : NSManagedObject

@property (nonatomic, retain) NSNumber * backgroundNum;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSNumber * followCount;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * planId;
@property (nonatomic, retain) NSString * planTitle;
@property (nonatomic, retain) NSNumber * userDeleted;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *feeds;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
