//
//  FeedDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIActionSheet+Blocks.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "JTSImageViewController.h"
@interface FeedDetailViewController ()
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSDictionary *textAttributes;
//@property (nonatomic,strong) NSString *testtext;
@end

@implementation FeedDetailViewController 

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"MM-dd HH:mm";
    }
    return _dateFormatter;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self.tableView registerNib:[UINib nibWithNibName:@"FeedDetailCell" bundle:nil] forCellReuseIdentifier:FEEDDETAILCELLID];

    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (weakSelf.hasNextPage) {
            [weakSelf loadComments];
        }
    }];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell


    //load comments
    self.hasNextPage = YES;
    [self loadComments];
    [self.tableView triggerInfiniteScrolling];
    
}

- (void)setFeed:(Feed *)feed{
    if (feed != _feed) {
        _feed = feed;
        [self updateHeaderInfoForFeed:_feed];
    }
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

#pragma mark - Feed Detail View Header Delegate 

- (void)didTapOnImageView:(UIImageView *)imageView{
    if (imageView.image) {
        // Create image info
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = imageView.image;
        imageInfo.referenceRect = imageView.frame;
        imageInfo.referenceView = imageView.superview;
        
        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

#pragma mark - dynamic feed title height
#define FONTSIZE 14.0f
- (NSDictionary *)textAttributes{
    if (!_textAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 10.0f;
//        paragraphStyle.minimumLineHeight = FONTSIZE;
        _textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:FONTSIZE],
                            NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _textAttributes;
}

- (CGFloat)heightForText:(NSString *)text withFontSize:(CGFloat)size referenceWidth:(CGFloat)width{
    
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(width - 24.0f,CGFLOAT_MAX) //label左右有12.0f的距离
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:[self textAttributes]
                                       context:nil];
    return CGRectGetHeight(bounds);
}

- (FeedDetailHeader *)headerView{
    if (!_headerView) {
        
        //计算高度
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat height = width + 10.0f + 48.0f + //referece FeedDetailHeader.xib
        [self heightForText:self.feed.feedTitle withFontSize:FONTSIZE referenceWidth:width];
        
        CGRect frame = CGRectMake(0,0, CGRectGetHeight(self.view.frame), height);
        _headerView = [FeedDetailHeader instantiateFromNib:frame];
        _headerView.delegate = self;
        self.tableView.tableHeaderView = _headerView;
        
        
        NSArray *images = [self.feed imageIdArray].count > 1 ? [self.feed imageIdArray] : @[self.feed.imageId];
        
        CGFloat w = CGRectGetWidth(_headerView.frame);
        _headerView.scrollView.contentSize = CGSizeMake(w * images.count, w);
        _headerView.pageControl.numberOfPages = images.count;
                
        for (NSUInteger index = 0; index < images.count; index++) {
            CGRect frame = CGRectMake(index * w, 0, w, w);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;

            NSURL *imageUrl = [[FetchCenter new] urlWithImageID:images[index] size:FetchCenterImageSize800];
            [imageView showImageWithImageUrl:imageUrl];
            
            [_headerView.scrollView addSubview:imageView];
            
        }

    }
    return _headerView;
}

//- (NSString *)testtext{
//    if (!_testtext) {
//        _testtext = [SystemUtil randomLorumIpsum];
//    }
//    return _testtext;
//}

- (void)updateHeaderInfoForFeed:(Feed *)feed{
    self.headerView.titleTextLabel.attributedText = [[NSAttributedString alloc] initWithString:self.feed.feedTitle
                                                                                    attributes:self.textAttributes];
    self.headerView.dateLabel.text = [SystemUtil stringFromDate:feed.createDate];
    [self.headerView setLikeButtonText:[NSString stringWithFormat:@"%@",feed.likeCount]];
    [self.headerView setCommentButtonText:[NSString stringWithFormat:@"%@",feed.commentCount]];
    [self.headerView.likeButton setSelected:feed.selfLiked.boolValue];
}

#pragma mark - table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:FEEDDETAILCELLID
                                    cacheByIndexPath:indexPath
                                       configuration:^(id cell) {
        [self configureCell:cell indexPath:indexPath];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedRC.fetchedObjects.count;
}

- (void)configureCell:(FeedDetailCell *)cell indexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.fetchedRC objectAtIndexPath:indexPath];
    NSURL *imageUrl = [self.fetchCenter urlWithImageID:comment.owner.headUrl size:FetchCenterImageSize50];
    [cell.profileImageView showImageWithImageUrl:imageUrl];
    
    cell.contentTextView.text = comment.content;
    
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
    cell.dateLabel.text = [self.dateFormatter stringFromDate:comment.createTime];
}

