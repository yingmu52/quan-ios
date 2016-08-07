//
//  AppDelegate.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AppDelegate.h"
#define BUGLY_APP_ID @"900007998"
#define QQ_URLSCHEME @"tencent1104337894"
#define PGY_APPID @"7f1cd492fc0f48875650e0d1c702093b"
#import "LoginViewController.h"
#import "MessageListViewController.h"
#import "MBProgressHUD.h"
@interface AppDelegate () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) LoginViewController *loginVC;
@end

@implementation AppDelegate
@synthesize writerManagedObjectContext = _writerManagedObjectContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //向后台拉取优图签名
    [self.fetchCenter requestSignature:nil];
    
    //向微信注册
    [WXApi registerApp:WECHATAppID];
    
    //薄公英启动基本SDK
    PgyManager *pgYmanager = [PgyManager sharedPgyManager];
    [pgYmanager startManagerWithAppId:PGY_APPID];
    [pgYmanager setEnableFeedback:NO];
//    [pgYmanager setFeedbackActiveType:kPGYFeedbackActiveTypeShake];
//    [pgYmanager setShakingThreshold:3.0]; //摇一摇触发反馈


    if (![User isUserLogin]){
        self.window.rootViewController = self.loginVC;
    }
    
    //register for push notification
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings{
    
    //only register remote notification when permission is granted
    if (notificationSettings != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    //remote registration successed
    NSString *strToken = [deviceToken.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    strToken = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    //Save Device Token
    [User updateAttributeFromDictionary:@{DEVICE_TOKEN:strToken}];
    
    //向后台发送Device Token
    if ([User isUserLogin]) {
        [self.fetchCenter sendDeviceToken:strToken completion:nil];
    } // else go to login 
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo{
    
//    UIApplicationState currentState = [[UIApplication sharedApplication] applicationState];
//    if (currentState == UIApplicationStateBackground | currentState == UIApplicationStateInactive) {
//        //切换到主页
//        UITabBarController *tbc = [self.loginVC.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
//        [[[UIApplication sharedApplication] keyWindow] setRootViewController:tbc];
//
//        [tbc setSelectedIndex:3]; //选择消息页
//        NSString *feedId = [userInfo valueForKeyPath:@"info.info_id"];
//        UINavigationController *nv = tbc.selectedViewController;
//        MessageListViewController *mlvc = nv.viewControllers.firstObject;
//        [mlvc performSegueWithIdentifier:@"showFeedDetailFromMessage" sender:feedId];
//    }

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    //remote registration failed
    NSLog(@"Failed To Register, error : %@",error);
}

#pragma mark - Other Application Events

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Tencent & Wechat

- (LoginViewController *)loginVC{
    if (!_loginVC) {
        _loginVC = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
    return _loginVC;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation{
    
    return
    [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]] |
    [TencentOAuth HandleOpenURL:url] |
    [QQApiInterface handleOpenURL:url delegate:nil] |
    [self handleJoingCircleURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return
    [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]] ||
    [TencentOAuth HandleOpenURL:url] || 
    [QQApiInterface handleOpenURL:url delegate:nil];
}


- (BOOL)handleJoingCircleURL:(NSURL *)url{
    
    //读取邀请圈子H5带进来的参数
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [args setObject:value forKey:key];
    }
    
    BOOL handleSucceed = NO;
    NSArray *validArgs = @[@"quanid",@"noncestr",@"signature",@"expiretime",@"invitecode"];
    for (NSString *str in args.allKeys) {
        handleSucceed = [validArgs containsObject:str];
    }
    if (handleSucceed) {
        NSLog(@"邀请加入操作成功");
        //102的错误码是时间过期，103的错误码是签名失败
        [self.fetchCenter joinCircleId:args[@"quanid"]
                           nonceString:args[@"noncestr"]
                             signature:args[@"signature"]
                            expireTime:args[@"expiretime"]
                            inviteCode:args[@"invitecode"]
                            completion:^(NSString *circleName)
        {
            //切换到圈子页
            UITabBarController *tbc = [self.loginVC.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
            [[[UIApplication sharedApplication] keyWindow] setRootViewController:tbc];
            [tbc setSelectedIndex:1];

            
            //提示加入成功
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                                                      animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = [NSString stringWithFormat:@"成功加入圈子【%@】",circleName];
            [hud hideAnimated:YES afterDelay:2.0];
        }];
    }
    
    return handleSucceed;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "lift.countdown.xinyi.Wish" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wish" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wish.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                              NSInferMappingModelAutomaticallyOption:@(YES)};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.parentContext = [self writerManagedObjectContext];
    
    return _managedObjectContext;
}

// Parent context
- (NSManagedObjectContext *)writerManagedObjectContext{
    if (!_writerManagedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_writerManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _writerManagedObjectContext;
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    
    if (!self.managedObjectContext) {
        NSError *error = nil;
        if ([self.managedObjectContext hasChanges] &&
            ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }else{
            [self.writerManagedObjectContext performBlockAndWait:^{
                // Save the context.
                NSError *error = nil;
                if (self.writerManagedObjectContext.hasChanges &&
                    ![self.writerManagedObjectContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }]; // writer
        }
        
    }
}

- (void)saveContext:(NSManagedObjectContext *)context{
    // Save the context.
    [context performBlockAndWait:^{
        NSError *error = nil;
        if (context.hasChanges &&
            ![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }else{
            [self.managedObjectContext performBlockAndWait:^{
                [self saveContext];
            }]; // main
            
        }
    }];
    
}


- (void)resetDataStore{
    //data model 有变化，删除重建以避免闪退。如果有保留用户数据的需求，应该使用data migration
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wish" withExtension:@"momd"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wish.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:modelURL.path]) {
        NSLog(@"Deleting Data Model ...");
        [fileManager removeItemAtURL:modelURL error:nil];
    }
    
    if ([fileManager fileExistsAtPath:storeURL.path]) {
        NSLog(@"Deleting Store URL ...");
        [fileManager removeItemAtURL:storeURL error:nil];
    }
}


+ (NSManagedObjectContext *)getContext
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.managedObjectContext;
}

#pragma mark - Fetch Center Delegate

- (void)didfinishGettingSignature{
    //the delegate only gets call when signature returns successfully
    //上传需要注册appId，应用级sign，userId根据用户需要选填
//    [TXYUploadManager authorize:YOUTU_APP_ID userId:nil sign:[User youtuSignature]];
    //下载需要注册appId，sign信息由用户填入url参数中
//    [TXYDownloader authorize:YOUTU_APP_ID userId:nil];
    //    NSLog(@"***************************************\n\n%@\n\n",[User youtuSignature]);]
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}
@end




