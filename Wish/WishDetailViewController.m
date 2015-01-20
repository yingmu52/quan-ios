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
@interface WishDetailViewController ()
@property (nonatomic,strong) UIButton *cameraButton;
@property (nonatomic) CGFloat scrollOffset;
@property (nonatomic) BOOL shouldShowSideWidgets;
@end

@implementation WishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollOffset = 0.0;
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
    

//    CGFloat x = self.tableView.frame.size.width - 58 - cameraIcon.size.width;
//    CGFloat y = self.tableView.frame.size.height - 32 - cameraIcon.size.height;
//    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, cameraIcon.size.width, cameraIcon.size.height)];
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
                                      selector:@selector(popViewControllerAnimated:)
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)determineApperance:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > self.scrollOffset){
        
        // scrolls down.
        self.scrollOffset = scrollView.contentOffset.y;
        self.cameraButton.hidden = NO;
        for (WishDetailCell *cell in self.tableView.visibleCells){
            [UIView animateWithDuration:0.1 animations:^{
                [cell showLikeAndComment];

            }];
        }
    }
    else
    {
        // scrolls up.
        self.scrollOffset = scrollView.contentOffset.y;
        self.cameraButton.hidden = YES;
        for (WishDetailCell *cell in self.tableView.visibleCells){
            [UIView animateWithDuration:0.1 animations:^{
                [cell dismissLikeAndComment];
                
            }];
        }
    }

   
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self determineApperance:scrollView];
}
#pragma mark - Table view delegate

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
