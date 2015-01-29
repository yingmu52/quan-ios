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
#import "SystemUtil.h"
#import "Feed+FeedCRUD.h"


@interface WishDetailViewController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic) CGFloat yVel;
@property (nonatomic) BOOL shouldShowSideWidgets;
@property (nonatomic,strong) UIButton *logoButton;
@property (nonatomic,strong) UILabel *labelUnderLogo;
@property (nonatomic,strong) UIImage *capturedImage;
@property (nonatomic,strong) UIButton *cameraButton;


@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@end

@implementation WishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.shouldShowSideWidgets = YES;
    [self loadCornerCamera];
    self.headerView.plan = self.plan; //set plan to header for updaing info
    [self fetchFeeds];
    
}

- (void)fetchFeeds{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    request.predicate = [NSPredicate predicateWithFormat:@"plan = %@",self.plan];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];

    self.fetchedRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                         managedObjectContext:self.plan.managedObjectContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
}
- (void)setFetchedRC:(NSFetchedResultsController *)fetchedRC
{
    _fetchedRC = fetchedRC;
    if (_fetchedRC.fetchRequest) {
        [_fetchedRC performFetch:nil];
    }
    
    if (_fetchedRC.fetchedObjects.count > 0) {
        //remove logo and underlogo text
        [self.logoButton removeFromSuperview];
        [self.labelUnderLogo removeFromSuperview];
        self.tableView.scrollEnabled = YES;
        self.view.backgroundColor = [Theme wishDetailBackgroundNone:self.view];

    }else{
        [self showCenterIcon];
        self.tableView.scrollEnabled = NO;
        self.cameraButton.hidden = NO;

    }
    [self.tableView reloadData];
}


- (void)showCenterIcon{
    self.view.backgroundColor = [Theme wishDetailBackgroundNone:self.view];
    
    //set center logo
    UIImage *logo = [Theme wishDetailBackgroundNonLogo];
    
    CGFloat logoWidth = self.view.frame.size.width/2.5;
    CGPoint center = self.view.center;
    
    UIButton *logoButton = [[UIButton alloc] initWithFrame:CGRectMake(center.x-logoWidth/2,
                                                                      center.y-logoWidth,
                                                                      logoWidth,logoWidth)];
    [logoButton setImage:logo forState:UIControlStateNormal];
    [logoButton addTarget:self action:@selector(showCamera)
         forControlEvents:UIControlEventTouchUpInside];
    
    //set text under logo
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, logoButton.center.y + logoWidth/2 + 20.0, self.view.frame.size.width, 20.0)];
    NSMutableParagraphStyle *paStyle = [NSMutableParagraphStyle new];
    paStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSParagraphStyleAttributeName:paStyle};
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"记录种下愿望这一刻吧！" attributes:attrs];
    label.attributedText = str;
    
    
    self.logoButton = logoButton;
    self.labelUnderLogo = label;
    [self.view addSubview:self.logoButton];
    [self.view addSubview:self.labelUnderLogo];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.cameraButton removeFromSuperview];
}
- (void)loadCornerCamera
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
                               constraintsWithVisualFormat:@"V:[cameraButton(>=12)]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(cameraButton)]];
    
    [topView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[cameraButton(>=12)]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(cameraButton)]];
    [cameraButton addTarget:self action:@selector(showCamera)
           forControlEvents:UIControlEventTouchUpInside];
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



#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.fetchedRC.sections.count == 1) {
        rows = self.fetchedRC.fetchedObjects.count;
    }
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    cell.feed = [self.fetchedRC objectAtIndexPath:indexPath];
//    cell.textLabel.text = [NSString stringWithFormat:@"Row %@", @(indexPath.row)];
    
    return cell;
}


- (void)showCamera{
    UIImagePickerController *controller = [SystemUtil showCamera:self];
    if (controller) {
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage]; // this line and next line is sequentally important
        //        NSLog(@"%@",NSStringFromCGSize(editedImage.size));
        //create Task
        [Feed createFeed:self.plan.planTitle image:self.capturedImage inPlan:self.plan];
        [self fetchFeeds];

    }];
}

@end

