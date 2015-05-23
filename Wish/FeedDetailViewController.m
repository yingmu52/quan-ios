//
//  FeedDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "Theme.h"
#import "FeedDetailCell.h"
#import "FetchCenter.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "CommentAcessaryView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface FeedDetailViewController () <FetchCenterDelegate,CommentAcessaryViewDelegate,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView* tableHeaderViewWrapper;
@property (weak, nonatomic) IBOutlet UILabel* headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (strong,nonatomic) CommentAcessaryView *commentView;



@property (nonatomic) BOOL hasNextPage;
@property (nonatomic,strong) NSDictionary *pageInfo;
@end

@implementation FeedDetailViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupContents];

    //load comments
    self.hasNextPage = YES;
    [self loadComments];
}

- (void)setupContents{
    self.imageView.image = self.feed.image;
    self.headerLabel.text = self.feed.feedTitle;
    self.dateLabel.text = [SystemUtil stringFromDate:self.feed.createDate];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.likeCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.commentCount];
    [self.likeButton setImage:(self.feed.selfLiked.boolValue ? [Theme likeButtonLiked] : [Theme likeButtonUnLiked]) forState:UIControlStateNormal];
}


- (void)setUpNavigationItem
{
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    
    UIButton *shareButton = [Theme buttonWithImage:[Theme navShareButtonDefault]
                                           target:self
                                         selector:nil
                                            frame:frame];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
}

#pragma mark - dynamic feed title height 

/*
 1) Add a headerView to a UITableView.
 2) Add a subview to headerView, let's call it wrapper.
 3) Make wrapper's height be adjusted with it's subviews (via Auto Layout).
 4) When autolayout had finished layout, set headerView's height to wrapper's height. (see -updateTableViewHeaderViewHeight)
 5) Reset headerView. (see -resetTableViewHeaderView)
 
 
 All this works seamlessly after the initial autolayout pass. Later, if you change wrapper's contents so that it gains different
 height, it wont work for some reason (guess laying out UILabel requires several autolayout passes or something). I solved this
 with scheduling setNeedsLayout for the ViewController's view in the next run loop iteration.
 */

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateTableViewHeaderViewHeight];
}

- (void)updateTableViewHeaderViewHeight
{
    // get height of the wrapper and apply it to a header
    CGRect Frame = self.tableView.tableHeaderView.frame;
    Frame.size.height = self.tableHeaderViewWrapper.frame.size.height;
    self.tableView.tableHeaderView.frame = Frame;
    
    // this magic applies the above changes
    // note, that if you won't schedule this call to the next run loop iteration
    // you'll get and error
    [self performSelector:@selector(resetTableViewHeaderView) withObject:self afterDelay:0];
}

// yeah, gues there's something special in the setter
- (void)resetTableViewHeaderView
{
    // whew, this could be animated!
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    
    // We need this to update the height, still not fully sure why do we need to
    // schedule this call for the next Run Loop iteration, will appreciate comments.
    [self.view performSelector:@selector(setNeedsLayout) withObject:nil afterDelay:0];
}


#pragma mark - table view 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedRC.fetchedObjects.count;
}

- (FeedDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FEEDDETAILCELLID forIndexPath:indexPath];
    Comment *comment = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if (!comment.owner.image) {
        [cell.profileImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:comment.owner.headUrl]
                                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
             comment.owner.image = image;
         }];

    }else{
        cell.profileImageView.image = comment.owner.image;
    }
    cell.contentLabel.text = comment.content;
    
    NSDictionary *userNameAttribute = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00B9C0"]};

    NSString *userAstring = comment.owner.ownerName ? comment.owner.ownerName : @"";

    if (comment.idForReply && comment.nameForReply) { //this is a reply. format: 回复<color_userName>:content
        
        NSString *userBstring = comment.nameForReply ? comment.nameForReply : @"";
        NSMutableAttributedString *userA = [[NSMutableAttributedString alloc] initWithString:userAstring
                                                                                  attributes:userNameAttribute];
        NSMutableAttributedString *reply = [[NSMutableAttributedString alloc] initWithString:@"回复"];
        NSMutableAttributedString *userB = [[NSMutableAttributedString alloc] initWithString:userBstring
                                                                                  attributes:userNameAttribute];
        
        [userA appendAttributedString:reply];
        [userA appendAttributedString:userB];
        cell.userNameLabel.attributedText = userA;
    }else{
        
        cell.userNameLabel.attributedText = [[NSAttributedString alloc] initWithString:userAstring
                                                                            attributes:userNameAttribute];
    }
    cell.dateLabel.text = [SystemUtil timeStringFromDate:comment.createTime];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //show comment view for replying
    self.commentView.feedInfoBackground.hidden = NO; // feed info section is for replying
    Comment *comment = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if (![comment.owner.ownerId isEqualToString:[User uid]]) { //can't reply to self
        self.commentView.comment = comment;
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
    }
    
}

