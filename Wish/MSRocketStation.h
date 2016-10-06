//
//  MSRocketStation.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/5/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSRocketStation : NSObject

+ (instancetype)sharedStation;
- (void)startDigestingTasks;
@end