- (FeedDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FEEDDETAILCELLID forIndexPath:indexPath];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //show comment view for replying
    self.commentView.feedInfoBackground.hidden = NO; // feed info section is for replying
    Comment *comment = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if (![comment.owner.ownerId isEqualToString:[User uid]]) { //the comment is from other user
        self.commentView.comment = comment;
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.fetchedRC objectAtIndexPath:indexPath];
    return [comment.owner.ownerId isEqualToString:[User uid]];
}

#pragma mark - highlight

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [SystemUtil colorFromHexString:@"#E7F0ED"];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - edit cell for delete comment 

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath{
    //this method must be implemented in order to get things work.
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                      title:@"删除"
                                                                    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [UIActionSheet showInView:self.view
                        withTitle:@"是否删除该条评论？"
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:@"删除"
                otherButtonTitles:nil
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"删除"]){
                                 //delete this comment
                                 [self.fetchCenter deleteComment:[self.fetchedRC objectAtIndexPath:indexPath]];
                             }
                         }];

    }];
    
    return @[delete];
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
        [headerView.likeButton setSelected:YES];

        //increase feed like count
        self.feed.likeCount = @(self.feed.likeCount.integerValue + 1);
        self.feed.selfLiked = @(YES);
        [self.fetchCenter likeFeed:self.feed];
    }else{
        [headerView.likeButton setSelected:NO];
//        [headerView.likeButton setImage:[Theme likeButtonUnLiked] forState:UIControlStateNormal];
        
        //decrease feed like count
        self.feed.likeCount = @(self.feed.likeCount.integerValue - 1);
        self.feed.selfLiked = @(NO);
        
        [self.fetchCenter unLikeFeed:self.feed];
    }
    [headerView setLikeButtonText:[NSString stringWithFormat:@"%@",self.feed.likeCount]];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self.tableView.infiniteScrollingView stopAnimating];
    NSLog(@"%@",info);
    if (!self.feed){
        self.title = @"该内容不存在";
    }
}

#pragma mark - comment

-(void)didPressedCommentButton:(FeedDetailHeader *)headerView{
    self.commentView.feedInfoBackground.hidden = YES; // feed info section is for replying
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
    
}

- (void)didFinishDeletingComment:(Comment *)comment{
    [[AppDelegate getContext] deleteObject:comment];
    self.feed.commentCount = @(self.feed.commentCount.integerValue - 1);
    [self.headerView setCommentButtonText:[NSString stringWithFormat:@"%@",self.feed.commentCount]];
}


#pragma mark - comment accessary view delegate 
- (void)didPressSend:(CommentAcessaryView *)cav{
    if (cav.textField.hasText){
        if (cav.state == CommentAcessaryViewStateComment) {
            [self.fetchCenter commentOnFeed:self.feed
                                    content:cav.textField.text];
        }else if (cav.state == CommentAcessaryViewStateReply){
            [self.fetchCenter replyAtFeed:self.feed
                                  content:cav.textField.text
                                  toOwner:cav.comment.owner.ownerId];
        }
        [self.commentView removeFromSuperview];
    }
}

#pragma mark - fetch center delegate 
- (void)didFinishCommentingFeed:(Feed *)feed commentId:(NSString *)commentId{
    
    //update feed count
    feed.commentCount = @(feed.commentCount.integerValue + 1);
    [self.headerView setCommentButtonText:[NSString stringWithFormat:@"%@",feed.commentCount]];

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
    self.commentView.textField.text = @"";
}

- (void)didFinishLoadingCommentList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage forFeed:(Feed *)feed{
    self.hasNextPage = hasNextPage;
    self.pageInfo = pageInfo;
    self.feed = feed;
    
    //stop animation
    [self.tableView.infiniteScrollingView stopAnimating];
    if (!self.hasNextPage){ //stop scroll to load more
        self.tableView.showsInfiniteScrolling = NO;
    }

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


- (void)loadComments{
    NSString *feedId = self.feed.feedId ? self.feed.feedId : self.feedId;
    NSAssert(feedId, @"nil feedId");
    [self.fetchCenter getCommentListForFeed:feedId pageInfo:self.pageInfo];
}

#pragma mark - delete local comments to insync with server

- (void)dealloc{
    NSUInteger numberOfPreservingCommentss = 20;
    NSArray *comments = self.fetchedRC.fetchedObjects;
    if (comments.count > numberOfPreservingCommentss) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        //order of delete is depending on how the comments are displayed (by older comments are at the top
        for (NSUInteger i = comments.count -1; i >= numberOfPreservingCommentss; i--) {
            Comment *comment = comments[i];
            [delegate.managedObjectContext deleteObject:comment];
        }
        [delegate saveContext];
    }

}

#pragma mark - set up for message view

- (void)setFeedId:(NSString *)feedId{
    _feedId = feedId;
    self.feed = [Feed fetchFeedWithId:_feedId];
}

@end








