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

const NSUInteger maxCardNum = 10;

@interface HomeViewController ()

<ZLSwipeableViewDataSource,
ZLSwipeableViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (nonatomic,weak) IBOutlet ZLSwipeableView *cardView;
@property (nonatomic,strong) NSMutableArray *myPlans;
//@property (nonatomic) NSUInteger currentCardIndex;
@end

@implementation HomeViewController

//-(NSUInteger)currentCardIndex
//{
//    if (_currentCardIndex > self.myPlans.count - 1) {
//        _currentCardIndex = 0 ;
//    }
//    return _currentCardIndex;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];

}
- (void)viewWillAppear:(BOOL)animated
{
    self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZLSwipeableViewDelegate


- (void)swipeableView:(ZLSwipeableView *)swipeableView didEndSwipingView:(UIView *)view atLocation:(CGPoint)location
{
    if (self.myPlans.count == 0) {
        self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];
        [self reloadInputViews];
//        [self nextViewForSwipeableView:self.cardView];
//        [self.cardView layoutIfNeeded];
    }
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {

    //could be improved when there is a view defined for no-myPlan-exist condition
    if (self.myPlans.count == 0) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:swipeableView.bounds];
    
    HomeCardView *contentView = [HomeCardView instantiateFromNib];
    
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:contentView];
    
    // This is important:
    // https://github.com/zhxnlai/ZLSwipeableView/issues/9
    NSDictionary *metrics = @{
                              @"height" : @(view.bounds.size.height),
                              @"width" : @(view.bounds.size.width)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    [view addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|[contentView(width)]"
      options:0
      metrics:metrics
      views:views]];
    [view addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|[contentView(height)]"
                          options:0
                          metrics:metrics
                          views:views]];
    //preset data
    if (self.myPlans.count > 0){
        Plan *currentPlan = self.myPlans.lastObject;
        contentView.dataImage = currentPlan.image;
        contentView.title = currentPlan.planTitle;
        contentView.subtitle = [NSString stringWithFormat:@"%d",self.myPlans.count];
        contentView.countDowns = @"????";
        [self.myPlans removeObject:currentPlan];
        
    }
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
//        UIImage *editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
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

@end
