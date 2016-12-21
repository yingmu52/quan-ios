//
//  MSSuperViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"
@interface MSSuperViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSMutableArray *itemChanges;
@end

@implementation MSSuperViewController


- (MBProgressHUD *)hud{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        _hud.mode = MBProgressHUDModeText;
        _hud.delegate = self;
    }
    return _hud;
}

#pragma mark - 控制器生活周期 Application Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self polishNavigationBar:YES];
}

- (void)polishNavigationBar:(BOOL)isClear{
    if (self.allowTransparentNavigationBar) {
        NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
        isClear ? [nav showClearBackground] : [nav showDefaultBackground];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self polishNavigationBar:NO];
}

- (void)setUpBackButton:(BOOL)useWhiteButton{
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        CGRect frame = CGRectMake(0,0, 25,25);
        UIImage *img = useWhiteButton ? [Theme navWhiteButtonDefault] : [Theme navBackButtonDefault];
        UIButton *backBtn = [Theme buttonWithImage:img
                                            target:self
                                          selector:@selector(msPopViewController)
                                             frame:frame];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

- (void)setupRightBarButtonItem:(BOOL)useWhiteIcon selector:(SEL)method{
    //点点点入口
    UIImage *img = useWhiteIcon ? [Theme navMoreButtonWhite] : [Theme navMoreButtonDefault];
    UIButton *moreBtn = [Theme buttonWithImage:img
                                        target:self
                                      selector:method
                                         frame:CGRectNull]; //使用真实大小
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.tableHeaderView && self.allowTransparentNavigationBar) {
        CGRect headFrame = self.tableView.tableHeaderView.frame;
        CGFloat animationOffset = CGRectGetMaxY(headFrame) - scrollView.contentOffset.y;
        NavigationBar *navbar = (NavigationBar *)self.navigationController.navigationBar;
        CGFloat threshold = CGRectGetHeight(headFrame);
        if (animationOffset >= 0 && animationOffset <= threshold){
            CGFloat alpha = 1 - animationOffset / threshold;
            alpha = alpha >= 0.9 ? 1.0 : alpha;
            alpha = alpha <= 0.2 ? 0.0 : alpha;
            
            
            if ([self.superVCDelegate respondsToSelector:@selector(didScrollWithNavigationBar:)]) {
                BOOL isTransparent = alpha <= 0.5;
                [self.superVCDelegate didScrollWithNavigationBar:isTransparent];
            }
            
            [UIView animateWithDuration:0.05 animations:^{
                [navbar setNavigationBarWithColor:[UIColor colorWithWhite:1.0 alpha:alpha]];
            }];
        }
    }
}

- (void)msPopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

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


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{

    if (controller == self.tableFetchedRC) {
        [self.tableView beginUpdates];
    }else if (controller == self.collectionFetchedRC) {
        self.itemChanges = [[NSMutableArray alloc] init];
    }else{
        NSAssert(false, @"Unkown Error in 'controllerWillChangeContent' ");
    }

}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (controller == self.tableFetchedRC) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationNone];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationNone];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationNone];
                break;
            case NSFetchedResultsChangeMove:
                [self.tableView moveSection:sectionIndex toSection:sectionIndex];
                break;
            default:
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(nullable NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(nullable NSIndexPath *)newIndexPath
{


    if (controller == self.tableFetchedRC) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:{
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
                break;
                
            case NSFetchedResultsChangeDelete:{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
                break;
                
            case NSFetchedResultsChangeUpdate:{
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
                break;
             case NSFetchedResultsChangeMove:
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
                
            default:
                break;
        }
        
    }else if (controller == self.collectionFetchedRC) {
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
    }else{
        NSAssert(false, @"Unkown Error in 'didChangeObject:atIndexPath' ");
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.tableFetchedRC) {
        [self.tableView endUpdates];
    }else if (controller == self.collectionFetchedRC) {
        [self.collectionView performBatchUpdates: ^{
            for (NSDictionary *change in self.itemChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        default:
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            self.itemChanges = nil;;
        }];
    }else{
        NSAssert(false, @"Unkown Error in 'controllerDidChangeContent' ");
    }
}

- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    return;
}

@end





