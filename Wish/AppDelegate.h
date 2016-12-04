//
//  AppDelegate.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "WXApi.h"
#import "MainTabBarController.h"
#import "LoginViewController.h"
#import "FetchCenter.h"
#import "WXApiManager.h"
#import "CWStatusBarNotification.h"

//#import <PgySDK/PgyManager.h>
#import <TencentOpenAPI/QQApiInterface.h>
//#import <spider/SPIntrospect.h>
#define NSLog if(1) NSLog

#define YOUTU_APP_ID @"10003267"
#define WECHATAppID @"wxf4957fc61a006431"
#define QQAppID @"1104337894"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) CWStatusBarNotification *statusBarNotification;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** 保存异线的MOC */
- (void)saveContext:(NSManagedObjectContext *)context;
- (void)saveMainContext;
- (NSURL *)applicationDocumentsDirectory;
+ (NSManagedObjectContext *)getContext;
+ (void)postStatusBarAlert:(NSString *)message;

+ (void)showMainTabbar;
+ (void)clearCoreData:(BOOL)shouldGoBackToTabBar;
+ (void)logout;

@end

