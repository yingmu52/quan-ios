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

@interface FollowingTVCData () <NSFetchedResultsControllerDelegate,FetchCenterDelegate,FollowingCellDelegate,ECSlidingViewControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@end

@implementation FollowingTVCData


- (void)viewDidLoad {
    [super viewDidLoad];
    FetchCenter *fetchCenter =[[FetchCenter alloc] init];
    fetchCenter.delegate  = self;
    [fetchCenter fetchFollowingPlanList];
//    dispatch_queue_t fetchFollowingListQ = dispatch_queue_create("fetchFollowingListQ", NULL);
//    dispatch_async(fetchFollowingListQ, ^{
//    });
}

- (void)didFinishFetchingFollowingPlanList{
    [self.tableView reloadData];
}

#pragma mark - segue

- (void)didPressMoreButtonForCell:(FollowingCell *)cell{
    [self performSegueWithIdentifier:@"showFollowerWishDetail" sender:cell];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(FollowingCell *)sender{
    if ([segue.identifier isEqualToString:@"showFollowerWishDetail"]) {
        [segue.destinationViewController setPlan:sender.plan];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedRC.fetchedObjects.count;;
}

- (void)configureFollowingCell:(FollowingCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
//    Feed *feed = [plan fetchLastUpdatedFeed];
    Feed *feed = [[plan.feeds allObjects] firstObject];
    //update Plan Info
    cell.bottomLabel.text = feed ? feed.feedTitle : @"无标题";
    cell.headTitleLabel.text = plan.planTitle;
    cell.headDateLabel.text = [NSString stringWithFormat:@"更新于 %@",[SystemUtil stringFromDate:plan.updateDate]];
    cell.plan = plan; // must set
    cell.delegate = self;
    
    //update User Info
    cell.headUserNameLabel.text = plan.owner.ownerName;
    [cell.headProfilePic sd_setImageWithURL:[[FetchCenter new] urlWithImageID:plan.owner.headUrl]
                           placeholderImage:[Theme menuLoginDefault]];
    
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
        request.predicate = [NSPredicate predicateWithFormat:@"ownerId != %@ && isFollowed == %@",[User uid],@(YES)];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
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


- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
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
