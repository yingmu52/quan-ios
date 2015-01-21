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

@interface HomeViewController () <ZLSwipeableViewDataSource,ZLSwipeableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,weak) IBOutlet ZLSwipeableView *cardView;
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
    [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
}
- (void)openMenu{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeLeft:(UIView *)view {
    NSLog(@"did swipe left");
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
        didSwipeRight:(UIView *)view {
    NSLog(@"did swipe right");
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
       didCancelSwipe:(UIView *)view {
    NSLog(@"did cancel swipe");
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
    NSLog(@"did start swiping at location: x %f, y %f", location.x, location.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
          swipingView:(UIView *)view
           atLocation:(CGPoint)location
          translation:(CGPoint)translation {
    NSLog(@"swiping at location: x %f, y %f, translation: x %f, y %f",
          location.x, location.y, translation.x, translation.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
    NSLog(@"did end swiping at location: x %f, y %f", location.x, location.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
           didSwipeUp:(UIView *)view{
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeDown:(UIView *)view{
    
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    //return nil;
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
