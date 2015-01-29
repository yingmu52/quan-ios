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
        _topThreeCache = [NSMutableArray new];
    }
    if (_topThreeCache.count > 3) {
        [_topThreeCache removeObjectAtIndex:0];
    }
    return _topThreeCache;
}


- (void)reloadCards{
    dispatch_queue_t reloadQ =  dispatch_queue_create("reload cards", NULL);
    dispatch_async(reloadQ, ^{
        self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];
        [self.topThreeCache removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.cardView discardAllSwipeableViews];
            [self.cardView loadNextSwipeableViewsIfNeeded];
        });
        
    });

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
    if (self.myPlans.count > maxCardNum){
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
    [self.topThreeCache removeObjectAtIndex:0];
    if (!self.topThreeCache.count && !self.myPlans.count) {
        [self reloadCards];
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
        //preset data
        Plan *plan = self.myPlans.lastObject;
        if (plan) {
            HomeCardView *contentView = [HomeCardView instantiateFromNibWithSuperView:view];
            contentView.delegate = self; // for responsing more view button action !!
            contentView.plan = plan;
            [self.topThreeCache addObject:plan]; //first object is the top card
            [self.myPlans removeLastObject];
        }
        return view;
    }
}

#pragma mark - Camera Util

- (IBAction)showCamera:(UIButton *)sender{
    UIImagePickerController *controller = [SystemUtil showCamera:self];
    if (controller) {
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        self.capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage]; // this line and next line is sequentally important
        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
//        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
//        NSLog(@"%@",NSStringFromCGSize(editedImage.size));
    }];
}




@end
