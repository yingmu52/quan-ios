//
//  Task.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-22.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plan;

@interface Task : NSManagedObject

@property (nonatomic, retain) Plan *plan;

@end
