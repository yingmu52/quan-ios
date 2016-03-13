//
//  Owner+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-12.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Owner.h"

NS_ASSUME_NONNULL_BEGIN

@interface Owner (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *headUrl;
@property (nullable, nonatomic, retain) NSString *ownerId;
@property (nullable, nonatomic, retain) NSString *ownerName;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;
@property (nullable, nonatomic, retain) NSSet<Message *> *messages;
@property (nullable, nonatomic, retain) NSSet<Plan *> *plans;

@end

@interface Owner (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet<Message *> *)values;
- (void)removeMessages:(NSSet<Message *> *)values;

- (void)addPlansObject:(Plan *)value;
- (void)removePlansObject:(Plan *)value;
- (void)addPlans:(NSSet<Plan *> *)values;
- (void)removePlans:(NSSet<Plan *> *)values;

@end

NS_ASSUME_NONNULL_END
