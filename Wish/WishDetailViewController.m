//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"

@interface WishDetailViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic) CGFloat yVel;
@end

@implementation WishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.headerView.plan = self.plan; //set plan to header for updaing info
}



- (void)setUpNavigationItem
{

    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popToRootViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self setCurrenetBackgroundColor];
}

- (void)setCurrenetBackgroundColor{
    if (self.fetchedRC.fetchedObjects.count) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        
        Feed *feed = (Feed *)self.fetchedRC.fetchedObjects.firstObject;
        imgView.image = [feed.image applyDarkEffect];
        self.tableView.backgroundView = imgView;
    }else{
        self.tableView.backgroundColor = [Theme wishDetailBackgroundNone:self.tableView];
    }
}
#pragma mark - Fetched Results Controller delegate

- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC){
        
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
        request.predicate = [NSPredicate predicateWithFormat:@"plan = %@",self.plan];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
        [request setFetchBatchSize:3];
        
        //create FetchedResultsController with context, sectionNameKeyPath, and you can cache here, so the next work if the same you can use your cash file.
        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:self.plan.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        self.fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        NSError *error;
        [_fetchedRC performFetch:&error];
        
    }
    return _fetchedRC;
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
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView
             insertRowsAtIndexPaths:@[newIndexPath]
             withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView setContentOffset:CGPointZero animated:NO]; //scroll to top

            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView
             deleteRowsAtIndexPaths:@[indexPath]
             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self setCurrenetBackgroundColor];
    [self.tableView endUpdates];

}




#pragma mark - table view delegate and data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 580.0/1136*tableView.frame.size.height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedRC.fetchedObjects.count;
}
- (WishDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    cell.feed = [self.fetchedRC objectAtIndexPath:indexPath];
    return cell;
}


@end

