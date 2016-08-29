//
//  MSSuperViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"
#import "MBProgressHUD.h"
@interface MSSuperViewController ()
@property (nonatomic,strong) NSMutableArray *itemChanges;
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

- (AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

#pragma mark - 网络失败情况的处理

- (void)didFailToReachInternet{
    [self stopRefreshingWidget];
}

- (void)didFailSendingRequest{
    [self stopRefreshingWidget];
}

- (void)stopRefreshingWidget{
    if (self.tableView) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
    }
    if (self.collectionView) {
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
    }
}

#pragma mark - Delegates and Data Sources


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableFetchedRC.fetchedObjects.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionFetchedRC.fetchedObjects.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// MARK: Table View Fetched Results Controller

- (NSFetchedResultsController *)tableFetchedRC{
    if (!_tableFetchedRC && self.tableFetchRequest){
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

- (NSFetchedResultsController *)collectionFetchedRC{
    if (!_collectionFetchedRC && self.collectionFetchRequest) {
        _collectionFetchedRC = [[NSFetchedResultsController alloc] initWithFetchRequest:self.collectionFetchRequest
                                                                   managedObjectContext:[AppDelegate getContext]
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
        _collectionFetchedRC.delegate = self;
        NSError *error;
        [_collectionFetchedRC performFetch:&error];
    }
    return _collectionFetchedRC;
}

// MARK: tableFetchedRC Delegate

/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"controllerWillChangeContent");
    if (controller == self.tableFetchedRC) {
        [self.tableView beginUpdates];
    }
    
    if (controller == self.collectionFetchedRC) {
        self.itemChanges = [[NSMutableArray alloc] init];
    }

}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"didChangeObject");
    if (controller == self.tableFetchedRC) {
        UITableView *tableView = self.tableView;
        switch(type)
        {
            case NSFetchedResultsChangeInsert:{
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
                
            default:
                break;
        }
        
    }
    
    
    if (controller == self.collectionFetchedRC) {
        NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
        switch(type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = newIndexPath;
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeMove:
                change[@(type)] = @[indexPath, newIndexPath];
                break;
            case NSFetchedResultsChangeUpdate:
                change[@(type)] = indexPath;
                break;
            default:
                break;
        }
        [self.itemChanges addObject:change];
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerDidChangeContent");
    if (controller == self.tableFetchedRC) {
        [self.tableView endUpdates];
    }
    
    if (controller == self.collectionFetchedRC) {
        [self.collectionView performBatchUpdates: ^{
            UICollectionView *collectionView = self.collectionView;
            for (NSDictionary *change in self.itemChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        default:
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            self.itemChanges = nil;;
        }];
        
    }
}
 
 */

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    if (controller == self.tableFetchedRC) {
        [self.tableView reloadData];
    }
    
    if (controller == self.collectionFetchedRC) {
        [self.collectionView reloadData];
    }
}


- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{}

@end





