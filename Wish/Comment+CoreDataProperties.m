//
//  Comment+CoreDataProperties.m
//  Stories
//
//  Created by Xinyi Zhuang on 8/2/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
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
@dynamic nameForReply;
@dynamic feed;
@dynamic owner;

@end
