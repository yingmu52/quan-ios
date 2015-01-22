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
@property (nonatomic,strong) Plan *currentPlan;

#warning !*^(*&^%&*()_(*&^%$
@property (nonatomic,strong) UIImage *capturedImage;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];

}

- (Plan *)currentPlan
{
    if (self.myPlans.count > 0) {
        _currentPlan = self.myPlans.lastObject;
    }
    return _currentPlan;
}

- (void)fetchMyplans
{
    self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self fetchMyplans];
    NSLog(@"%d",self.myPlans.count);
}
- (void)viewDidLayoutSubviews
{
    self.cardView.delegate = self;
    self.cardView.dataSource = self;
}

- (void)setUpNavigationItem
{
    [self.cardView layoutIfNeeded];

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
- (void)openMenu{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}



#pragma mark - 

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
        [self.cardView swipeTopViewToRight];
        [self.currentPlan deleteSelf:[AppDelegate getContext]];
    }
}

#pragma mark - ZLSwipeableViewDelegate


- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location
{
    if (!self.myPlans.count) {
        [self fetchMyplans];
    }
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location
{
    [self.myPlans removeObject:self.currentPlan];

}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {

    //could be improved when there is a view defined for no-myPlan-exist condition
    if (self.myPlans.count == 0) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:swipeableView.bounds];

    HomeCardView *contentView = [HomeCardView instantiateFromNibWithSuperView:view];
    
    
    contentView.delegate = self; // for responsing more view button action !!
    
    //preset data
    contentView.dataImage = self.currentPlan.image;
    contentView.title = self.currentPlan.planTitle;
    contentView.subtitle = [NSString stringWithFormat:@"%d",self.myPlans.count];
    contentView.countDowns = @"????";
//    self.currentCardIndex ++ ;

    return view;
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
