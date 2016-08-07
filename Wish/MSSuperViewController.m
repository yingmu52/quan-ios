//
//  MSSuperViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"

@interface MSSuperViewController ()
@property (nonatomic,strong) NSBlockOperation *blockOperation;
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

#pragma mark - Delegates and Data Sources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableFetchedRC.fetchedObjects.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionFetchedRC.fetchedObjects.count;
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.tableFetchedRC) {
        [self.tableView beginUpdates];
    }else if (controller == self.collectionFetchedRC) {
        [UIView setAnimationsEnabled:NO];
        self.blockOperation = [[NSBlockOperation alloc] init];
    }
    
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (controller == self.tableFetchedRC) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:{
//                NSLog(@"%@ INSERT",self.class);
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
                
            case NSFetchedResultsChangeDelete:{
//                NSLog(@"%@ DELETE",self.class);
                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
                
            case NSFetchedResultsChangeUpdate:{
//                NSLog(@"%@ UPDATE",self.class);
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
//                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self configureTableViewCell:cell atIndexPath:indexPath];
            }
                break;
                
            case NSFetchedResultsChangeMove:{
//                NSLog(@"%@ MOVE",self.class);
                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
//                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            }
                break;
                
            default:
                break;
        }
        
    }else if (controller == self.collectionFetchedRC) {
        __weak UICollectionView *collectionView = self.collectionView;
        switch (type) {
            case NSFetchedResultsChangeInsert: {
//                NSLog(@"%@ INSERT",self.class);
                [self.blockOperation addExecutionBlock:^{
                    [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                }];
            }
                break;
            
                
            case NSFetchedResultsChangeDelete: {
//                NSLog(@"%@ DELETE",self.class);
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
                break;
                
            case NSFetchedResultsChangeUpdate: {
//                NSLog(@"%@ UPDATE",self.class);
                [self.blockOperation addExecutionBlock:^{                    
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }];
            }
                break;
                
            case NSFetchedResultsChangeMove: {
//                NSLog(@"%@ MOVE",self.class);
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//                    [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                }];
            }
                break;

            default:
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.tableFetchedRC) {
        [self.tableView endUpdates];
    }else if (controller == self.collectionFetchedRC) {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:^(BOOL finished) {
            [UIView setAnimationsEnabled:YES];
            self.blockOperation = nil;
        }];
    }
}

- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{}

@end





