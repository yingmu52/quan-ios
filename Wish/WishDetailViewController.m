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
#import "UIImage+ImageEffects.h"
#import "PostFeedViewController.h"
@interface WishDetailViewController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,NSFetchedResultsControllerDelegate,PostFeedViewControllerDelegate>
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
    [self showCenterIcon];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeCenterIcon];
    [self.cameraButton removeFromSuperview];

}


#pragma mark - setup views
- (void)loadCornerCamera
{
    //load camera image
    UIImage *cameraIcon = [Theme wishDetailCameraDefault];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:cameraIcon forState:UIControlStateNormal];
    cameraButton.hidden = YES;
    

    UIWindow *topView = [[UIApplication sharedApplication] keyWindow];

    CGFloat trailing = 3*58.0/640 * self.view.frame.size.width;
    CGFloat bottom = 5*32.0/1136 * self.view.frame.size.height;

    [cameraButton setFrame:CGRectMake(topView.frame.size.width - trailing,
                                      topView.frame.size.height - bottom,
                                      cameraIcon.size.width/2,
                                      cameraIcon.size.height/2)];
    [topView addSubview:cameraButton];
    
    //lock camera to buttom right corner
    //    cameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [topView addConstraints:[NSLayoutConstraint
//                             constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[cameraButton(%f)]|",trailing]
//                             options:NSLayoutFormatDirectionLeadingToTrailing
//                             metrics:nil
//                             views:NSDictionaryOfVariableBindings(cameraButton)]];
//    
//    [topView addConstraints:[NSLayoutConstraint
//                             constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[cameraButton(%f)]|",bottom]
//                             options:NSLayoutFormatDirectionLeadingToTrailing
//                             metrics:nil
//                             views:NSDictionaryOfVariableBindings(cameraButton)]];
    [cameraButton addTarget:self action:@selector(showCamera)
           forControlEvents:UIControlEventTouchUpInside];
    self.cameraButton = cameraButton;
    
}
- (void)setUpNavigationItem
{

    CGRect frame = CGRectMake(0,0, 25,25);
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

    self.tableView.backgroundColor = [self currenetBackgroundColor];

}

- (void)removeCenterIcon{
    [self.logoButton removeFromSuperview];
    [self.labelUnderLogo removeFromSuperview];
    
}
- (void)showCenterIcon{
    
    BOOL shouldShow = self.fetchedRC.fetchedObjects.count == 0; // && !self.logoButton && !self.labelUnderLogo;
    
    self.tableView.scrollEnabled = !shouldShow;
    self.cameraButton.hidden = !shouldShow;
    
    if (shouldShow){
        //set center logo
        UIImage *logo = [Theme wishDetailBackgroundNonLogo];
        
        CGFloat logoWidth = self.view.frame.size.width/2.5;
        CGPoint center = self.view.center;
        
        self.logoButton = [[UIButton alloc] initWithFrame:CGRectMake(center.x-logoWidth/2,
                                                                     center.y-logoWidth,
                                                                     logoWidth,logoWidth)];
        [self.logoButton setImage:logo forState:UIControlStateNormal];
        [self.logoButton addTarget:self action:@selector(showCamera)
                  forControlEvents:UIControlEventTouchUpInside];
        
        //set text under logo
        self.labelUnderLogo = [[UILabel alloc] initWithFrame:CGRectMake(0,self.logoButton.center.y + logoWidth/2 + 10.0,
                                                                        logoWidth*2, 20.0)];
        self.labelUnderLogo.center = CGPointMake(self.logoButton.center.x + 5.0,self.labelUnderLogo.center.y);
        NSMutableParagraphStyle *paStyle = [NSMutableParagraphStyle new];
        paStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:12.0],
                                NSParagraphStyleAttributeName:paStyle};
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"记录种下愿望这一刻吧！" attributes:attrs];
        self.labelUnderLogo.attributedText = str;
        
        [self.tableView addSubview:self.logoButton];
        [self.tableView addSubview:self.labelUnderLogo];
    }else{
        [self removeCenterIcon];
    }
    
}


#pragma mark - Fetched Results Controller delegate

- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = self.plan.managedObjectContext;
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    request.predicate = [NSPredicate predicateWithFormat:@"plan = %@",self.plan];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    [request setFetchBatchSize:3];
    
    //create FetchedResultsController with context, sectionNameKeyPath, and you can cache here, so the next work if the same you can use your cash file.
    NSFetchedResultsController *newFRC =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedRC = newFRC;
    _fetchedRC.delegate = self;
        NSError *error;
        [_fetchedRC performFetch:&error];
    return _fetchedRC;
    
    
}

- (void)controllerWillChangeContent:
(NSFetchedResultsController *)controller
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
        case NSFetchedResultsChangeInsert:
            [self.tableView
             insertRowsAtIndexPaths:@[newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView
             deleteRowsAtIndexPaths:@[indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            // dont't support move action
            break;
    }
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    self.tableView.backgroundColor = [self currenetBackgroundColor];

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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 580.0/1136*tableView.frame.size.height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedRC.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    cell.feed = [self.fetchedRC objectAtIndexPath:indexPath];
    return cell;
}


#pragma mark - camera

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showPostFeed"]) {
        PostFeedViewController *pfvc = (PostFeedViewController *)segue.destinationViewController;
        pfvc.navigationTitle = self.plan.planTitle;
        pfvc.previewImage = self.capturedImage;
        pfvc.delegate = self;
    }
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
        if (self.capturedImage) {
            [self performSegueWithIdentifier:@"showPostFeed" sender:nil];
            
        }
    }];
}


- (void)didFinishAddingTitleForFeed:(PostFeedViewController *)postFeedVC{
    [Feed createFeed:postFeedVC.titleForFeed
               image:self.capturedImage
              inPlan:self.plan];
    [self.headerView updateSubtitle:self.plan.feeds.count];

}
- (UIColor *)currenetBackgroundColor{

    if (!self.plan.image){
        return [Theme wishDetailBackgroundNone:self.tableView];
    }else{
        CGRect rect = self.tableView.bounds;
        rect.size.height *= 2;
        return [UIColor colorWithPatternImage:[SystemUtil darkLayeredImage:[self.plan.image applyLightEffect] inRect:rect]];
    }
    
}
@end

