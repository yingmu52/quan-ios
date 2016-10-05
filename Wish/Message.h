//
//  Message.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-22.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MSBase.h"
@class Owner;

NS_ASSUME_NONNULL_BEGIN

@interface Message : MSBase
+ (Message *)updateMessageWithInfo:(NSDictionary *)messageInfo
                         ownerInfo:(NSDictionary *)ownerInfo
              managedObjectContext:(NSManagedObjectContext *)context;
@end

NS_ASSUME_NONNULL_END

#import "Message+CoreDataProperties.h"
