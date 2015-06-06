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
#import "Feed+FeedCRUD.h"
#import "SDWebImageCompat.h"
#import "PopupView.h"
#import "FeedDetailHeader.h"
@interface FeedDetailViewController () <FetchCenterDelegate,CommentAcessaryViewDelegate,NSFetchedResultsControllerDelegate,PopupViewDelegate,FeedDetailHeaderDelegate>

@property (strong, nonatomic) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (strong,nonatomic) CommentAcessaryView *commentView;
@property (nonatomic,strong) Feed *feed;


@property (nonatomic) BOOL hasNextPage;
@property (nonatomic,strong) NSDictionary *pageInfo;

@property (nonatomic,strong) FeedDetailHeader *headerView;
@end

@implementation FeedDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];

    //load comments
    self.hasNextPage = YES;
    [self loadComments];
}

- (void)setFeed:(Feed *)feed{
    if (_feed != feed){
        _feed = feed;
        [self updateHeaderInfoForFeed:_feed];
    }
    _feed = feed;
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

#warning 区分主人和客人态
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
//    UIButton *deleteButton = [Theme buttonWithImage:[Theme navButtonDeleted]
//                                             target:self
//                                           selector:@selector(showPopupView)
//                                              frame:frame];
//    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                           target:nil action:nil];
//    space.width = 25.0f;
//    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:deleteButton],
//                                                space,
//                                                [[UIBarButtonItem alloc] initWithCustomView:shareButton]];

}

#pragma mark - dynamic feed title height 

- (FeedDetailHeader *)headerView{
    if (!_headerView) {
        CGFloat height = self.tableView.frame.size.width + [self heightForText:self.feed.feedTitle withFontSize:13.0f] + 32.0f + 8.0f; //bottom 32, top 8
        CGRect frame = CGRectMake(0,0, self.tableView.frame.size.width, height);
        _headerView = [FeedDetailHeader instantiateFromNib:frame];
        _headerView.delegate = self;
        self.tableView.tableHeaderView = _headerView;
    }
    return _headerView;
}

- (void)updateHeaderInfoForFeed:(Feed *)feed{
    if (feed.image){
        self.headerView.imageView.image = feed.image;
    }else{
        [self.headerView.imageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:feed.imageId]
                                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                feed.image = image;
                                            }];
    }
    self.headerView.headerLabel.text = feed.feedTitle;
    self.headerView.dateLabel.text = [SystemUtil stringFromDate:feed.createDate];
    self.headerView.likeCountLabel.text = [NSString stringWithFormat:@"%@",feed.likeCount];
    self.headerView.commentCountLabel.text = [NSString stringWithFormat:@"%@",feed.commentCount];
    [self.headerView.likeButton setImage:(feed.selfLiked.boolValue ? [Theme likeButtonLiked] : [Theme likeButtonUnLiked]) forState:UIControlStateNormal];
        
}

#pragma mark - table view

#define kAvatarSize 40.0f

- (CGFloat)heightForText:(NSString *)text withFontSize:(CGFloat)size{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    CGFloat width = CGRectGetWidth(self.tableView.frame);
    
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(width, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
    return roundf(CGRectGetHeight(bounds));
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.fetchedRC objectAtIndexPath:indexPath];
    return [self heightForText:comment.content withFontSize:14.0] + kAvatarSize;
}

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

    NSString *userAstring = comment.owner.ownerName ? comment.owner.ownerName : @"无用户名";

    if (comment.idForReply && comment.nameForReply) { //this is a reply. format: 回复<color_userName>:content
        
        NSString *userBstring = comment.nameForReply ? comment.nameForReply : @"无用户名";
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

- (void)didPressedLikeButton:(FeedDetailHeader *)headerView{
    if (!self.feed.selfLiked.boolValue) {
        [headerView.likeButton setImage:[Theme likeButtonLiked] forState:UIControlStateNormal];
        
        //increase feed like count
        self.feed.likeCount = @(self.feed.likeCount.integerValue + 1);
        self.feed.selfLiked = @(YES);
        headerView.likeCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.likeCount];
        
        [self.fetchCenter likeFeed:self.feed];
    }else{
        [headerView.likeButton setImage:[Theme likeButtonUnLiked] forState:UIControlStateNormal];
        
        //decrease feed like count
        self.feed.likeCount = @(self.feed.likeCount.integerValue - 1);
        self.feed.selfLiked = @(NO);
        headerView.likeCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.likeCount];
        
        
        [self.fetchCenter unLikeFeed:self.feed];
    }
    
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
//    self.likeButton.userInteractionEnabled = YES;
    NSLog(@"%@",info);
//    self.navigationItem.rightBarButtonItem = nil;

//    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
//                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
//                               delegate:self
//                      cancelButtonTitle:@"OK"
//                      otherButtonTitles:nil, nil] show];
}

#pragma mark - comment

-(void)didPressedCommentButton:(FeedDetailHeader *)headerView{
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
    self.headerView.commentCountLabel.text = [NSString stringWithFormat:@"%@",feed.commentCount];

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

- (void)didFinishLoadingCommentList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage forFeed:(Feed *)feed{
    self.hasNextPage = hasNextPage;
    self.pageInfo = pageInfo;
    self.feed = feed;
}

#pragma mark - fetched results controller 

- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC){
        
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
        request.predicate = [NSPredicate predicateWithFormat:@"feed.feedId = %@",self.feedId ? self.feedId : self.feed.feedId];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]];
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
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Comment inserted");
        }
            break;
            
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Comment deleted");
        }
            break;
            
        case NSFetchedResultsChangeUpdate:{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Comment updated");
        }
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
    // if self.feed is not at local than use feedId to fetchFrom the Cloud
    NSString *feedId = self.feed.feedId ? self.feed.feedId : self.feedId;
    NSAssert(feedId, @"nil feedId");
    [self.fetchCenter getCommentListForFeed:feedId pageInfo:self.pageInfo];
}

#pragma mark - delete local comments to insync with server

//- (void)dealloc{
//    for (Comment *comment in self.fetchedRC.fetchedObjects) {
//        [[AppDelegate getContext] deleteObject:comment];
//    }
//    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
//}

#pragma mark - set up for message view

- (void)setFeedId:(NSString *)feedId{
    _feedId = feedId;
    self.feed = [Feed fetchFeedWithId:_feedId];
}

#pragma mark - feed deletion

- (void)showPopupView{
    if (self.feed){
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        NSString *popupViewTitle = [self isDeletingTheLastFeed] ?
        @"这是最后一条记录啦！\n这件事儿也会被删除哦~" : @"真的要删除这条记录吗？";
        PopupView *popupView = [PopupView showPopupDeleteinFrame:window.frame
                                                       withTitle:popupViewTitle];
        popupView.delegate = self;
        [window addSubview:popupView];
    }
}

- (void)popupViewDidPressCancel:(PopupView *)popupView{
    [popupView removeFromSuperview];
}

- (void)popupViewDidPressConfirm:(PopupView *)popupView{
    if ([self isDeletingTheLastFeed]){
        [self.feed.plan deleteSelf];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.fetchCenter deleteFeed:self.feed];
    }
    [self popupViewDidPressCancel:popupView];
}

- (void)didFinishDeletingFeed:(Feed *)feed{
    [feed deleteSelf];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isDeletingTheLastFeed{
    return self.feed.plan.feeds.count == 1;
}
@end








