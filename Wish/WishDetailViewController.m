//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
//#import "CommentAcessaryView.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVInfiniteScrolling.h"
@interface WishDetailViewController () <HeaderViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>
//@property (strong,nonatomic) CommentAcessaryView *commentView;
@end

@implementation WishDetailViewController


#pragma mark setter and getters
- (void)setHeaderView:(HeaderView *)headerView{
    _headerView = headerView;
    _headerView.delegate = self;
    [_headerView updateHeaderWithPlan:self.plan];
    self.tableView.tableHeaderView = headerView;
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
    
}
#pragma mark Header View

- (void)initialHeaderView{
    CGFloat planDescriptionHeight = 0.0f;
    CGFloat fontSize = 12.0f;
    if (self.plan.hasDetailText) {
        planDescriptionHeight = [SystemUtil heightForText:self.plan.detailText withFontSize:fontSize];
    }else if ([self.plan.owner.ownerId isEqualToString:[User uid]]){ //只记算自己的事件描述高度，客人态描述隐藏
        planDescriptionHeight = [SystemUtil heightForText:EMPTY_PLACEHOLDER_OWNER withFontSize:fontSize];
    }
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(mainFrame), 130.0f + planDescriptionHeight);
    self.headerView = [HeaderView instantiateFromNib:frame];
    self.headerView.descriptionTextView.delegate = self;
}

//rquest server to update plan when user hit return key
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        self.plan.detailText = textView.text;
        [self.fetchCenter updatePlan:self.plan];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.isFirstResponder){
        NSInteger maxCount = 75;
        if (textView.text.length > maxCount) {
            textView.text = [textView.text substringToIndex:maxCount];
        }
    }
}

//update table header view's frame when the content of text view changes
- (void)textView:(GCPTextView *)textView contentHeightDidChange:(CGFloat)height{
    if (textView.isFirstResponder){ //this condition avoids a jerking reposition of the header view
        self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 240.0f/1136*self.tableView.frame.size.height + height);
        self.tableView.tableHeaderView = self.tableView.tableHeaderView; //this line does the magic of reposition table view cell after the change of the header frame
    }
}

#pragma mark - set up view

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //pan to pop gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.shadowImage = [UIImage new]; //主页到详情时，隐藏导航分隔线
    [self setUpNavigationItem];
    [self initialHeaderView];
    [self.tableView registerNib:[UINib nibWithNibName:@"WishDetailCell" bundle:nil]
         forCellReuseIdentifier:@"WishDetailCell"];
    self.tableView.separatorColor = [UIColor clearColor]; //remove separation line
    //hide follow button first and display later when the correct value is fetched from the server
    self.headerView.followButton.hidden = YES;
    
    //add infinate scroll
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (weakSelf.hasNextPage) {
            NSLog(@"Loading More..");
            [weakSelf.fetchCenter loadFeedsListForPlan:weakSelf.plan pageInfo:weakSelf.pageInfo];
        }
    }];

    //trigger inital loading
    self.hasNextPage = YES; //important, must set before [self loadMore]
    [self.fetchCenter loadFeedsListForPlan:self.plan pageInfo:self.pageInfo];
    [self.tableView triggerInfiniteScrolling];
}

- (void)goBack{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
//    dispatch_queue_t queue_cleanUp;
//    queue_cleanUp = dispatch_queue_create("com.stories.WishDetailViewController.cleanup", NULL);
//    dispatch_async(queue_cleanUp, ^{
        NSUInteger numberOfPreservingFeeds = 20;
        NSArray *allFeeds = self.fetchedRC.fetchedObjects;
        if (allFeeds.count > numberOfPreservingFeeds) {
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            for (NSUInteger i = numberOfPreservingFeeds; i < allFeeds.count; i++) {
                Feed *feed = allFeeds[i];
                [delegate.managedObjectContext deleteObject:feed];
            }
            [delegate saveContext];
        }
//    });
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(goBack)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self setCurrenetBackgroundColor];
}

- (void)setCurrenetBackgroundColor{
    if (self.plan.image){
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.image = [self.plan.image applyDarkEffect];
        self.tableView.backgroundView = imgView;

    }else{
//        self.tableView.backgroundColor = [Theme wishDetailBackgroundNone:self.tableView];
        self.tableView.backgroundColor = [UIColor blackColor];
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
    switch(type){
            
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"Feed inserted");
        }
            break;
            
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"Feed deleted");
        }
            break;
            
        case NSFetchedResultsChangeUpdate:{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"Feed updated");
        }
            break;

        default:
            break;
    }
}


- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self.headerView updateHeaderWithPlan:self.plan];
}


#pragma mark - table view delegate and data source

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height - 568.0f) >= 0)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    if (IS_IPHONE5){
        return 750.0f/1136 * CGRectGetHeight(frame);
    }else{
        //eariler
        return 785.0f/640 * CGRectGetWidth(frame);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedRC.fetchedObjects.count;
}

