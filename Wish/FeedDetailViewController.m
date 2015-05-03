//
//  FeedDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "Theme.h"
@interface FeedDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end

@implementation FeedDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    
    self.imageView.image = self.feed.image;
    self.textView.text = self.feed.feedTitle;
    self.dateLabel.text = [NSString stringWithFormat:@"%@",self.feed.createDate];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.likeCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",self.feed.commentCount];

    [self updateHeaderViewFrame];
}

- (void)updateHeaderViewFrame{
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 840.0f/1136 * self.tableView.frame.size.height;
    self.tableView.tableHeaderView.frame = frame;
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


@end
