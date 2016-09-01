//
//  Message+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 9/1/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentId;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *createTime;
@property (nullable, nonatomic, retain) NSString *feedsId;
@property (nullable, nonatomic, retain) NSNumber *userDeleted;
@property (nullable, nonatomic, retain) NSString *messageId;
@property (nullable, nonatomic, retain) NSString *picurl;
@property (nullable, nonatomic, retain) NSString *targetOwnerId;
@property (nullable, nonatomic, retain) Owner *owner;

@end

NS_ASSUME_NONNULL_END
