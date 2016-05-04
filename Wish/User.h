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
#define PROFILE_PICTURE_ID @"user_profile_id_qq" //NSString
#define PROFILE_PICTURE_ID_CUSTOM @"user_profile_id"
#define EXPIRATION_DATE @"login_expiraiton_date" //NSDate
#define GENDER @"user_gender" //NSString
#define USER_DISPLAY_NAME @"user_display_name" //NSString
#define OCCUPATION @"user_occupation"
#define PERSONALDETAIL @"user_description"
#define UID @"user_unique_id"
#define UKEY @"user_unique_request_key"
#define YOUTU_SIGNATURE @"tencent_Youtu_Signature"
#define CURRENT_CIRCLE_ID @"current_circle_identifier"
#define LOGIN_TYPE @"user_login_type"
#define IS_SUPERUSER @"is_user_aSuperUser"

@interface User : NSObject

+ (void)updateAttributeFromDictionary:(NSDictionary *)info;
+ (void)updateOwnerInfo:(NSDictionary *)info;
+ (NSDictionary *)getOwnerInfo;

+ (NSString *)openID;
+ (NSString *)accessToken;
+ (NSString *)uid;
+ (NSString *)uKey;
+ (BOOL)isUserLogin;
+ (NSURL *)userProfilePictureURL;
+ (NSString *)userDisplayName;
+ (NSString *)gender;
+ (NSString *)updatedProfilePictureId;
+ (NSString *)occupation;
+ (NSString *)personalDetailInfo;
+ (NSString *)youtuSignature;
+ (NSString *)loginType;
+ (void)storeSignature:(NSString *)sign;
+ (NSString *)currentCircleId;

+ (BOOL)isSuperUser;
@end
