//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeViewController.h"
#import "UINavigationItem+CustomItem.h"
#import "Theme.h"
#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ZLSwipeableView.h"
#import "HomeCardView.h"
#import "Plan+PlanCRUD.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "PostViewController.h"

const NSUInteger maxCardNum = 10;

@interface HomeViewController ()

<ZLSwipeableViewDataSource,
ZLSwipeableViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
HomeCardViewDelegate>

@property (nonatomic,weak) IBOutlet ZLSwipeableView *cardView;

@property (nonatomic,strong) NSMutableArray *myPlans;


@property (nonatomic,strong) UIImage *capturedImage;

@property (nonatomic,strong) NSMutableArray *topThreeCache;

@end

@implementation HomeViewController

- (NSMutableArray *)topThreeCache
{
    if (!_topThreeCache) {
        _topThreeCache = [NSMutableArray arrayWithCapacity:3];
    }
    if (_topThreeCache.count > 3) {
        [_topThreeCache removeObjectAtIndex:0];
    }
    return _topThreeCache;
}


- (void)reloadCards{
    self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];
    [self.cardView discardAllSwipeableViews];
    [self.cardView loadNextSwipeableViewsIfNeeded];
    [self.topThreeCache removeAllObjects];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadCards];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];

}

- (void)viewDidLayoutSubviews
{
    self.cardView.delegate = self;
    self.cardView.dataSource = self;
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self
                                      selector:@selector(openMenu)
                                         frame:frame];
    
    UIButton *addBtn = [Theme buttonWithImage:[Theme navAddDefault]
                                       target:self
                                     selector:@selector(addWish)
                                        frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    [self.cardView layoutIfNeeded];

}

- (void)openMenu{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark - db operation



- (void)addWish{
    if (self.myPlans.count == maxCardNum){
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"Come the fuck on! life is too short for too many goddamn plans"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }else{
        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
    }
}


#pragma mark - 

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
        Plan *plan = self.topThreeCache.firstObject;
        [plan deleteSelf:[AppDelegate getContext]];
        [self.cardView swipeTopViewToRight];
        [self reloadCards];

    }
}

#pragma mark - ZLSwipeableViewDelegate
- (void)swipeableView:(ZLSwipeableView *)swipeableView didEndSwipingView:(UIView *)view atLocation:(CGPoint)location
{

    if (!self.topThreeCache.count) {
        [self reloadCards];
    }else{
        [self.topThreeCache removeObjectAtIndex:0];
    }
    
}

#pragma mark - ZLSwipeableViewDataSource

//always display the last object of myPlan
- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {

    UIView *view;
    if (!self.myPlans.count) {
        return nil;
    }else{
        
        view = [[UIView alloc] initWithFrame:swipeableView.bounds];
        HomeCardView *contentView = [HomeCardView instantiateFromNibWithSuperView:view];
        contentView.delegate = self; // for responsing more view button action !!
        
        //preset data
        Plan *plan = self.myPlans.lastObject;
        contentView.plan = plan;
        [self.topThreeCache addObject:plan]; //first object is the top card
        [self.myPlans removeLastObject];
        return view;
    }
}

#pragma mark - Camera Util

- (IBAction)showCamera:(UIButton *)sender{
    UIImagePickerController *controller = [[self class] showCamera:self];
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
        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];

//        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
//        NSLog(@"%@",NSStringFromCGSize(editedImage.size));
    }];
}

+ (UIImagePickerController *)showCamera:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate{
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return nil;
    }
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    controller.allowsEditing = YES;
    controller.delegate = delegate;
    return controller;
}


#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostFromHome"]) {
        PostViewController *pvc = segue.destinationViewController;
        pvc.capturedImage = self.capturedImage;
    }
}
@end
