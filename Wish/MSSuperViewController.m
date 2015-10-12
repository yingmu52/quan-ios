//
//  MSSuperViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"

@interface MSSuperViewController ()
@end

@implementation MSSuperViewController


#pragma mark - 控制器生活周期 Application Life Cycle

#pragma mark - 网络通讯&后台调联 Fetch Center

-(FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

#pragma mark - Table View

// MARK: Table View Delegate and Data Source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return self.tableFetchedRC.sections.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (self.tableFetchedRC.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.tableFetchedRC sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    return rows;
}

// MARK: Table View Fetched Results Controller

- (NSFetchedResultsController *)tableFetchedRC{
    if (!_tableFetchedRC){
        NSAssert(self.tableFetchRequest, @"NULL tableFetchRequest");
        _tableFetchedRC = [[NSFetchedResultsController alloc] initWithFetchRequest:self.tableFetchRequest
                                                              managedObjectContext:[AppDelegate getContext]
                                                                sectionNameKeyPath:nil
                                                                         cacheName:nil];
        _tableFetchedRC.delegate = self;
        NSError *error;
        [_tableFetchedRC performFetch:&error];
        
    }
    return _tableFetchedRC;
}


// MARK: tableFetchedRC Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.tableFetchedRC) {
        [self.tableView beginUpdates];
    }
}

//- (void)controller:(NSFetchedResultsController *)controller
//  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex
//     forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        default:
//            break;
//    }
//}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (controller == self.tableFetchedRC) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }

    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.tableFetchedRC) {
        [self.tableView endUpdates];
    }
}

@end





