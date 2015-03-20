//
//  User.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-16.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSString *)uid{
    NSDictionary *info = [self.class getOwnerInfo];
    return [NSString stringWithFormat:@"%@",info[UID]];
}

+ (NSString *)uKey{
    NSDictionary *info = [self.class getOwnerInfo];
    return info[UKEY];
}
+ (void)updateOwnerInfo:(NSDictionary *)info{
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:OWNERINFO];
}

+ (NSDictionary *)getOwnerInfo{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:OWNERINFO];
    //    NSAssert(![info isKindOfClass:[NSDictionary class]], @"info is not a dictionary");
    return info;
}

+ (BOOL)isUserLogin{
    NSDictionary *info = [self.class getOwnerInfo];
    return info && [info[LOGIN_STATUS] boolValue];
}

+ (NSURL *)userProfilePictureURL{
    NSDictionary *info = [self.class getOwnerInfo];
    return [NSURL URLWithString:info[PROFILE_PICTURE_URL]];
}

+ (NSString *)userDisplayName{
    NSDictionary *info = [self.class getOwnerInfo];
    return info[USER_DISPLAY_NAME];
}

@end
