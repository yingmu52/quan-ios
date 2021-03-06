//
//  Message+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Message+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *commentId;
@property (nullable, nonatomic, copy) NSString *feedsId;
@property (nullable, nonatomic, copy) NSString *targetOwnerId;
@property (nullable, nonatomic, copy) NSNumber *userDeleted;
@property (nullable, nonatomic, retain) Owner *owner;

@end

NS_ASSUME_NONNULL_END
