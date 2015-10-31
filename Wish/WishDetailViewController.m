//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
//#import "CommentAcessaryView.h"
#import "UIImageView+ImageCache.h"
#import "UIScrollView+SVInfiniteScrolling.h"
@interface WishDetailViewController () <HeaderViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>
@property (nonatomic,strong) NSDictionary *textAttributes;
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

        [self.fetchCenter updatePlan:self.plan completion:^{
            [textView resignFirstResponder];
        }];
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
    [self.navigationController popViewControllerAnimated:YES];
    
    self.fetchedRC.delegate = nil;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSUInteger numberOfPreservingFeeds = 20;
    NSArray *allFeeds = self.fetchedRC.fetchedObjects;
    if (allFeeds.count > numberOfPreservingFeeds) {
        for (NSUInteger i = numberOfPreservingFeeds; i < allFeeds.count; i++) {
            Feed *feed = allFeeds[i];
            [delegate.managedObjectContext deleteObject:feed];
        }
    }
    [delegate saveContext];
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

    if (![self.tableView.backgroundView isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        self.tableView.backgroundView = imgView;
        
        NSURL *imageUrl = [self.fetchCenter urlWithImageID:self.plan.backgroundNum size:FetchCenterImageSize400];
     
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSString *localKey = [manager cacheKeyForURL:imageUrl];

        if ([manager diskImageExistsForURL:imageUrl]) {
            imgView.image = [[manager.imageCache imageFromDiskCacheForKey:localKey] applyDarkEffect];
            
        }else{
            self.tableView.backgroundColor = [UIColor blackColor];
            self.tableView.backgroundView = nil;
        }
    }else{
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
            case NSFetchedResultsChangeMove:{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
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

#define FONTSIZE 14.0f
- (NSDictionary *)textAttributes{
    if (!_textAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        _textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:FONTSIZE],
                            NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _textAttributes;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect bounds = [feed.feedTitle boundingRectWithSize:CGSizeMake(width - 16.0f,CGFLOAT_MAX) //label左右有8.0f的距离
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:self.textAttributes
                                       context:nil];
    
    CGFloat limit = 80.0f;
    CGFloat height = CGRectGetHeight(bounds);
    if (height > limit) height = limit;
    return  height + width + 33.0f; // 剩余的padding约33.0f;

//    return 430.0f;
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
    
    cell.likeCountLabel.text = feed.likeCount.integerValue ? [NSString stringWithFormat:@"%@",feed.likeCount] : @"赞";
    cell.commentCountLabel.text = feed.commentCount.integerValue ? [NSString stringWithFormat:@"%@",feed.commentCount] : @"评论";
    
    NSNumber *numberOfPictures = [feed numberOfPictures];
    if (numberOfPictures.integerValue > 1) {
        cell.pictureCountLabel.hidden = NO;
        [cell setPictureLabelText:[NSString stringWithFormat:@"共%@张",[feed numberOfPictures]]];
    }else{
        cell.pictureCountLabel.hidden = YES;
    }
    [cell.photoView downloadImageWithImageId:feed.imageId size:FetchCenterImageSize800];
    return cell;
}

#warning - This should go to super view ~ 
- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(nonnull WishDetailCell *)cell
forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    cell.photoView.image = nil;
    [cell.photoView sd_cancelCurrentImageLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //enter feed detail only when plan description text view is not being edited
    if (!self.headerView.descriptionTextView.isFirstResponder){
        Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
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
        [self.fetchCenter likeFeed:feed completion:nil];
    }else{
        
        //decrease feed like count
        feed.likeCount = @(feed.likeCount.integerValue - 1);
        feed.selfLiked = @(NO);
        
        //send unlike request
        [self.fetchCenter unLikeFeed:feed completion:nil];
    }
}


#pragma mark - wish detail cell delegate
- (void)didPressedMoreOnCell:(WishDetailCell *)cell{
}


#pragma mark - fetch center delegate 

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    
    self.headerView.followButton.hidden = NO; //show follow button on request failure.
    [self.tableView.infiniteScrollingView stopAnimating];

}


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
        }

    }
}

- (NSString *)segueForFeed{
    return nil; //abstract
}

- (void)didPressedCommentOnCell:(WishDetailCell *)cell{
    //进入动态详情并呼出键盘
    Feed *feed = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:[self segueForFeed] sender:feed];
}

#pragma mark - follow

- (void)didPressedUnFollow:(UIButton *)sender{
    [self.fetchCenter unFollowPlan:self.plan completion:^{
        [self.headerView updateHeaderWithPlan:self.plan];
    }];
}

- (void)didPressedFollow:(UIButton *)sender{
    [self.fetchCenter followPlan:self.plan completion:^{
        [self.headerView updateHeaderWithPlan:self.plan];
    }];
}


@end

