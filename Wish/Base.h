//
//  Base.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Base : NSManagedObject

@property (nonatomic, retain) NSNumber * isPosted;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * postDate;

@end
