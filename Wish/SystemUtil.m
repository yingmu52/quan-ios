//
//  SystemUtil.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "SystemUtil.h"

@implementation SystemUtil


// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return [components day]+1;
}


#define OWNERID @"MOTHERFUCKING_OWNER_FUCKING_I_FUCKING_D"

#pragma mark - user id
+ (NSString *)getOwnerId{
#warning fucking change this in the future man !
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] objectForKey:OWNERID];
    ownerID = ownerID ? ownerID : @"100001";
    return ownerID;
}

+ (void)updateOwnerId:(NSString *)newID
{
    return [[NSUserDefaults standardUserDefaults] setObject:newID forKey:OWNERID];
}


+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
#warning time zone?
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}


+ (BOOL)hasActiveInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return reachability.currentReachabilityStatus != NotReachable;
}

@end
