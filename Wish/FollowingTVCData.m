//
//  FollowingTVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingTVCData.h"
@import CoreData;
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "Plan.h"
#import "UIViewController+ECSlidingViewController.h"
#import "UIImageView+WebCache.h"
#import "Theme.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "ProfileViewController.h"
#import "WishDetailVCFollower.h"
static NSUInteger numberOfPreloadedFeeds = 3;

@interface FollowingTVCData () <NSFetchedResultsControllerDelegate,FetchCenterDelegate,FollowingCellDelegate,ECSlidingViewControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSMutableArray *serverPlanList;
@end

@implementation FollowingTVCData

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fetchCenter fetchFollowingPlanList];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)dealloc{
    NSUInteger numberOfPreservingFeeds = 20;
    NSArray *plans = self.fetchedRC.fetchedObjects;
    if (plans.count > numberOfPreservingFeeds) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        for (NSUInteger i = numberOfPreservingFeeds; i < plans.count; i++) {
            [delegate.managedObjectContext deleteObject:plans[i]];
        }
        [delegate saveContext];
    }
}

- (void)didFinishFetchingFollowingPlanList:(NSArray *)planIds{
    
    [self.serverPlanList addObjectsFromArray:planIds];
    
    //delete feed from local if it does not appear to be ien the server side feed list
#warning bug : if following plans count is 0 -> self.serverPlanlist = @[] -> no comparasion will occur ~
    if (self.serverPlanList.count > 0 && self.fetchedRC.fetchedObjects.count > 0){
        dispatch_queue_t syncQueue = dispatch_queue_create("com.stories.FollowingTVCData.syncFollowingPlanList", NULL);
        dispatch_async(syncQueue, ^{
            for (Plan *plan in self.fetchedRC.fetchedObjects){
                if (![self.serverPlanList containsObject:plan.planId]) {
                    NSLog(@"sync following plan list");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [plan.managedObjectContext deleteObject:plan];
                    });
                    
                }
            }
        });
    }
    
}

- (NSMutableArray *)serverPlanList{
    if (!_serverPlanList){
        _serverPlanList = [NSMutableArray array];
    }
    return _serverPlanList;
}

#pragma mark - segue

- (void)didPressMoreButtonForCell:(FollowingCell *)cell{
    Plan *plan = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:@"showFollowerWishDetail" sender:plan];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFollowerWishDetail"]) {
        if ([sender isKindOfClass:[NSArray class]]){
            NSArray *array = (NSArray *)sender;
            WishDetailVCFollower *wishDetailVC = segue.destinationViewController;
            wishDetailVC.plan = array.firstObject; // refer: didPressCollectionCellAtIndex
            [wishDetailVC.tableView scrollToRowAtIndexPath:array.lastObject
                                          atScrollPosition:UITableViewScrollPositionMiddle
                                                  animated:NO];

        }else{
            [segue.destinationViewController setPlan:sender];
        }

    }
    if ([segue.identifier isEqualToString:@"showPersonalInfo"]) {
        [segue.destinationViewController setOwner:sender];
    }
}

- (void)didTapOnProfilePicture:(FollowingCell *)cell{
    Plan *plan = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:@"showPersonalInfo" sender:plan.owner];
}

- (void)didPressCollectionCellAtIndex:(NSIndexPath *)indexPath forCell:(FollowingCell *)cell{
    Plan *plan = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:@"showFollowerWishDetail" sender:@[plan,indexPath]];
}
#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedRC.fetchedObjects.count;;
}

- (void)configureFollowingCell:(FollowingCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    
    //update Plan Info
    cell.headTitleLabel.text = plan.planTitle;
    cell.headDateLabel.text = [NSString stringWithFormat:@"更新于 %@",[SystemUtil stringFromDate:plan.updateDate]];
    cell.delegate = self;
    
    //fetch feeds array
    NSArray *sortedArray = [plan.feeds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]]];
    cell.feedsArray =  [sortedArray subarrayWithRange:NSMakeRange(0, numberOfPreloadedFeeds)];
    
    //update User Info
    cell.headUserNameLabel.text = plan.owner.ownerName;

    [cell.headProfilePic setCircularImageWithURL:[self.fetchCenter urlWithImageID:plan.owner.headUrl]
                                        forState:UIControlStateNormal];

}
#pragma mark - Fetched Results Controller Delegate

- (NSFetchedResultsController *)fetchedRC
{
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }else{
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;

        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId != %@ && isFollowed == %@",[User uid],@(YES)];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
        [request setFetchBatchSize:3];
        //create FetchedResultsController with context, sectionNameKeyPath, and you can cache here, so the next work if the same you can use your cashe file.
        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:context sectionNameKeyPath:nil
                                                       cacheName:nil];
        _fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        [_fetchedRC performFetch:nil];
        return _fetchedRC;
    }
}


- (void)controllerWillChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type){
            
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"Followed Plan inserted");
        }
            break;
            
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"Followed Plan deleted");
        }
            break;
            
        case NSFetchedResultsChangeUpdate:{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"Followed Plan updated");
        }
            break;
            
        default:
            break;
    }
}


- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - go to discovery 

- (IBAction)goToDiscovery:(UITapGestureRecognizer *)tap{
    self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerForDiscovery"];
    
}

#pragma mark - fetch center delegate

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    NSLog(@"fail");

}
@end
