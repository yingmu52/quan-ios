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
}

+ (void)updateAttributeFromDictionary:(NSDictionary *)info{
    NSDictionary *oldOwnerInfo = [[self.class getOwnerInfo] mutableCopy];
    for (NSString *key in [info allKeys]){
        if ([oldOwnerInfo objectForKey:key]){
            [oldOwnerInfo setValue:info[key] forKey:key];
        }
        
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
    NSDictionary *info = [self.class getOwnerInfo];
    return [NSString stringWithFormat:@"%@", info ? info[UID] : @""];
}

+ (NSString *)uKey{
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

@end
