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
@property (nonatomic) int buttomCardIndex;
@property (nonatomic,strong) UIImage *capturedImage;
@end

@implementation HomeViewController

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

- (int)buttomCardIndex{
    if (_buttomCardIndex < 0) {
        _buttomCardIndex = self.myPlans.count - 1;

    }else if (_buttomCardIndex > self.myPlans.count - 1){
        _buttomCardIndex = -1;
    }
    NSLog(@"----%d",self.myPlans.count+1 % _buttomCardIndex + 1);
    return _buttomCardIndex;
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


- (void)fetchMyplans
{
    self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self fetchMyplans];
    NSLog(@"%d",self.myPlans.count);
}

#pragma mark - 

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
        [self.cardView swipeTopViewToRight];
        [(Plan *)self.myPlans.lastObject deleteSelf:[AppDelegate getContext]];
        [self.myPlans removeLastObject];
        self.buttomCardIndex = -1;
        [self.cardView discardAllSwipeableViews];
        [self.cardView loadNextSwipeableViewsIfNeeded];
    }
}

#pragma mark - ZLSwipeableViewDelegate


- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location
{
    NSLog(@"buttom index %d",self.buttomCardIndex);
    NSLog(@"%d",self.myPlans.count);
    
}

- (BOOL)shouldLoadNextView:(ZLSwipeableView *)swipeableView
{
    if (!self.myPlans.count || self.buttomCardIndex < 0){
        return NO;
    }else{
        return YES;
    }
}


#pragma mark - ZLSwipeableViewDataSource

//always display the last object of myPlan
- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {

    //could be improved when there is a view defined for no-myPlan-exist condition

    UIView *view = [[UIView alloc] initWithFrame:swipeableView.bounds];

    HomeCardView *contentView = [HomeCardView instantiateFromNibWithSuperView:view];
    
    
    contentView.delegate = self; // for responsing more view button action !!
    
    //preset data
    
    Plan *plan = self.myPlans[--self.buttomCardIndex + 1];
    
    contentView.dataImage = plan.image;
    
    contentView.title = [NSString stringWithFormat:@"bindex %d",self.buttomCardIndex ];
    contentView.subtitle = [NSString stringWithFormat:@"mpindex %d",[self.myPlans indexOfObject:plan]];
    contentView.countDowns = nil;
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
