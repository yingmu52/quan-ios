//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//
#import "HomeViewController.h"
#import "PostFeedViewController.h"
#import "Theme.h"
#import "HomeCardView.h"
#import "Plan.h"
#import "Feed.h"
#import "AppDelegate.h"
#import "WishDetailViewController.h"
#import "HomeCardFlowLayout.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "ImagePicker.h"
#import "ViewForEmptyEvent.h"
#import "UIImageView+ImageCache.h"
#import "NZCircularImageView.h"
#import "UIImageView+ImageCache.h"
#import "StationViewController.h"

const NSUInteger maxCardNum = 10;
@interface HomeViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate,
HomeCardViewDelegate,
UIActionSheetDelegate,
ImagePickerDelegate,
ViewForEmptyEventDelegate,StationViewControllerDelegate>
@property (nonatomic,weak) Plan *currentPlan;
@property (nonatomic,weak) ViewForEmptyEvent *guideView;
@property (nonatomic,strong) ImagePicker *imagePicker;
@end
@implementation HomeViewController
- (void)updateNavigationTitle{
    NSArray *plans = self.collectionFetchedRC.fetchedObjects;
    if (plans.count > 0) {
        NSInteger page = self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame);
        self.navigationItem.title = [NSString stringWithFormat:@"%@/%@",@(page + 1),@(plans.count)];
    }else{
        self.navigationItem.title = nil;
    }
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateNavigationTitle];
}

- (NSFetchRequest *)collectionFetchRequest{
    if (!_collectionFetchRequest) {
        _collectionFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        
        _collectionFetchRequest.predicate = [NSPredicate predicateWithFormat:@"owner.mUID == %@ && planStatus == %d",[User uid],PlanStatusOnGoing];
        
        _collectionFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mCreateTime" ascending:NO]];
    }
    return _collectionFetchRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self addLongPressGesture];
    
    self.collectionView.mj_header = nil;
    self.collectionView.mj_footer = nil;
    [self loadNewData];
}

- (void)loadNewData{
    NSArray *localList = [self.collectionFetchedRC.fetchedObjects valueForKey:@"mUID"];
    [self.fetchCenter getPlanListForOwnerId:[User uid]
                                  localList:localList
                                 completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.collectionFetchedRC.fetchedObjects.count) {
        [self setUpEmptyView];
    }
}
- (void)addLongPressGesture{
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lp.delaysTouchesBegan = YES;
    lp.minimumPressDuration = 0.3;
    [self.collectionView addGestureRecognizer:lp];
}

- (void)setUpNavigationItem
{
    //1.左上角个人头像图标
    NZCircularImageView *myIcon = [[NZCircularImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    myIcon.backgroundColor = [UIColor lightGrayColor];
    NSString *newPicId = [User updatedProfilePictureId];
    myIcon.userInteractionEnabled = YES;
    myIcon.gestureRecognizers = @[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfileView)]];
    if (newPicId){
        [myIcon downloadImageWithImageId:newPicId size:FetchCenterImageSize100];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myIcon];
}

- (void)showProfileView{
    [self performSegueWithIdentifier:@"showMyPageFromHome" sender:nil];
}

#pragma mark - image picker
- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}
- (void)didPressCameraOnCard:(HomeCardView *)cardView{
    if (self.collectionFetchedRC.fetchedObjects.count) {
        self.currentPlan = [self.collectionFetchedRC objectAtIndexPath:[self.collectionView indexPathForCell:cardView]];
        [self.imagePicker showPhotoLibrary:self];
    }
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    [self performSegueWithIdentifier:@"ShowPostFeedFromHome" sender:@[assets,self.currentPlan]];
}
#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPostFeedFromHome"]) {
        PostFeedViewController *pfvc = segue.destinationViewController;
        NSArray *array = sender;
        pfvc.assets = array.firstObject;
        pfvc.plan = array.lastObject;
    }
    
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
        [segue.destinationViewController setPlan:sender];
    }
    
    if ([segue.identifier isEqualToString:@"showStationView"]) {
        StationViewController *svc = segue.destinationViewController;
        svc.delegate = self;
        NSArray *obj = (NSArray *)sender;
        svc.indexPath = obj.firstObject;
        svc.cardImage = obj[1];
        svc.longPress = obj.lastObject;
    }
    segue.destinationViewController.hidesBottomBarWhenPushed = YES;
    
}

#pragma mark - Station View Delegate;

- (void)didFinishAction:(StationViewSelection)selection forIndexPath:(NSIndexPath *)indexPath{
    
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    if (selection == StationViewSelectionDelete) {
        //删除事件
        [self.fetchCenter deletePlanId:plan.mUID completion:nil];
    }
    if (selection == StationViewSelectionFinish) {
        //完成归档
        [self.fetchCenter updatePlanId:plan.mUID
                            planStatus:PlanStatusFinished
                            completion:nil];
    }
    NSLog(@"%@",indexPath);
}

#pragma mark -  UICollectionView methods
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    if (plan) {
        if (longPress.state == UIGestureRecognizerStateBegan) {
            HomeCardView *cell = (HomeCardView *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"showStationView" sender:@[indexPath,cell.imageView.image,longPress]];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:plan];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.collectionFetchedRC) {
        [super controllerDidChangeContent:controller];
        if (!controller.fetchedObjects.count){
            [self setUpEmptyView];
        }else{
            self.collectionView.hidden = NO;
            if (self.guideView){
                [self.guideView removeFromSuperview];
            }
        }
    }
}

#pragma mark - implement parent class abstract methods
- (void)configureCollectionViewCell:(HomeCardView *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    [cell.imageView downloadImageWithImageId:plan.mCoverImageId size:FetchCenterImageSize800];
    cell.titleLabel.text = plan.mTitle;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@条记录  %@人关注",plan.tryTimes,plan.followCount];
    cell.delegate = self;
    [cell layoutIfNeeded]; //fixed auto layout error on iphone 5s or above
}
#pragma mark - Handling 0 Events Situation
- (void)setUpEmptyView{
    self.collectionView.hidden = YES;
    self.navigationItem.title = nil;
    [self.view addSubview:self.guideView];
}
- (ViewForEmptyEvent *)guideView{
    if (!_guideView){
        //        CGFloat width = 568.0/640 * CGRectGetWidth(self.view.frame);
        //        CGFloat height = 590.0/1136 * CGRectGetHeight(self.view.frame);
        CGFloat leftMargin = 30.0f/640 * CGRectGetWidth(self.view.frame);
        CGFloat width = CGRectGetWidth(self.view.frame) - leftMargin * 2;
        CGFloat height = 590.0 *width / 568;
        CGRect rect = CGRectMake(leftMargin,13,width,height); //13 is angle height, see ViewForEmptyEvent.xib
        _guideView = [ViewForEmptyEvent instantiateFromNib:rect];
        _guideView.delegate = self;
    }
    return _guideView;
}
- (void)didPressButton:(ViewForEmptyEvent *)view{
    [view removeFromSuperview];
    [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
}
@end
