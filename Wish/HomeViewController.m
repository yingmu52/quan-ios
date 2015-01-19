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
@interface HomeViewController () <ZLSwipeableViewDataSource>

@property  (nonatomic,strong) CustomBarItem *menuButton;
@property (nonatomic,strong) CustomBarItem *addButton;

@property (nonatomic,weak) IBOutlet ZLSwipeableView *cardView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self.cardView layoutIfNeeded];
}

- (void)viewDidLayoutSubviews
{
    self.cardView.dataSource = self;
}
- (void)setMenuButton:(CustomBarItem *)menuButton
{
    _menuButton = menuButton;
    [_menuButton addTarget:self
                  selector:@selector(openMenu)
                     event:UIControlEventTouchUpInside];
    [_menuButton setOffset:5];
}

- (void)setAddButton:(CustomBarItem *)addButton
{
    _addButton = addButton;
    [_addButton addTarget:self
                 selector:@selector(addWish)
                    event:UIControlEventTouchUpInside];
    [_addButton setOffset:-5];
}
- (void)setUpNavigationItem
{
    self.menuButton = [self.navigationItem setItemWithImage:[Theme navMenuDefault]
                                                       size:CGSizeMake(30,30)
                                                   itemType:left];
    self.addButton = [self.navigationItem setItemWithImage:[Theme navAddDefault]
                                                       size:CGSizeMake(30,30)
                                                   itemType:right];
}

- (void)addWish{
    
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

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    UIView *view = [[UIView alloc] initWithFrame:swipeableView.bounds];
    HomeCardView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"HomeCardView"
                                   owner:self
                                 options:nil] firstObject];
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


@end
