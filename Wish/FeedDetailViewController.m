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
@interface FeedDetailViewController () <FetchCenterDelegate,CommentAcessaryViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView* tableHeaderViewWrapper;
@property (weak, nonatomic) IBOutlet UILabel* headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) FetchCenter *fetchCenter;

@property (strong,nonatomic) CommentAcessaryView *commentView;
@end

@implementation FeedDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupContents];
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
    return 10;
}

- (FeedDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FEEDDETAILCELLID forIndexPath:indexPath];
    
    NSString *content = [NSString stringWithFormat:@"%@",[NSUUID UUID]];
    cell.contentLabel.text = content;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.commentView.feedInfoBackground.hidden = NO; // feed info section is for replying
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
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
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

#pragma mark - comment

- (IBAction)comment:(UIButton *)sender{
    self.commentView.feedInfoBackground.hidden = YES; // feed info section is for replying
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.commentView];
}

#pragma mark - comment accessary view delegate 
- (void)didPressSend:(CommentAcessaryView *)cav{
    [self.fetchCenter commentOnFeed:self.feed content:cav.textField.text];
}

#pragma mark - fetch center delegate 
- (void)didFinishCommentingFeed:(Feed *)feed{
    feed.commentCount = @(feed.commentCount.integerValue + 1);
//    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
    [self.commentView removeFromSuperview];
    self.commentView.textField.text = @"";
}
@end








