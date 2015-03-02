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
@interface FollowingTVCData () <NSFetchedResultsControllerDelegate,FetchCenterDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;

@end

@implementation FollowingTVCData

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.tableFooterView.hidden = YES;
    
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    NSArray *array = [Plan fetchWith:@"Plan" predicate:nil keyForDescriptor:@"createDate"];
//    for (Feed*feed in array) {
//        NSLog(@"%@\n",feed);
//        [delegate.managedObjectContext deleteObject:feed];
//    }
//    [delegate.managedObjectContext save:nil];
    
    FetchCenter *fetchCenter =[[FetchCenter alloc] init];
    fetchCenter.delegate  = self;
    [fetchCenter performSelectorInBackground:@selector(fetchFollowingPlanList:)
                                  withObject:@[@"100004"]];
}

- (void)didFinishFetchingFollowingPlanList{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedRC.fetchedObjects.count;;
}

- (void)configureFollowingCell:(FollowingCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    Feed *feed = [plan fetchLastUpdatedFeed];
//    NSLog(@"%@",plan.feeds );
    cell.bottomLabel.text = feed.feedTitle;
    cell.headTitleLabel.text = plan.planTitle;
    cell.headDateLabel.text = [SystemUtil stringFromDate:plan.updateDate];
    cell.plan = plan; // must set 
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
        request.predicate = [NSPredicate predicateWithFormat:@"ownerId != %@",[SystemUtil getOwnerId]];
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

- (void)controllerWillChangeContent:
(NSFetchedResultsController *)controller
{
//    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
//    [self.tableView reloadData];
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
//             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
//             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
//                                  withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            // dont't support move action
//            break;
//    }
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
//    [self.tableView endUpdates];
    [self.tableView reloadData];
}


@end
