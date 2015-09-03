//
//  Feed.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Plan;

@interface Feed : NSManagedObject

@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * feedId;
@property (nonatomic, retain) NSString * feedTitle;
@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * selfLiked;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Plan *plan;
@end

@interface Feed (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
