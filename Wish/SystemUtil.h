//
//  SystemUtil.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "Reachability.h"
@interface SystemUtil : NSObject


+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSUInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
+ (NSString *)getOwnerId;
+ (void)updateOwnerId:(NSString *)newID;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (BOOL)hasActiveInternetConnection;

@end
