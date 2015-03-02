//
//  Feed.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plan;

@interface Feed : NSManagedObject

@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * feedId;
@property (nonatomic, retain) NSString * feedTitle;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) Plan *plan;

@end
