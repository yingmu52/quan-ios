//
//  FeedDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "BFRImageViewController.h"
#import "CommentViewController.h"
#import "MainTabBarController.h"

#define FEEDDETAILCELLID @"FeedDetailCell"
@interface FeedDetailViewController () <CommentViewControllerDelegate>
@property (nonatomic,strong) FeedDetailHeader *headerView;
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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.mj_header = nil;
    //不要用beginRefreshing 因为会很淫荡地跳到页面下方
    [self loadMoreData];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 60;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //如果从消息页进来时，尝试定位到评论
    if (self.message){
        Comment *comment = [Comment fetchID:self.message.commentId
                     inManagedObjectContext:self.message.managedObjectContext];
        if (comment) {
            NSIndexPath *indexPath = [self.tableFetchedRC indexPathForObject:comment];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}


- (void)loadMoreData{
    NSString *feedId = self.feed ? self.feed.mUID : self.message.feedsId;
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"mUID"];
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
             self.feed = [Feed fetchID:feedId inManagedObjectContext:self.appDelegate.managedObjectContext];
         }
          
     }];
}


- (void)setFeed:(Feed *)feed{
    _feed = feed;
    if (!feed) {
        self.title = @"该内容不存在";
    }else{
        [self updateHeaderInfoForFeed:feed];
    }
    
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
    if ([self.feed.plan.owner.mUID isEqualToString:[User uid]]) {
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
        @"这是最后一条记录啦！\n这件话题夹也会被删除哦~" : @"真的要删除这条记录吗？";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            if (self.feed.plan.feeds.count == 1){
                                                                [self.fetchCenter deletePlanId:self.feed.plan.mUID completion:^{
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

- (void)didTapOnImageViewAtIndex:(NSInteger)index{
    NSMutableArray *imageURLs = [NSMutableArray array];
    for (NSString *imageId in self.feed.imageIdArray) {
        NSURL *imgUrl = [self.fetchCenter urlWithImageID:imageId size:FetchCenterImageSize800];
        [imageURLs addObject:imgUrl];
    }
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initForPeekWithImageSource:imageURLs];
    imageVC.initialIndex = index;
    [self presentViewController:imageVC animated:YES completion:nil];
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
        [self heightForText:self.feed.mTitle withFontSize:FONTSIZE referenceWidth:width];
        
        CGRect frame = CGRectMake(0,0, CGRectGetHeight(self.view.frame), height);
        _headerView = [FeedDetailHeader instantiateFromNib:frame];
        _headerView.delegate = self;
        self.tableView.tableHeaderView = _headerView;
        
        
        NSArray *images = [self.feed imageIdArray].count > 1 ? [self.feed imageIdArray] : @[self.feed.mCoverImageId];
        
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
    self.headerView.titleTextLabel.attributedText = [[NSAttributedString alloc] initWithString:feed.mTitle
                                                                                    attributes:self.textAttributes];
    self.headerView.dateLabel.text = [SystemUtil stringFromDate:feed.mCreateTime];
    [self.headerView setLikeButtonText:feed.likeCount];
    [self.headerView setCommentButtonText:feed.commentCount];
    [self.headerView.likeButton setSelected:feed.selfLiked.boolValue];
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableFetchedRC.fetchedObjects.count;
}

- (void)configureCell:(MSTableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [cell.ms_imageView1 downloadImageWithImageId:comment.owner.mCoverImageId size:FetchCenterImageSize100];
    cell.ms_textView.text = comment.mTitle;
    
    NSDictionary *userNameAttribute = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00B9C0"]};
    
    NSString *userAstring = comment.owner.mTitle.length > 0 ? comment.owner.mTitle : [NSString stringWithFormat:@"用户%@",comment.owner.mUID];
    
    if (comment.idForReply && comment.nameForReply) { //this is a reply. format: 回复<color_userName>:content
        
        NSString *userBstring = comment.nameForReply.length > 0 ? comment.nameForReply : [NSString stringWithFormat:@"用户%@",comment.idForReply];
        NSMutableAttributedString *userA = [[NSMutableAttributedString alloc] initWithString:userAstring
                                                                                  attributes:userNameAttribute];
        NSMutableAttributedString *reply = [[NSMutableAttributedString alloc] initWithString:@"回复"];
        NSMutableAttributedString *userB = [[NSMutableAttributedString alloc] initWithString:userBstring
                                                                                  attributes:userNameAttribute];
        
        [userA appendAttributedString:reply];
        [userA appendAttributedString:userB];
        cell.ms_title.attributedText = userA;
    }else{
        
        cell.ms_title.attributedText = [[NSAttributedString alloc] initWithString:userAstring
                                                                            attributes:userNameAttribute];
    }
    cell.ms_dateLabel.text = [self.dateFormatter stringFromDate:comment.mCreateTime];
    
    //从消息页进来时，highligh对应评论的cell
    if ([self.message.commentId isEqualToString:comment.mUID]) {
        cell.backgroundColor = [SystemUtil colorFromHexString:@"#E7F0ED"];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEEDDETAILCELLID forIndexPath:indexPath];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([User isVisitor]) {
        MainTabBarController *mvc = (MainTabBarController *)self.tabBarController;
        [mvc showVisitorLoginAlert];
    }else{
        Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
        if (![comment.owner.mUID isEqualToString:[User uid]]) { //the comment is from other user
            [self performSegueWithIdentifier:@"showCommentViewController" sender:comment];
        }else{
            [self deleteActionAtIndexPath:indexPath];
        }
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.tableFetchedRC objectAtIndexPath:indexPath];
    return [comment.owner.mUID isEqualToString:[User uid]];
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
    [super didFailSendingRequest];
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
        cvc.feed = self.feed;
        cvc.delegate = self;
    }
}
#pragma mark - comment

-(void)didPressedCommentButton:(FeedDetailHeader *)headerView{
    if ([User isVisitor]) {
        MainTabBarController *mvc = (MainTabBarController *)self.tabBarController;
        [mvc showVisitorLoginAlert];
    }else{
        [self performSegueWithIdentifier:@"showCommentViewController" sender:nil];
    }
}

#pragma mark - fetched results controller

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feed.mUID == %@",self.feed ? self.feed.mUID : self.message.feedsId];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mCreateTime" ascending:YES]];
    }
    return _tableFetchRequest;
}


- (void)commentViewDidFinishInsertingComment{
    [self.headerView setCommentButtonText:self.feed.commentCount];
    NSIndexPath *buttomIndex = [NSIndexPath indexPathForRow:self.tableFetchedRC.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:buttomIndex
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

@end








