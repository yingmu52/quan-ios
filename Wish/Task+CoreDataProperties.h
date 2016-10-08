//
//  Task+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Task+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *imageLocalIdentifiers;
@property (nullable, nonatomic, copy) NSNumber *isFinished;
@property (nullable, nonatomic, copy) NSString *planID;
@property (nullable, nonatomic, copy) NSNumber *progress;

@end

NS_ASSUME_NONNULL_END
