//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
#import "SDWebImageCompat.h"
@interface WishDetailViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic) CGFloat yVel;
@end

@implementation WishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self.tableView registerNib:[UINib nibWithNibName:@"WishDetailCell" bundle:nil]
         forCellReuseIdentifier:@"WishDetailCell"];
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
    dispatch_main_async_safe(^{
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView
                 insertRowsAtIndexPaths:@[newIndexPath]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView setContentOffset:CGPointZero animated:NO]; //scroll to top
                NSLog(@"Feed inserted");
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView
                 deleteRowsAtIndexPaths:@[indexPath]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
                NSLog(@"Feed deleted");
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                NSLog(@"Feed updated");
                break;
            default:
                break;
        }        
    })
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self setCurrenetBackgroundColor];
    [self.tableView endUpdates];

}

#pragma mark - table view delegate and data source

- (CGFloat)heightForText:(NSString *)text{
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}];
    
    CGSize maxSize = [[UIScreen mainScreen] bounds].size;
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){368.0f / 400 * maxSize.width,maxSize.height}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height; // maximum number of line is 6 for 140 character
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
    CGFloat margin = 0.0f;
    return (580.0f - margin)/1136*tableView.frame.size.height + [self heightForText:feed.feedTitle];
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

