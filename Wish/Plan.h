//
//  Plan.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task;

@interface Plan : NSManagedObject

@property (nonatomic, retain) NSNumber * backgroundNum;
@property (nonatomic, retain) NSNumber * finishPercent;
@property (nonatomic, retain) NSNumber * followCount;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSNumber * planStatus;
@property (nonatomic, retain) NSNumber * remainDays;
@property (nonatomic, retain) NSNumber * tryCount;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
