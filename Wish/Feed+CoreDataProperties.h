//
//  Feed+CoreDataProperties.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/3/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "Feed.h"


NS_ASSUME_NONNULL_BEGIN

@interface Feed (CoreDataProperties)

+ (NSFetchRequest<Feed *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *commentCount;
@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *feedId;
@property (nullable, nonatomic, copy) NSString *feedTitle;
@property (nullable, nonatomic, copy) NSString *imageId;
@property (nullable, nonatomic, copy) NSNumber *likeCount;
@property (nullable, nonatomic, copy) NSString *picUrls;
@property (nullable, nonatomic, copy) NSNumber *selfLiked;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;
@property (nullable, nonatomic, retain) Plan *plan;

@end

@interface Feed (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

@end

NS_ASSUME_NONNULL_END
