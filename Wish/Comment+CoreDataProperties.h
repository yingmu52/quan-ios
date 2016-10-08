//
//  Comment+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/8/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Comment+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

+ (NSFetchRequest<Comment *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *idForReply;
@property (nullable, nonatomic, copy) NSString *nameForReply;
@property (nullable, nonatomic, retain) Feed *feed;
@property (nullable, nonatomic, retain) Owner *owner;

@end

NS_ASSUME_NONNULL_END
