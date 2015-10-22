//
//  Comment+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentId;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *createTime;
@property (nullable, nonatomic, retain) NSString *idForReply;
@property (nullable, nonatomic, retain) NSNumber *isMyComment;
@property (nullable, nonatomic, retain) NSString *nameForReply;
@property (nullable, nonatomic, retain) Feed *feed;
@property (nullable, nonatomic, retain) Owner *owner;

@end

NS_ASSUME_NONNULL_END
