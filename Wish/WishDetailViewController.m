//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
#import "UIImageView+ImageCache.h"
#import "InvitationViewController.h"
@interface WishDetailViewController () <HeaderViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>
@property (nonatomic,strong) NSDictionary *textAttributes;
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation WishDetailViewController


#pragma mark setter and getters
- (void)setHeaderView:(HeaderView *)headerView{
    _headerView = headerView;
    _headerView.delegate = self;
    [_headerView updateHeaderWithPlan:self.plan];
    self.tableView.tableHeaderView = headerView;
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

        [self.fetchCenter updatePlan:self.plan.planId
                               title:self.plan.planTitle
                           isPrivate:self.plan.isPrivate.boolValue
                         description:self.plan.detailText
                          completion:^{
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
    
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];
    
    //初次拉数据
    [self loadMoreData];
}

- (void)loadMoreData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"feedId"];
    [self.fetchCenter getFeedsListForPlan:self.plan.planId
                                localList:localList
                                   onPage:self.currentPage
                               completion:^(NSNumber *currentPage, NSNumber *totalPage, BOOL isFollow)
    {
        if ([currentPage isEqualToNumber:totalPage]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            self.currentPage = @(currentPage.integerValue + 1);
            [self.tableView.mj_footer endRefreshing];
        }
        
        if (self.plan.isFollowed.boolValue != isFollow) {
            self.plan.isFollowed = @(isFollow);
            [self.plan.managedObjectContext save:nil];
        }
    }];
}

- (void)goBack{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
    self.tableFetchedRC.delegate = nil;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSUInteger numberOfPreservingFeeds = 20;
    NSArray *allFeeds = self.tableFetchedRC.fetchedObjects;
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
    [self setCurrenetBackgroundColor];

    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(goBack)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}
- (void)setCurrenetBackgroundColor{

    if (![self.tableView.backgroundView isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        
        //添加模糊
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        visualEffectView.frame = imgView.frame;
        [imgView addSubview:visualEffectView];

        //设置背影
        self.tableView.backgroundView = imgView;
        
        
        //下载图片
        NSURL *imageUrl = [self.fetchCenter urlWithImageID:self.plan.backgroundNum size:FetchCenterImageSize400];
     
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSString *localKey = [manager cacheKeyForURL:imageUrl];

        if ([manager diskImageExistsForURL:imageUrl]) {
            imgView.image = [manager.imageCache imageFromDiskCacheForKey:localKey];
            
        }else{
            self.tableView.backgroundColor = [UIColor blackColor];
            self.tableView.backgroundView = nil;
        }
    }else{
        self.tableView.backgroundColor = [UIColor blackColor];        
    }

}

#pragma mark - Fetched Results Controller delegate

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"plan.planId == %@",self.plan.planId];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}



- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
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
    Feed *feed = [self.tableFetchedRC objectAtIndexPath:indexPath];
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
    return self.tableFetchedRC.fetchedObjects.count;
}

- (WishDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(WishDetailCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.delegate = self;
    Feed *feed = [self.tableFetchedRC objectAtIndexPath:indexPath];
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
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //enter feed detail only when plan description text view is not being edited
    if (!self.headerView.descriptionTextView.isFirstResponder){
        Feed *feed = [self.tableFetchedRC objectAtIndexPath:indexPath];
        if (feed.feedId){ //prevent crash
            [self performSegueWithIdentifier:[self segueForFeed] sender:feed.feedId];
        }
    }
}

- (NSString *)segueForFeed{
    return @"showFeedDetailView";
}
#pragma mark - like and unlike

- (void)didPressedLikeOnCell:(WishDetailCell *)cell{
    //already increment/decrement like count locally,
    //the following request must respect the current cell.feed like/dislike status
    Feed *feed = [self.tableFetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    if (!feed.selfLiked.boolValue) {
        //send like request
        [self.fetchCenter likeFeed:feed completion:nil];
    }else{
        //send unlike request
        [self.fetchCenter unLikeFeed:feed completion:nil];
    }
}


#pragma mark - wish detail cell delegate
- (void)didPressedMoreOnCell:(WishDetailCell *)cell{
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
    
    if ([segue.identifier isEqualToString:@"showInvitationView"]) {
        InvitationViewController *ivc = segue.destinationViewController;
        ivc.titleText = @"分享事件给好友";
        ivc.imageUrl = [self.fetchCenter urlWithImageID:self.plan.backgroundNum size:FetchCenterImageSize50];
        ivc.sharedContentTitle = self.plan.planTitle;
        ivc.sharedContentDescription = self.plan.detailText ? self.plan.detailText : @"";
        ivc.h5Url = [NSString stringWithFormat:@"http://html.wexincloud.com/data/shier.all.html#/share/%@",self.plan.planId];
    }
}

- (void)didPressedCommentOnCell:(WishDetailCell *)cell{
    //进入动态详情并呼出键盘
    Feed *feed = [self.tableFetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
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

