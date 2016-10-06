//
//  Message+CoreDataClass.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBase+CoreDataClass.h"

@class Owner;

NS_ASSUME_NONNULL_BEGIN

@interface Message : MSBase

+ (Message *)updateMessageWithInfo:(NSDictionary *)messageInfo
                         ownerInfo:(NSDictionary *)ownerInfo
              managedObjectContext:(NSManagedObjectContext *)context;


@end

NS_ASSUME_NONNULL_END

#import "Message+CoreDataProperties.h"