- (CommentAcessaryView *)commentView{
    if (!_commentView){
        _commentView = [CommentAcessaryView instantiateFromNib:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _commentView.delegate = self;
    }
    return _commentView;
}
#pragma mark - like
- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (IBAction)likeButtonPressed{
    if (!self.feed.selfLiked.boolValue) {
        [self.likeButton setImage:[Theme likeButtonLiked] forState:UIControlStateNormal];
        [self.fetchCenter likeFeed:self.feed];
    }else{
        [self.likeButton setImage:[Theme likeButtonUnLiked] forState:UIControlStateNormal];
        [self.fetchCenter unLikeFeed:self.feed];
    }
    self.likeButton.userInteractionEnabled = NO;

}

- (void)didFinishUnLikingFeed:(Feed *)feed{
    self.likeButton.userInteractionEnabled = YES;
    //decrease feed like count
    feed.likeCount = @(self.feed.likeCount.integerValue - 1);
    feed.selfLiked = @(NO);
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",feed.likeCount];
}

- (void)didFinishLikingFeed:(Feed *)feed{
    self.likeButton.userInteractionEnabled = YES;
    //increase feed like count
    feed.likeCount = @(self.feed.likeCount.integerValue + 1);
    feed.selfLiked = @(YES);
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",feed.likeCount];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    self.likeButton.userInteractionEnabled = YES;
    NSLog(@"%@",info);
    self.navigationItem.rightBarButtonItem = nil;

//    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
//                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
//                               delegate:self
//                      cancelButtonTitle:@"OK"
//                      otherButtonTitles:nil, nil] show];
}

#pragma mark - comment

- (IBAction)comment:(UIButton *)sender{
    self.commentView.feedInfoBackground.hidden = YES; // feed info section is for replying
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
}

#pragma mark - comment accessary view delegate 
- (void)didPressSend:(CommentAcessaryView *)cav{
    if (cav.state == CommentAcessaryViewStateComment) {
        [self.fetchCenter commentOnFeed:self.feed
                                content:cav.textField.text];
    }else if (cav.state == CommentAcessaryViewStateReply){
        [self.fetchCenter replyAtFeed:self.feed
                              content:cav.textField.text
                              toOwner:cav.comment.owner.ownerId];
    }
}

#pragma mark - fetch center delegate 
- (void)didFinishCommentingFeed:(Feed *)feed commentId:(NSString *)commentId{
    
    //update feed count
    feed.commentCount = @(feed.commentCount.integerValue + 1);
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",feed.commentCount];

    //create comment locally
    if (self.commentView.state == CommentAcessaryViewStateComment) {
        [Comment createComment:self.commentView.textField.text
                     commentId:commentId
                       forFeed:feed];
        
    }else if (self.commentView.state == CommentAcessaryViewStateReply){
        [Comment replyToOwner:self.commentView.comment.owner // this is done in didSelectRowAtIndexPath
                      content:self.commentView.textField.text
                    commentId:commentId
                      forFeed:feed];
    }
    
    [self.commentView removeFromSuperview];
    self.commentView.textField.text = @"";
}

- (void)didFinishLoadingCommentList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage{
    self.hasNextPage = hasNextPage;
    self.pageInfo = pageInfo;
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - fetched results controller 

- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC){
        
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
        request.predicate = [NSPredicate predicateWithFormat:@"feed = %@",self.feed];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]];
        [request setFetchBatchSize:3];
        
        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:[AppDelegate getContext]
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        self.fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        NSError *error;
        [_fetchedRC performFetch:&error];
        
    }
    return _fetchedRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
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
            NSLog(@"Comment inserted");
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Comment deleted");
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"Comment updated");
            break;
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
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
    if (self.hasNextPage) {
        [self loadComments];
    }else{
        self.title = @"别拉了，没了！";
        [self performSelector:@selector(setTitle:) withObject:nil afterDelay:0.5f];
    }
}


- (void)loadComments{
    if (self.feed){
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        [spinner startAnimating];
        [self.fetchCenter getCommentListForFeed:self.feed pageInfo:self.pageInfo];
    }
}

#pragma mark - delete local comments to insync with server

//- (void)dealloc{
//    for (Comment *comment in self.fetchedRC.fetchedObjects) {
//        [[AppDelegate getContext] deleteObject:comment];
//    }
//    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
//}

#pragma mark - set up for message view 

/*
 1. When set self.feedId, fetch local database.
 2. set self.feed to the local feed instance.
 3. if self.feed does not exist, then fetch only and get feed
 */

- (void)setFeedId:(NSString *)feedId{
    _feedId = feedId;
    NSArray *results = [Plan fetchWith:@"Feed"
                             predicate:[NSPredicate predicateWithFormat:@"feedId = %@",feedId]
                      keyForDescriptor:@"createDate"];
    NSAssert(results.count <= 1, @"feed id is not unique");
    
    if (results.count) {
        self.feed = results.lastObject;
    }else{
        //load Feed from online
#warning need to work on this !
    }
}
@end








