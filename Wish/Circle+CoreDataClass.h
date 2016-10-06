//
//  Circle+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBase+CoreDataClass.h"

@class Plan;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, CircleType) {
    CircleTypeUndefine,
    CircleTypeJoined,
    CircleTypeFollowed
};


@interface Circle : MSBase

// Insert code here to declare functionality of your managed object subclass
+ (Circle *)updateCircleWithInfo:(NSDictionary *)info managedObjectContext:(NSManagedObjectContext *)context;

+ (Circle *)createCircle:(NSString *)circleId
                    name:(NSString *)circleName
                    desc:(NSString *)desc
                 imageId:(NSString *)imageId
                 context:(NSManagedObjectContext *)context;


@end

NS_ASSUME_NONNULL_END

#import "Circle+CoreDataProperties.h"
