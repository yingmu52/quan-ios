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

//user dictionary keys
#define OWNERINFO @"motherfucking_user_fucking_in_fucking_fo" //key for user info
#define ACCESS_TOKEN @"access_token_string" //NSString
#define OPENID @"user_open_id" //NSString
#define PROFILE_PICTURE_URL @"user_profile_url" //NSString
#define EXPIRATION_DATE @"login_expiraiton_date" //NSDate
#define GENDER @"user_gender" //NSString
#define USER_DISPLAY_NAME @"user_display_name" //NSString
#define LOGIN_STATUS @"user_login_status" //BOOL

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (BOOL)hasActiveInternetConnection;
+ (UIImagePickerController *)showCamera:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate;
+ (UIImage *)darkLayeredImage:(UIImage *)image inRect:(CGRect)bounds;

+ (void)setupShawdowForView:(UIView *)view;


+ (NSString *)getOwnerId;
+ (void)updateOwnerInfo:(NSDictionary *)info;

+ (BOOL)isUserLogin;
+ (NSURL *)userProfilePictureURL;
+ (NSString *)userDisplayName;

@end
