//
//  Owner.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Plan;

@interface Owner : NSManagedObject

@property (nonatomic, retain) NSString * headUrl;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *plans;
@end

@interface Owner (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addPlansObject:(Plan *)value;
- (void)removePlansObject:(Plan *)value;
- (void)addPlans:(NSSet *)values;
- (void)removePlans:(NSSet *)values;

@end
