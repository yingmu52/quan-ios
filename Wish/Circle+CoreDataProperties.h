//
//  Circle+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-02-29.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Circle.h"

NS_ASSUME_NONNULL_BEGIN

@interface Circle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *circleId;
@property (nullable, nonatomic, retain) NSString *circleName;
@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSString *invitationCode;
@property (nullable, nonatomic, retain) NSString *circleDescription;
@property (nullable, nonatomic, retain) NSString *imageId;
@property (nullable, nonatomic, retain) NSString *ownerId;

@end

NS_ASSUME_NONNULL_END
