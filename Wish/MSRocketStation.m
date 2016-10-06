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
@property (nonatomic,strong) NSFetchedResultsController *taskFRC;
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
        //
    }
    return self;
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (NSFetchedResultsController *)taskFRC{
    if (!_taskFRC) {
        //fetch all tasks
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mCreateTime" ascending:NO]];
        _taskFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:[AppDelegate getContext]
                                                         sectionNameKeyPath:nil
                                                                  cacheName:nil];
        _taskFRC.delegate = self;
        NSError *error;
        [_taskFRC performFetch:&error];
    }
    return _taskFRC;
}

- (void)startDigestingTasks{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        
        //1. fetch all tasks
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *workContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workContext.parentContext = delegate.managedObjectContext;
        
        //fetch all unfinished tasks sorted by mCreateTime (FIFO)
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFinished == %@",@(NO)];
        NSArray *allTasks = [Task fetchWithPredicate:predicate
                                             WithKey:@"mCreateTime"
                              inManagedObjectContext:workContext];
        NSLog(@"已检测到%@个待发送的片段",@(allTasks.count));
        PHImageManager *manager = [PHImageManager defaultManager];
        
        //2. enumerate tasks
        for (Task *task in allTasks) {
            
            //3. Decode Image
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
                         
                         //4. Upload image
                         NSLog(@"正在发送...(%@/%@)",@([allTasks indexOfObject:task] + 1),@(allTasks.count));
                         [self.fetchCenter uploadImages:arrayOfUIImages completion:^(NSArray *imageIds)
                         {
                             //5. create feed
                             [self.fetchCenter createFeed:task.mTitle
                                                   planId:task.planID
                                          fetchedImageIds:imageIds
                                               completion:^(NSString *feedId)
                             {
                                 
                                 [workContext performBlock:^{
                                     //6. delete task
                                     task.isFinished = @(YES);
                                     NSLog(@"已完成任务%@",task.mUID);
                                 }];
                                 
                             }];
                             
                         }];
                     }
                 }];

            }];
        }
    
    
    });

}




@end
