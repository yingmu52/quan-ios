//
//  Circle.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-20.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Circle : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (Circle *)updateCircleWithInfo:(NSDictionary *)info;
@end

NS_ASSUME_NONNULL_END

#import "Circle+CoreDataProperties.h"