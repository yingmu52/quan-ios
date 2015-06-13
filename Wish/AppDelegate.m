//
//  AppDelegate.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AppDelegate.h"
#import "ECSlidingViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "User.h"
#import "LoginViewController.h"
#import "FetchCenter.h"
@interface AppDelegate () <FetchCenterDelegate>
@property (nonatomic,strong) NSTimer *messageNotificationTimer;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (strong, nonatomic) NSNumber *messageCount;
@property (strong, nonatomic) NSNumber *followCount;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([User isUserLogin]){
        ECSlidingViewController *root = (ECSlidingViewController *)self.window.rootViewController;
        root.anchorRightPeekAmount = root.view.frame.size.width * (640 - 290.0)/640;
        root.underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
        [self.messageNotificationTimer fire];
    }else{
        UIStoryboard *storyBoard = self.window.rootViewController.storyboard;
        LoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        self.window.rootViewController = loginVC;
        [self.window makeKeyAndVisible];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.messageNotificationTimer = nil; //set to nil instead of invalidate
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.messageNotificationTimer invalidate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.messageNotificationTimer fire];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    self.messageNotificationTimer = nil;
}

#pragma mark - Tencent
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
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
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (NSManagedObjectContext *)getContext
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.managedObjectContext;
}


#pragma mark - Message Notification

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (NSTimer *)messageNotificationTimer{
    if (!_messageNotificationTimer) {
        _messageNotificationTimer  = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(requestMessageCount) userInfo:nil repeats:YES];
    }
    return _messageNotificationTimer;
}
- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    //do nothing
}

- (void)didFinishGettingMessageNotificationWithMessageCount:(NSNumber *)msgCount followCount:(NSNumber *)followCount{
    self.messageCount = msgCount;
    self.followCount = followCount;
    NSLog(@"message count %@, follow count %@",msgCount,followCount);
    self.numberOfMessages = @(msgCount.integerValue + followCount.integerValue);
}

- (NSNumber *)messageCount{
    if (!_messageCount) {
        _messageCount = @(0);
    }
    return _messageCount;
}

- (NSNumber *)followCount{
    if (!_followCount) {
        _followCount = @(0);
    }
    return _followCount;
}

- (void)requestMessageCount{
    if ([User isUserLogin]) {
        [self.fetchCenter getMessageNotificationInfo];
    }else{
        [self.messageNotificationTimer invalidate];
    }
}
@end




