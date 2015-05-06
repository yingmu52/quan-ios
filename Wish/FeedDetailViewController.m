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
@interface FeedDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView* tableHeaderViewWrapper;
@property (weak, nonatomic) IBOutlet UILabel* headerLabel;

@end

@implementation FeedDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupContents];
}

- (void)setupContents{
    self.imageView.image = self.feed.image;
    self.textView.text = self.feed.feedTitle;
    self.headerLabel.text = self.feed.feedTitle;
    self.dateLabel.text = [NSString stringWithFormat:@"%@",self.feed.createDate];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.likeCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.commentCount];
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


@end








