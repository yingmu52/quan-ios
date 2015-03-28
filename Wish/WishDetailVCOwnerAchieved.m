
//  WishDetailOwnerAchieved.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCOwnerAchieved.h"
#import "PopupView.h"
@interface WishDetailVCOwnerAchieved () <PopupViewDelegate>

@end

@implementation WishDetailVCOwnerAchieved


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupBadageImageView];
}

- (void)setupBadageImageView{
    UIImage *image;
    if (self.plan.planStatus.integerValue == PlanStatusFinished) image = [Theme achieveBadageLabelSuccess];
    if (self.plan.planStatus.integerValue == PlanStatusGiveTheFuckingUp) image = [Theme achieveBadageLabelFail];
    self.headerView.badgeImageView.image = image;
    self.headerView.badgeImageView.hidden = NO;
}


- (void)setUpNavigationItem{
    [super setUpNavigationItem];
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                           target:self
                                         selector:@selector(deletePlan)
                                            frame:frame];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
}

-(void)deletePlan{

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    PopupView *popupView = [PopupView showPopupDeleteinFrame:keyWindow.frame];
    popupView.delegate = self;

    [keyWindow addSubview:popupView];
}

- (void)popupViewDidPressCancel:(PopupView *)popupView{
    [popupView removeFromSuperview];
}
- (void)popupViewDidPressConfirm:(PopupView *)popupView{
    [self.plan deleteSelf];
    [self popupViewDidPressCancel:popupView];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
