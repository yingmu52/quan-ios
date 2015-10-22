//
//  Comment+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment+CoreDataProperties.h"

@implementation Comment (CoreDataProperties)

@dynamic commentId;
@dynamic content;
@dynamic createTime;
@dynamic idForReply;
@dynamic isMyComment;
@dynamic nameForReply;
@dynamic feed;
@dynamic owner;

@end
