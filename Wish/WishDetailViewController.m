//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
#import "CommentAcessaryView.h"
@interface WishDetailViewController () <CommentAcessaryViewDelegate,HeaderViewDelegate>
@property (nonatomic) CGFloat yVel;
@property (strong,nonatomic) CommentAcessaryView *commentView;

@end

@implementation WishDetailViewController

- (void)initialHeaderView{
    CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 350.0f/1136*self.tableView.frame.size.height);
    self.headerView = [HeaderView instantiateFromNib:frame];
}

- (void)setHeaderView:(HeaderView *)headerView{
    _headerView = headerView;
    _headerView.delegate = self;
    _headerView.plan = self.plan;
    self.tableView.tableHeaderView = headerView;
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
    self.headerView.followButton.hidden = YES; // hide follow button and show it when the proper info is fetched from the server
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

//- (CGFloat)heightForText:(NSString *)text{
//    
//    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
//                                                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
//    
//    CGSize maxSize = [[UIScreen mainScreen] bounds].size;
//    
//    CGRect rect = [attributedText boundingRectWithSize:(CGSize){368.0f / 400 * maxSize.width,CGFLOAT_MAX}
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                               context:nil];
//    return rect.size.height; // maximum number of line is 6 for 140 character
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat baseHeight = 750.0f/1136*tableView.frame.size.height;
    return baseHeight;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
    if (feed.feedId){ //prevent crash
        [self performSegueWithIdentifier:[self segueForFeed] sender:feed];
    }
}

- (NSString *)segueForFeed{
    //abstract
    return @"";
}
#pragma mark - like and unlike

- (void)didPressedLikeOnCell:(WishDetailCell *)cell{
    //already increment/decrement like count locally,
    //the following request must respect the current cell.feed like/dislike status
    
    if (!cell.feed.selfLiked.boolValue) {
        [self.fetchCenter likeFeed:cell.feed];
    }else{
        [self.fetchCenter unLikeFeed:cell.feed];
    }
}

- (void)didFinishUnLikingFeed:(Feed *)feed{
    //decrease feed like count
    feed.likeCount = @(feed.likeCount.integerValue - 1);
    feed.selfLiked = @(NO);
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
}

- (void)didFinishLikingFeed:(Feed *)feed{
    //increase feed like count
    feed.likeCount = @(feed.likeCount.integerValue + 1);
    feed.selfLiked = @(YES);
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
//    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",feed.likeCount];
}
#pragma mark - header view 
- (void)updateHeaderView{
    self.headerView.plan = self.plan; //set plan to header for updaing info
}

//- (void)setupBadageImageView{
//    UIImage *image;
//    if (self.plan.planStatus.integerValue == PlanStatusFinished) image = [Theme achieveBadageLabelSuccess];
//    if (self.plan.planStatus.integerValue == PlanStatusGiveTheFuckingUp) image = [Theme achieveBadageLabelFail];
//    self.headerView.badgeImageView.image = image;
//    self.headerView.badgeImageView.hidden = NO;
//}

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
    
    self.headerView.followButton.hidden = NO; //show follow button on request failure.

}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:[self segueForFeed]]){
        [segue.destinationViewController setFeed:sender];
    }
}


#pragma mark - comment
- (CommentAcessaryView *)commentView{
    if (!_commentView){
        _commentView = [CommentAcessaryView instantiateFromNib:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.commentView.feedInfoBackground.hidden = YES; // feed info section is for replying
        _commentView.delegate = self;
    }
    return _commentView;
}

- (void)didPressedCommentOnCell:(WishDetailCell *)cell{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
    self.commentView.feed = cell.feed;
}

- (void)didPressSend:(CommentAcessaryView *)cav{
    [self.fetchCenter commentOnFeed:cav.feed content:cav.textField.text];
}

#pragma mark - fetch center delegate
- (void)didFinishCommentingFeed:(Feed *)feed commentId:(NSString *)commentId{
    
    //update feed count
    feed.commentCount = @(feed.commentCount.integerValue + 1);
    
    //create comment locally
    [Comment createComment:self.commentView.textField.text commentId:commentId forFeed:feed];
    
    [self.commentView removeFromSuperview];
    self.commentView.textField.text = @"";
}

#pragma mark - follow

- (void)didPressedUnFollow:(UIButton *)sender{
    [self.fetchCenter unFollowPlan:self.plan];
}

- (void)didPressedFollow:(UIButton *)sender{
    [self.fetchCenter followPlan:self.plan];
}

- (void)didFinishFollowingPlan:(Plan *)plan{
//    [self.headerView.followButton setTitle:@"已关注" forState:UIControlStateNormal];
//    self.headerView.followButton.titleLabel.text = @"已关注";
    self.headerView.followButton.hidden = NO;
}

- (void)didFinishUnFollowingPlan:(Plan *)plan{
//    [self.headerView.followButton setTitle:@"关注" forState:UIControlStateNormal];
//    self.headerView.followButton.titleLabel.text = @"关注";
    self.headerView.followButton.hidden = NO;
}


@end

