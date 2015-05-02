//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"

@interface WishDetailViewController () 
@property (nonatomic) CGFloat yVel;
@end

@implementation WishDetailViewController

- (void)initialHeaderView{
    self.headerView = [HeaderView instantiateFromNib:CGRectMake(0, 0, self.tableView.frame.size.width, 280.0/1136*self.tableView.frame.size.height)];
    self.tableView.tableHeaderView = self.headerView;
    self.headerView.plan = self.plan;
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
  
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self initialHeaderView];
    [self.tableView registerNib:[UINib nibWithNibName:@"WishDetailCell" bundle:nil]
         forCellReuseIdentifier:@"WishDetailCell"];
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
        Feed *feed = (Feed *)self.fetchedRC.fetchedObjects.firstObject;
        if (feed.image) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            imgView.image = [feed.image applyDarkEffect];
            self.tableView.backgroundView = imgView;
        }
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
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self fetchResultsControllerDidInsert];
            NSLog(@"Feed inserted");
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Feed deleted");
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"Feed updated");
            break;
        default:
            break;
    }
    
    [self updateHeaderView];
}

- (void)fetchResultsControllerDidInsert{
    //abstract
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
                                                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
    
    CGSize maxSize = [[UIScreen mainScreen] bounds].size;
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){368.0f / 400 * maxSize.width,CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height; // maximum number of line is 6 for 140 character
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat baseHeight = 550.0f/1136*tableView.frame.size.height;

    Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
    CGFloat additionalTextHeight = [self heightForText:feed.feedTitle];
    CGFloat margin = 50.0f;
    
    CGFloat actualHeight = (550.0f - margin)/1136*tableView.frame.size.height + additionalTextHeight;
    return actualHeight < baseHeight ? baseHeight : actualHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedRC.fetchedObjects.count;
}

- (WishDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.feed = [self.fetchedRC objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - wish detail view cell delegate 

- (void)didPressedLikeOnCell:(WishDetailCell *)cell{
    //already increment/decrement like count locally,
    //the following request must respect the current cell.feed like/dislike status
    
    if (cell.feed.selfLiked.boolValue) {
        [self.fetchCenter likeFeed:cell.feed];
    }else{
        [self.fetchCenter unLikeFeed:cell.feed];
    }
}

#pragma mark - header view 
- (void)updateHeaderView{
    self.headerView.plan = self.plan; //set plan to header for updaing info
}

- (void)setupBadageImageView{
    UIImage *image;
    if (self.plan.planStatus.integerValue == PlanStatusFinished) image = [Theme achieveBadageLabelSuccess];
    if (self.plan.planStatus.integerValue == PlanStatusGiveTheFuckingUp) image = [Theme achieveBadageLabelFail];
    self.headerView.badgeImageView.image = image;
    self.headerView.badgeImageView.hidden = NO;
}

#pragma mark - did scroll to bottom
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    CGFloat y = offset.y + bounds.size.height - inset.bottom;
    CGFloat h = size.height;
    
    CGFloat reload_distance = 50.0;
    if(y > h + reload_distance) {
        [self loadMore];
    }
}

- (void)loadMore{
    //abstract
}

#pragma mark - wish detail cell delegate
- (void)didPressedMoreOnCell:(WishDetailCell *)cell{
    [UIActionSheet showInView:self.tableView withTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"分享这张照片"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"分享这张照片"]) {
            NSLog(@"share feed");
        }
    }];
}


#pragma mark - fetch center delegate 

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

@end

