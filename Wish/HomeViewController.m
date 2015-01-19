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
@interface HomeViewController () <ZLSwipeableViewDataSource,ZLSwipeableViewDelegate>

//@property  (nonatomic,strong) CustomBarItem *menuButton;
//@property (nonatomic,strong) CustomBarItem *addButton;

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
//- (void)setMenuButton:(CustomBarItem *)menuButton
//{
//    _menuButton = menuButton;
//    [_menuButton addTarget:self
//                  selector:@selector(openMenu)
//                     event:UIControlEventTouchUpInside];
//    [_menuButton setOffset:5];
//}
//
//- (void)setAddButton:(CustomBarItem *)addButton
//{
//    _addButton = addButton;
//    [_addButton addTarget:self
//                 selector:@selector(addWish)
//                    event:UIControlEventTouchUpInside];
//    [_addButton setOffset:-5];
//}


- (void)setUpNavigationItem
{
    [self.cardView layoutIfNeeded];
    
    
//    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [menuBtn addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
//    [menuBtn setImage:[Theme navMenuDefault] forState:UIControlStateNormal];
//    menuBtn.frame = frame;
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

//    self.menuButton = [self.navigationItem setItemWithImage:[Theme navMenuDefault]
//                                                       size:CGSizeMake(30,30)
//                                                   itemType:left];
//    self.addButton = [self.navigationItem setItemWithImage:[Theme navAddDefault]
//                                                       size:CGSizeMake(30,30)
//                                                   itemType:right];
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

- (void)swipeableView:(ZLSwipeableView *)swipeableView
           didSwipeUp:(UIView *)view{
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeDown:(UIView *)view{
    
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
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


@end
