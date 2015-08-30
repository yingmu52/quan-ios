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
#define YOUTU_APP_ID @"10003267"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (NSManagedObjectContext *)getContext;
@end

