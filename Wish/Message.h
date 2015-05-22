//
//  Message.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Owner;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * feedsId;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * picurl;
@property (nonatomic, retain) NSString * targetOwnerId;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) Owner *owner;

@end
