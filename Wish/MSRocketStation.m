//
//  MSRocketStation.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/5/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSRocketStation.h"
#import "Task+CoreDataClass.h"
#import "FetchCenter.h"
@import Photos;
@interface MSRocketStation () <FetchCenterDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) AppDelegate *appDelegate;
@end

@implementation MSRocketStation


+ (instancetype)sharedStation {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}


//- (void)launchRocket{
//    NSPredicate *p =[NSPredicate predicateWithFormat:@"isFinished != %@",@(YES)];
//    NSArray *tasks = [Task fetchWithPredicate:p inManagedObjectContext:[AppDelegate getContext]];
//    for (Task *task in tasks) {
//        [self sendTask:task];
//    }
//}


- (void)addNewTaskWithFeedTitle:(NSString *)title
                         planId:(NSString *)planId
                  localImageIDs:(NSArray *)localImageIds{
    Task *task = [Task insertTaskWithFeedTitle:title
                                        planID:planId
                                  locaImageIDs:localImageIds
                        inManagedObjectContext:self.appDelegate.managedObjectContext];
    [self.appDelegate saveMainContext];
    [self sendTask:task];
}
- (void)sendTask:(Task *)task{
    
    NSLog(@"正在发送片段标题《%@》",task.mTitle);
    PHImageManager *manager = [PHImageManager defaultManager];
    
    //Decode Image
    NSArray *localImageIDs = [task localIDs];
    NSMutableArray *arrayOfUIImages = [NSMutableArray arrayWithCapacity:localImageIDs.count];
    
    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:localImageIDs options:nil];
    [results enumerateObjectsUsingBlock:^(PHAsset  * _Nonnull asset,
                                          NSUInteger idx,
                                          BOOL * _Nonnull stop)
     {
         [manager requestImageDataForAsset:asset
                                   options:nil
                             resultHandler:^(NSData * _Nullable imageData,
                                             NSString * _Nullable dataUTI,
                                             UIImageOrientation orientation,
                                             NSDictionary * _Nullable info)
          {
              [arrayOfUIImages addObject:[UIImage imageWithData:imageData scale:0.5]];
              if (arrayOfUIImages.count == localImageIDs.count){
                  //Upload image
                  [self.fetchCenter uploadImages:arrayOfUIImages progress:^(CGFloat progress) {
                      task.progress = @(progress);
                  } completion:^(NSArray *imageIds) {
                      //create feed
                      [self.fetchCenter createFeed:task.mTitle
                                            planId:task.planID
                                   fetchedImageIds:imageIds
                                        completion:^(NSString *feedId){
                           //delete task
                           task.isFinished = @(YES);
                           [self.appDelegate saveMainContext];
                           NSLog(@"已完成任务 %@",feedId);
                       }];
                  }];
              }
          }];
         
     }];

}

- (void)removeAllFinishedTasks{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        //1. fetch all tasks
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *workContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workContext.parentContext = delegate.managedObjectContext;
        
        NSArray *tasks = [Task fetchWithPredicate:[NSPredicate predicateWithFormat:@"isFinished == %@",@(YES)] inManagedObjectContext:workContext];
        
        for (Task *task in tasks) {
            [workContext deleteObject:task];
        }
        [delegate saveContext:workContext];
    });
}


@end
