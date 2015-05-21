//
//  Owner+OwnerCRUD.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Owner.h"

@interface Owner (OwnerCRUD)
+ (Owner *)updateOwnerWithInfo:(NSDictionary *)dict;
@end
