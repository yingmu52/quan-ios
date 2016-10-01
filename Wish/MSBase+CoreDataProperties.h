//
//  MSBase+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/1/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSBase (CoreDataProperties)

+ (NSFetchRequest<MSBase *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *lastReadTime;

@end

NS_ASSUME_NONNULL_END