- (WishDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    cell.delegate = self;
    Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
    cell.dateLabel.text = [SystemUtil stringFromDate:feed.createDate];
    
    [cell.likeButton setImage:feed.selfLiked.boolValue ? [Theme likeButtonLiked] : [Theme likeButtonUnLiked]
                     forState:UIControlStateNormal];
    
    cell.titleLabel.text = feed.feedTitle;
    
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%@",feed.likeCount];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%@",feed.commentCount];
    if (!feed.image) {
        [cell.photoView sd_setImageWithURL:[self.fetchCenter urlWithImageID:feed.imageId]];
    }else{
        cell.photoView.image = feed.image;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.headerView.descriptionTextView.isFirstResponder){ //enter feed detail only when plan description text view is not being edited
        Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
        //save feed image only when user select certain feed
        if (!feed.image){
            WishDetailCell *cell = (WishDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
            feed.image = cell.photoView.image;
        }
        
        if (feed.feedId){ //prevent crash
            [self performSegueWithIdentifier:[self segueForFeed] sender:feed.feedId];
        }
    }
}

#pragma mark - like and unlike

- (void)didPressedLikeOnCell:(WishDetailCell *)cell{
    //already increment/decrement like count locally,
    //the following request must respect the current cell.feed like/dislike status
    Feed *feed = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    if (!feed.selfLiked.boolValue) {
        //increase feed like count
        feed.likeCount = @(feed.likeCount.integerValue + 1);
        feed.selfLiked = @(YES);
        
        //send like request
        [self.fetchCenter likeFeed:feed];
    }else{
        
        //decrease feed like count
        feed.likeCount = @(feed.likeCount.integerValue - 1);
        feed.selfLiked = @(NO);
        
        //send unlike request
        [self.fetchCenter unLikeFeed:feed];
    }
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

- (void)didFinishUpdatingPlan:(Plan *)plan{
    //did finished update plan description
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    
    self.headerView.followButton.hidden = NO; //show follow button on request failure.
    [self.tableView.infiniteScrollingView stopAnimating];

}

//- (void)didFinishCommentingFeed:(Feed *)feed commentId:(NSString *)commentId{
//    
//    //update feed count
//    feed.commentCount = @(feed.commentCount.integerValue + 1);
//    
//    //create comment locally
////    [Comment createComment:self.commentView.textField.text commentId:commentId forFeed:feed];
//    
////    self.commentView.textField.text = @"";
//}

- (void)didFinishLoadingFeedList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage serverFeedIdList:(NSArray *)serverFeedIds{
    self.hasNextPage = hasNextPage;
    self.pageInfo = pageInfo;
    [self.headerView updateHeaderWithPlan:self.plan];
    [self.tableView.infiniteScrollingView stopAnimating];
    
    if (!self.hasNextPage){
        self.tableView.showsInfiniteScrolling = NO;
    }
    
    //upload a local copy of server side feed list
    [self.serverFeedIds addObjectsFromArray:serverFeedIds];
    
    //delete feed from local if it does not appear to be ien the server side feed list
    for (Feed *feed in self.fetchedRC.fetchedObjects){
        if (![self.serverFeedIds containsObject:feed.feedId]) {
            [feed.managedObjectContext deleteObject:feed];
        }
    }
}


- (NSMutableArray *)serverFeedIds{
    if (!_serverFeedIds){
        _serverFeedIds = [NSMutableArray array];
    }
    return _serverFeedIds;
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:[self segueForFeed]]){
        
        if ([sender isKindOfClass:[NSString class]]){
            [segue.destinationViewController setFeedId:sender];
        }else if ([sender isKindOfClass:[Feed class]]){ //see didPressedCommentOnCell method
            Feed *feed = (Feed *)sender;
            FeedDetailViewController *vc = segue.destinationViewController;
            vc.feedId = feed.feedId;
            
            //show replay view, see didPressedCommentButton in FeedDetailViewController
            vc.commentView.feedInfoBackground.hidden = YES; // feed info section is for replying
            [[[UIApplication sharedApplication] keyWindow] addSubview:vc.commentView];
            [segue.destinationViewController setFeedId:feed.feedId];
            
        }

    }
}

- (NSString *)segueForFeed{
    return nil; //abstract
}

#pragma mark - comment
//- (CommentAcessaryView *)commentView{
//    if (!_commentView){
//        _commentView = [CommentAcessaryView instantiateFromNib:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//        self.commentView.feedInfoBackground.hidden = YES; // feed info section is for replying
//        _commentView.delegate = self;
//    }
//    return _commentView;
//}
//

- (void)didPressedCommentOnCell:(WishDetailCell *)cell{
    //进入动态详情并呼出键盘
    Feed *feed = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:[self segueForFeed] sender:feed];

//    [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
//    self.commentView.feed = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
}
//
//- (void)didPressSend:(CommentAcessaryView *)cav{
//    [self.fetchCenter commentOnFeed:cav.feed content:cav.textField.text];
//    [self.commentView removeFromSuperview];
//
//}

#pragma mark - follow

- (void)didPressedUnFollow:(UIButton *)sender{
    [self.fetchCenter unFollowPlan:self.plan];
}

- (void)didPressedFollow:(UIButton *)sender{
    [self.fetchCenter followPlan:self.plan];
}

- (void)didFinishFollowingPlan:(Plan *)plan{
    [self.headerView updateHeaderWithPlan:plan];
}

- (void)didFinishUnFollowingPlan:(Plan *)plan{
    [self.headerView updateHeaderWithPlan:plan];
}


@end

