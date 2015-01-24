//
//  Plan.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-23.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task;

@interface Plan : NSManagedObject

@property (nonatomic, retain) NSNumber * backgroundNum;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * planId;
@property (nonatomic, retain) NSString * planTitle;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
