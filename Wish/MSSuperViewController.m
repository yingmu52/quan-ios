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


#pragma mark - 上拉和下拉控件

- (void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(loadNewData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];

}

- (void)setCollectionView:(UICollectionView *)collectionView{
    _collectionView = collectionView;
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(loadNewData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.collectionView.mj_header = header;
    [self.collectionView.mj_header beginRefreshing];
    
    
    //上拉刷新
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                         refreshingAction:@selector(loadMoreData)];

}

- (void)loadNewData{
    [self stopRefreshingWidget];
}
- (void)loadMoreData{
    [self stopRefreshingWidget];
}

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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionFetchedRC.fetchedObjects.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.tableFetchedRC.sections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.tableFetchedRC.sections[section];
    return [sectionInfo numberOfObjects];
}

// MARK: Table View Fetched Results Controller
- (NSString *)tableSectionKeyPath{ return nil; }

- (NSFetchedResultsController *)tableFetchedRC{
    if (!_tableFetchedRC && self.tableFetchRequest){
        _tableFetchedRC = [[NSFetchedResultsController alloc] initWithFetchRequest:self.tableFetchRequest
                                                              managedObjectContext:self.appDelegate.managedObjectContext
                                                                sectionNameKeyPath:[self tableSectionKeyPath]
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
                                                                   managedObjectContext:self.appDelegate.managedObjectContext
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


    if (controller == self.tableFetchedRC) {
        UITableView *tableView = self.tableView;
        switch(type)
        {
            case NSFetchedResultsChangeInsert:{
                NSLog(@"Table Inserted");
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
                break;
                
            case NSFetchedResultsChangeDelete:{
                NSLog(@"Table Deleted");
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
                break;
                
            case NSFetchedResultsChangeUpdate:{
                NSLog(@"Table Updated");
                [self configureTableViewCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
                break;
                
            case NSFetchedResultsChangeMove:{
                NSLog(@"Table Moved");
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
                break;
                
            default:
                break;
        }
        
    }
    
    
//    if (controller == self.collectionFetchedRC) {
//        NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
//        switch(type) {
//            case NSFetchedResultsChangeInsert:
//                change[@(type)] = newIndexPath;
//                break;
//            case NSFetchedResultsChangeDelete:
//                change[@(type)] = indexPath;
//                break;
//            case NSFetchedResultsChangeMove:
//                change[@(type)] = @[indexPath, newIndexPath];
//                break;
//            case NSFetchedResultsChangeUpdate:
//                change[@(type)] = indexPath;
//                break;
//            default:
//                break;
//        }
//        [self.itemChanges addObject:change];
//    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.tableFetchedRC) {
        [self.tableView endUpdates];
    }
    
    if (controller == self.collectionFetchedRC) {
        [self.collectionView reloadData];
//        [self.collectionView performBatchUpdates: ^{
//            UICollectionView *collectionView = self.collectionView;
//            for (NSDictionary *change in self.itemChanges) {
//                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//                    switch(type) {
//                        case NSFetchedResultsChangeInsert:
//                            [collectionView insertItemsAtIndexPaths:@[obj]];
//                            break;
//                        case NSFetchedResultsChangeDelete:
//                            [collectionView deleteItemsAtIndexPaths:@[obj]];
//                            break;
//                        case NSFetchedResultsChangeMove:
//                            [collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
//                            break;
//                        case NSFetchedResultsChangeUpdate:
//                            [collectionView reloadItemsAtIndexPaths:@[obj]];
//                            break;
//                        default:
//                            break;
//                    }
//                }];
//            }
//        } completion:^(BOOL finished) {
//            self.itemChanges = nil;;
//        }];
        
    }
}

*/

// /*
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    if (controller == self.tableFetchedRC) {
        [self.tableView reloadData];
    }
    
    if (controller == self.collectionFetchedRC) {
        [self.collectionView reloadData];
    }
}
 
// */


- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{}

@end





