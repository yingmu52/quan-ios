//
//  User.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-16.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//user dictionary keys
#define OWNERINFO @"motherfucking_user_fucking_in_fucking_fo" //key for user info
#define ACCESS_TOKEN @"access_token_string" //NSString
#define OPENID @"user_open_id" //NSString
#define PROFILE_PICTURE_URL @"user_profile_url" //NSString
#define EXPIRATION_DATE @"login_expiraiton_date" //NSDate
#define GENDER @"user_gender" //NSString
#define USER_DISPLAY_NAME @"user_display_name" //NSString
//#define LOGIN_STATUS @"user_login_status" //BOOL
#define UID @"user_unique_id"
#define UKEY @"user_unique_request_key"

@interface User : NSObject

+ (NSString *)uid;
+ (NSString *)uKey;

+ (void)updateOwnerInfo:(NSDictionary *)info;

+ (BOOL)isUserLogin;
+ (NSURL *)userProfilePictureURL;
+ (NSString *)userDisplayName;
@end
