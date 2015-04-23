//
//  User.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-16.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "User.h"

@implementation User


#pragma mark - set


+ (void)updateOwnerInfo:(NSDictionary *)info{
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:OWNERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)updateAttributeFromDictionary:(NSDictionary *)info{
    NSMutableDictionary *oldOwnerInfo = [[self.class getOwnerInfo] mutableCopy];
    for (NSString *key in [info allKeys]){
        oldOwnerInfo[key] = info[key];
    }
    [self.class updateOwnerInfo:oldOwnerInfo];
}
#pragma mark - get

+ (NSDictionary *)getOwnerInfo{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:OWNERINFO];
    //    NSAssert(![info isKindOfClass:[NSDictionary class]], @"info is not a dictionary");
    return info;
}


+ (NSString *)uid{
//    return @"100004";
    NSDictionary *info = [self.class getOwnerInfo];
    return [NSString stringWithFormat:@"%@", info ? info[UID] : @""];
}

+ (NSString *)uKey{
//    return @"ukey551616ce53da30.10303099";
    NSDictionary *info = [self.class getOwnerInfo];
    return info[UKEY];
}


+ (NSString *)updatedProfilePictureId{
    NSDictionary *info = [self.class getOwnerInfo];
    return info[PROFILE_PICTURE_ID_CUSTOM];

}

+ (BOOL)isUserLogin{
    return [[self class] uid] && [[self class] uKey];
}

+ (NSURL *)userProfilePictureURL{
    NSDictionary *info = [self.class getOwnerInfo];
    return [NSURL URLWithString:info[PROFILE_PICTURE_ID]];
}

+ (NSString *)userDisplayName{
    NSDictionary *info = [self.class getOwnerInfo];
    return info[USER_DISPLAY_NAME];
}

+ (NSString *)gender{
    NSDictionary *info = [self.class getOwnerInfo];
    return info[GENDER];
}



#pragma mark - simulator implementation (need to uncomment )
/*

+ (NSString *)uid{
    return @"100004";
}

+ (NSString *)uKey{
    return @"ukey551616ce53da30.10303099";
}


+ (NSString *)updatedProfilePictureId{
    return @"";
    
}

+ (BOOL)isUserLogin{
    return [[self class] uid] && [[self class] uKey];
}

+ (NSURL *)userProfilePictureURL{
    return [NSURL URLWithString:@"http://q.qlogo.cn/qqapp/1104337894/78167CF6EB9262F8C4BA18F858BC3485/100"];
}

+ (NSString *)userDisplayName{
    return @"Test Name";
}

+ (NSString *)gender{
    return @"TestGender";
}
*/
@end
