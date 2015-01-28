//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
#import "WishDetailCell.h"
#import "UINavigationItem+CustomItem.h"
#import "Theme.h"

@interface WishDetailViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIButton *cameraButton;
@property (nonatomic) CGFloat yVel;
@property (nonatomic) BOOL shouldShowSideWidgets;

@end

@implementation WishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    if (!self.plan) {
        self.view.backgroundColor = [Theme wishDetailBackgroundNone];
//        [self.view setOpaque:NO];
//        [self.view.layer setOpaque:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.shouldShowSideWidgets = YES;
    [self loadCamera];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.cameraButton removeFromSuperview];
}
- (void)loadCamera
{
    //load camera image
    UIImage *cameraIcon = [Theme wishDetailCameraDefault];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:cameraIcon forState:UIControlStateNormal];
    cameraButton.hidden = YES;
    [cameraButton setFrame:CGRectMake(self.tableView.frame.size.width - cameraIcon.size.width/2,
                                           self.tableView.frame.size.height - cameraIcon.size.height/2,
                                           cameraIcon.size.width/2,
                                           cameraIcon.size.height/2)];
    UIWindow *topView = [[UIApplication sharedApplication] keyWindow];
    [topView addSubview:cameraButton];
    
    //lock camera to buttom right corner
//    cameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-[cameraButton(==10)]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(cameraButton)]];
    
    [topView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[cameraButton(==10)]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(cameraButton)]];
    
    self.cameraButton = cameraButton;

}

- (void)setUpNavigationItem
{

    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popToRootViewControllerAnimated:)
                                         frame:frame];
    
    UIButton *composeBtn = [Theme buttonWithImage:[Theme navComposeButtonDefault]
                                       target:self
                                     selector:nil
                                        frame:frame];
    
    UIButton *shareBtn = [Theme buttonWithImage:[Theme navShareButtonDefault]
                                         target:self
                                       selector:nil
                                          frame:frame];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:shareBtn],
                                                [[UIBarButtonItem alloc] initWithCustomView:composeBtn]];

}


#pragma mark - Scroll view delegate (widget animation)

-  (void)displayWidget:(BOOL)shouldDisplay
{
    self.cameraButton.hidden = !shouldDisplay;
    for (WishDetailCell *cell in self.tableView.visibleCells){
        [UIView animateWithDuration:0.1 animations:^{
            [cell moveWidget:shouldDisplay];
        }];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self displayWidget:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self displayWidget:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
//    cell.textLabel.text = [NSString stringWithFormat:@"Row %@", @(indexPath.row)];
    
    return cell;
}

@end
