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
#define PGY_APPID @"66e5b274501bae9aed70ab7aeea5a7a6"
#import "LoginViewController.h"
#import "MessageListViewController.h"
#import "MBProgressHUD.h"
#import "CWStatusBarNotification.h"
#import "MainTabBarController.h"
#import "MessageListViewController.h"
#import <PgySDK/PgyManager.h>
#import "MSRocketStation.h"
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
//    [pgYmanager setShakingThreshold:4.0];

    
    //如果用户未登陆，跳转到登陆页
    if (![User isUserLogin]){
        self.window.rootViewController = self.loginVC;
    }else{
        [AppDelegate registerForDeviceToken];
        
    }
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
//    [[MSRocketStation sharedStation] launchRocket];
}

#pragma mark - Push Notification

+ (void)registerForDeviceToken{
    UIApplication *application = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
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
    UIApplicationState currentState = [[UIApplication sharedApplication] applicationState];
    if (currentState == UIApplicationStateActive) {
        NSString *message = [userInfo valueForKeyPath:@"aps.alert"];
        if (message) { //不为null的情况才作提示，
            CWStatusBarNotification *cbn = [CWStatusBarNotification new];
            cbn.notificationLabelBackgroundColor = [Theme globleColor];
            cbn.notificationAnimationInStyle = CWNotificationAnimationStyleLeft;
            cbn.notificationAnimationOutStyle = CWNotificationAnimationStyleRight;
            cbn.notificationStyle = CWNotificationStyleStatusBarNotification;
            [cbn displayNotificationWithMessage:message
                                    forDuration:2.0];
        }
     }else{
        //切换到消息
        [self selectMainTabbarAtIndex:3];
     }

    [self.fetchCenter getMessageNotificationInfo:^(NSNumber *messageCount, NSNumber *followCount) {
        NSUInteger msgIndex = 3;
        MainTabBarController *mtbc = (MainTabBarController *)self.window.rootViewController;
        UITabBarItem *messageTab = [mtbc.tabBar.items objectAtIndex:msgIndex];
        messageTab.badgeValue = messageCount.integerValue > 0 ? [NSString stringWithFormat:@"%@",messageCount] : nil;
        
        UINavigationController *nc = [mtbc.viewControllers objectAtIndex:msgIndex];
        MessageListViewController *mlvc = nc.viewControllers.firstObject;
        [mlvc loadNewData];
        
    }];
}

+ (MainTabBarController *)getMainTabbarController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarController *mtbc = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    return mtbc;
}

-(void)selectMainTabbarAtIndex:(NSUInteger)index{
    MainTabBarController *tbc = [AppDelegate getMainTabbarController];
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:tbc];
    [tbc setSelectedIndex:index];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    //remote registration failed
    NSLog(@"Failed To Register, error : %@",error);
}

#pragma mark - Other Application Events

- (void)applicationWillTerminate:(UIApplication *)application {
    //Close Spider If Necessary
    if ([[SPIntrospect sharedIntrospector] isOpen]) {
        [[SPIntrospect sharedIntrospector] closeSpider];
    }
}

#pragma mark - Tencent & Wechat

- (LoginViewController *)loginVC{
    if (!_loginVC) {
        _loginVC = [LoginViewController initLoginViewController];
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
            [self selectMainTabbarAtIndex:1];
            
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
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wish" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wish.sqlite"];
        NSError *error = nil;
        NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                                  NSInferMappingModelAutomaticallyOption:@(YES)};
//                                  NSIgnorePersistentStoreVersioningOption:@(YES)};
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:options
                                                               error:&error])
        {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext{
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = [self writerManagedObjectContext];

    }
    return _managedObjectContext;
}

// Parent context
- (NSManagedObjectContext *)writerManagedObjectContext{
    if (!_writerManagedObjectContext) {
        _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_writerManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _writerManagedObjectContext;
}


#pragma mark - Core Data Saving support

- (void)saveContext:(NSManagedObjectContext *)context{
    // Save the context.
    NSAssert(![NSThread isMainThread], @"This method should always be called on background thread");
    NSError *error = nil;
    if (context.hasChanges &&
        ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }else{
        [self saveMainContext];
    }
}

- (void)saveMainContext{
    [self.managedObjectContext performBlock:^{
        NSError *error = nil;
        if ([self.managedObjectContext hasChanges] &&
            ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @try {
                    // Save the context.
                    NSError *error = nil;
                    if (self.writerManagedObjectContext.hasChanges &&
                        ![self.writerManagedObjectContext save:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    }else{
                        NSLog(@"Stored Data on %@ Thread \n\n\n",[NSThread isMainThread] ? @"Main" : @"Background");
                    }
                } @catch (NSException *exception) {
                    [self resetDataStore];
                }
            });
        }
    }]; // main
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
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _writerManagedObjectContext = nil;
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



#pragma mark - 登出操作

+ (void)logout{
    //delete user info, this lines must be below [self clearCoreData];
    [User updateOwnerInfo:[NSDictionary dictionary]];
    
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[LoginViewController initLoginViewController]];
}

+ (void)clearCoreData:(BOOL)shouldGoBackToTabBar{
    //see Updated Solution for iOS 9+ in http://stackoverflow.com/questions/1077810/delete-reset-all-entries-in-core-data
    //删除本地数据库
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //1
        [NSUserDefaults resetStandardUserDefaults];
        
        //2. 删除所有Core Data数据
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        //Each thread needs to have its own moc
        NSManagedObjectContext *backgroundMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        backgroundMoc.parentContext = delegate.managedObjectContext;
        
        for (NSEntityDescription *entity in delegate.managedObjectModel.entities) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entity.name];
            [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSError *error;
            NSArray *fetchedObjects = [backgroundMoc executeFetchRequest:fetchRequest error:&error];
            for (NSManagedObject *object in fetchedObjects)
            {
                [backgroundMoc deleteObject:object];
            }
        }
        
        //3
        [delegate saveContext:backgroundMoc];
        if (shouldGoBackToTabBar) {
            dispatch_main_async_safe(^{
                //切换到主页
                [AppDelegate showMainTabbar];
            });
        }
    });
    
}


+ (void)showMainTabbar{
    //show Main View
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[AppDelegate getMainTabbarController]];
    [AppDelegate registerForDeviceToken];
}
@end




