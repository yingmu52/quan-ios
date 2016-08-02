//
//  FeedDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "JTSImageViewController.h"
#import "CommentViewController.h"
@interface FeedDetailViewController ()
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSDictionary *textAttributes;
@property (nonatomic,strong) NSNumber *currentPage;
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
    [self.tableView registerNib:[UINib nibWithNibName:@"FeedDetailCell" bundle:nil]
         forCellReuseIdentifier:FEEDDETAILCELLID];

    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreComments)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    //不要用beginRefreshing 因为会很淫荡地跳到页面下方
    [self loadMoreComments];
}

- (void)loadMoreComments{
    NSString *feedId = self.feed.feedId ? self.feed.feedId : self.feedId;
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"commentId"];
    //        NSLog(@"%@",self.currentPage);
    [self.fetchCenter getCommentListForFeed:feedId
                                  localList:localList
                                currentPage:self.currentPage
                                 completion:^(NSNumber *currentPage,
                                              NSNumber *totalPage,
                                              BOOL hasComments)
     {
         //            NSLog(@"%@ %@",currentPage,totalPage);
         if ([currentPage isEqualToNumber:totalPage] || !hasComments) {
             [self.tableView.mj_footer endRefreshingWithNoMoreData];
         }else{
             self.currentPage = @(currentPage.integerValue + 1);
             [self.tableView.mj_footer endRefreshing];
         }
         if (!self.feed) {
             self.feed = [Feed fetchFeedWithId:feedId];
         }
          
     }];
}


- (void)setFeed:(Feed *)feed{
    _feed = feed;
    [self updateHeaderInfoForFeed:feed];
}

- (void)setFeedId:(NSString *)feedId{
    _feedId = feedId;
    self.feed = [Feed fetchFeedWithId:feedId];
}

- (void)setUpNavigationItem
{
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    
    
//    UIButton *shareButton = [Theme buttonWithImage:[Theme navShareButtonDefault]
//                                            target:self
//                                          selector:nil
//                                             frame:frame];
    
//    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                           target:nil action:nil];
//    space.width = 25.0f;
//    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:deleteButton],
//                                                space,
//                                                [[UIBarButtonItem alloc] initWithCustomView:shareButton]];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    if ([self.feed.plan.owner.ownerId isEqualToString:[User uid]]) {
        UIButton *deleteButton = [Theme buttonWithImage:[Theme navButtonDeleted]
                                                 target:self
                                               selector:@selector(showPopupView)
                                                  frame:frame];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    }
}


- (void)showPopupView{
    if (self.feed){
        NSString *title = self.feed.plan.feeds.count == 1 ?
        @"这是最后一条记录啦！\n这件事儿也会被删除哦~" : @"真的要删除这条记录吗？";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            if (self.feed.plan.feeds.count == 1){
                                                                [self.fetchCenter deletePlanId:self.feed.plan.planId completion:^{
                                                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                                                }];
                                                            }else{
                                                                [self.fetchCenter deleteFeed:self.feed completion:^{
                                                                    [self.navigationController popViewControllerAnimated:YES];
                                                                }];
                                                            }
                                                        }];
        
        [alert addAction:confirm];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
                                    attributes:self.textAttributes
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
            [imageView downloadImageWithImageId:images[index] size:FetchCenterImageSize800];
            [_headerView.scrollView addSubview:imageView];
            
        }

    }
    return _headerView;
}


- (void)updateHeaderInfoForFeed:(Feed *)feed{
    if (feed) {
        self.headerView.titleTextLabel.attributedText = [[NSAttributedString alloc] initWithString:feed.feedTitle
                                                                                        attributes:self.textAttributes];
        self.headerView.dateLabel.text = [SystemUtil stringFromDate:feed.createDate];
        [self.headerView setLikeButtonText:feed.likeCount];
        [self.headerView setCommentButtonText:feed.commentCount];
        [self.headerView.likeButton setSelected:feed.selfLiked.boolValue];
    }
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
    return self.tableFetchedRC.fetchedObjects.count;
}

- (void)configureCell:(FeedDetailCell *)cell indexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [cell.profileImageView downloadImageWithImageId:comment.owner.headUrl size:FetchCenterImageSize100];
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
    Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
    
    if (![comment.owner.ownerId isEqualToString:[User uid]]) { //the comment is from other user
        [self performSegueWithIdentifier:@"showCommentViewController" sender:comment];
    }else{
        [self deleteActionAtIndexPath:indexPath];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
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
        [self deleteActionAtIndexPath:indexPath];

    }];
    
    return @[delete];
}

- (void)deleteActionAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"是否删除该条评论？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
        [self.fetchCenter deleteComment:comment completion:^{
            [comment.managedObjectContext  deleteObject:comment];
            self.feed.commentCount = @(self.feed.commentCount.integerValue - 1);
            [self.headerView setCommentButtonText:self.feed.commentCount];
        }];
    }];
    
    [actionSheet addAction:deleteAction];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - like

- (void)didPressedLikeButton:(FeedDetailHeader *)headerView{
    if (!self.feed.selfLiked.boolValue) {
        [headerView.likeButton setSelected:YES];
        [self.fetchCenter likeFeed:self.feed completion:nil];
    }else{
        [headerView.likeButton setSelected:NO];        
        [self.fetchCenter unLikeFeed:self.feed completion:nil];
    }
    [headerView setLikeButtonText:self.feed.likeCount];
}

- (void)didFailSendingRequest{
    [self.tableView.mj_footer endRefreshing];
    if (!self.feed){
        self.title = @"该内容不存在";
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showCommentViewController"]) {
        CommentViewController *cvc = segue.destinationViewController;
        if (sender) {
            cvc.comment = sender;
        }
        cvc.feedDetailViewController = self;
    }
}
#pragma mark - comment

-(void)didPressedCommentButton:(FeedDetailHeader *)headerView{
    [self performSegueWithIdentifier:@"showCommentViewController" sender:nil];
}

#pragma mark - fetched results controller 

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feed.feedId == %@",self.feedId];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]];
    }
    return _tableFetchRequest;
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [super controller:controller
      didChangeObject:anObject
          atIndexPath:indexPath
        forChangeType:type
         newIndexPath:newIndexPath];
    
    if ((type == NSFetchedResultsChangeInsert ||
         type == NSFetchedResultsChangeDelete) &&
        self.feed &&
        controller == self.tableFetchedRC) {
        [self.headerView setCommentButtonText:self.feed.commentCount];
    }

}

@end








