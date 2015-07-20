//
//  DiscoveryVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-30.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryVCData.h"
#import "FetchCenter.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
#import "WishDetailVCFollower.h"
#import "UIViewController+ECSlidingViewController.h"
@interface DiscoveryVCData () <FetchCenterDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) FetchCenter *fetchCenter;
//@property (nonatomic,strong) NSMutableArray *plans;
@property (nonatomic,strong) NSMutableArray *itemChanges;
@property (nonatomic,strong) NSBlockOperation *blockOperation;
@end

@implementation DiscoveryVCData

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fetchCenter getDiscoveryList];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)addWish{
    [self performSegueWithIdentifier:@"showPostViewFromDiscovery" sender:nil];
}

- (void)dealloc{
//    [self removePlans];
}

- (void)removePlans{
//    dispatch_queue_t queue_cleanUp;
//    queue_cleanUp = dispatch_queue_create("com.stories.DiscoveryVCData.cleanup", NULL);
//    dispatch_async(queue_cleanUp, ^{
        NSUInteger numberOfPreservingPlans = 0;
        NSArray *allPlans = self.fetchedRC.fetchedObjects;
        if (allPlans.count > numberOfPreservingPlans) {
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            for (NSInteger i = numberOfPreservingPlans ;i < self.fetchedRC.fetchedObjects.count; i ++){
                Plan *plan = self.fetchedRC.fetchedObjects[i];
                if ([plan isDeletable]){
                    NSLog(@"Discovery: removing plan %@",plan.planId);
                    [delegate.managedObjectContext deleteObject:plan];
                }
            }
            [delegate saveContext];
        }
//    });

}

#pragma mark - collection view delegate & data soucce

- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    [cell.discoveryImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:plan.backgroundNum]];
    cell.discoveryTitleLabel.text = plan.planTitle;
    cell.discoveryByUserLabel.text = [NSString stringWithFormat:@"by %@",plan.owner.ownerName];
    cell.discoveryFollowerCountLabel.text = [NSString stringWithFormat:@"%@ 关注",plan.followCount];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}

#pragma mark - fetch center delegate


- (void)didfinishFetchingDiscovery:(NSArray *)plans{
//    [self.plans addObjectsFromArray:plans];
//    [self.collectionView reloadData];
//    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)handleFailure:(NSDictionary *)info{
//    self.navigationItem.rightBarButtonItem = nil;
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // save the plan image background only when user select a certain plan!
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if (!plan.image){
        DiscoveryCell *cell = (DiscoveryCell *)[collectionView cellForItemAtIndexPath:indexPath];
        plan.image = cell.discoveryImageView.image;
    }
    
    if ([plan.owner.ownerId isEqualToString:[User uid]] && ![plan.planStatus isEqualToNumber:@(PlanStatusFinished)]){ //已完成的事件不支持编辑
        [self performSegueWithIdentifier:@"showWishDetailVCOwnerFromDiscovery" sender:plan];
    }else{
        [self performSegueWithIdentifier:@"showDiscoveryWishDetail" sender:plan];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Plan *)plan{
    if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"] || [segue.identifier isEqualToString:@"showWishDetailVCOwnerFromDiscovery"]){
        [segue.destinationViewController setPlan:plan];
    }
}

#pragma mark - fetched results controller delegate
- (NSFetchedResultsController *)fetchedRC
{
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }else{
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        //        request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId != %@ && isFollowed == %@",[User uid],@(YES)];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
        [request setFetchBatchSize:3];
        //create FetchedResultsController with context, sectionNameKeyPath, and you can cache here, so the next work if the same you can use your cashe file.
        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:[AppDelegate getContext]
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        _fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        [_fetchedRC performFetch:nil];
        return _fetchedRC;
    }
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
////    self.blockOperation = [NSBlockOperation new];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    __weak UICollectionView *collectionView = self.collectionView;
//    switch (type) {
//        case NSFetchedResultsChangeInsert: {
//            [self.blockOperation addExecutionBlock:^{
//                [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//            }];
//            break;
//        }
//            
//        case NSFetchedResultsChangeDelete: {
//            [self.blockOperation addExecutionBlock:^{
//                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
//            }];
//            break;
//        }
//            
//        case NSFetchedResultsChangeUpdate: {
//            [self.blockOperation addExecutionBlock:^{
//                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            }];
//            break;
//        }            
//        default:
//            break;
//    }
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    [self.collectionView performBatchUpdates:^{
//        [self.blockOperation start];
//    } completion:^(BOOL finished) {
//        // Do whatever
//    }];
    [self.collectionView reloadData];
}


@end



