//
//  Comment.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed, Owner;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * idForReply;
@property (nonatomic, retain) NSNumber * isMyComment;
@property (nonatomic, retain) NSString * nameForReply;
@property (nonatomic, retain) Feed *feed;
@property (nonatomic, retain) Owner *owner;

@end
