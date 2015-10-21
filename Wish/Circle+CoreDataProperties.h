//
//  Circle+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-20.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Circle.h"

NS_ASSUME_NONNULL_BEGIN

@interface Circle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *circleId;
@property (nullable, nonatomic, retain) NSString *circleName;
@property (nullable, nonatomic, retain) NSString *invitationCode;
@property (nullable, nonatomic, retain) NSDate *createDate;

@end

NS_ASSUME_NONNULL_END
