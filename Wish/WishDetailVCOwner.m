//
//  WishDetailVCOwner.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCOwner.h"
#import "PostFeedViewController.h"
#import "EditWishViewController.h"
#import "ImagePicker.h"
#import "UIActionSheet+Blocks.h"

@interface WishDetailVCOwner () <UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>
@property (nonatomic) BOOL shouldShowSideWidgets;
@property (nonatomic,strong) UIButton *logoButton;
@property (nonatomic,strong) UILabel *labelUnderLogo;
//@property (nonatomic,strong) UIImage *capturedImage;
@property (nonatomic,strong) UIButton *cameraButton;

@property (nonatomic) CGFloat lastContentOffSet; // for camera animation
@end
@implementation WishDetailVCOwner


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.shouldShowSideWidgets = YES;
    [self loadCornerCamera];
    [self showCenterIcon];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeCenterIcon];
    [self.cameraButton removeFromSuperview];
    
}

- (void)setUpNavigationItem{
    [super setUpNavigationItem];
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *composeBtn = [Theme buttonWithImage:[Theme navComposeButtonDefault]
                                           target:self
                                         selector:@selector(editPlan)
                                            frame:frame];
    
//    UIButton *shareBtn = [Theme buttonWithImage:[Theme navShareButtonDefault]
//                                         target:self
//                                       selector:nil
//                                          frame:frame];
    
//    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:shareBtn],
//                                                [[UIBarButtonItem alloc] initWithCustomView:composeBtn]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:composeBtn];
    

    
}
- (void)editPlan{
    [self performSegueWithIdentifier:@"showEditPage" sender:self.plan];
}


#pragma mark - setup views

- (void)loadCornerCamera
{
    //load camera image
    UIImage *cameraIcon = [Theme wishDetailCameraDefault];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:cameraIcon forState:UIControlStateNormal];
    cameraButton.hidden = NO;
    
    
    UIWindow *topView = [[UIApplication sharedApplication] keyWindow];
    
    CGFloat trailing = 3*58.0/640 * self.view.frame.size.width;
    CGFloat bottom = 5*32.0/1136 * self.view.frame.size.height;
    
    [cameraButton setFrame:CGRectMake(topView.frame.size.width - trailing,
                                      topView.frame.size.height - bottom,
                                      cameraIcon.size.width/1.9,
                                      cameraIcon.size.height/1.9)];
    [topView addSubview:cameraButton];
    
    [cameraButton addTarget:self action:@selector(showCamera)
           forControlEvents:UIControlEventTouchUpInside];
    self.cameraButton = cameraButton;
    
}


- (void)removeCenterIcon{
    [self.logoButton removeFromSuperview];
    [self.labelUnderLogo removeFromSuperview];
    
}


- (void)showCenterIcon{
    
    BOOL shouldShow = self.fetchedRC.fetchedObjects.count == 0; // && !self.logoButton && !self.labelUnderLogo;
    
    self.tableView.scrollEnabled = !shouldShow;
//    self.cameraButton.hidden = !shouldShow;
    
    if (shouldShow){
        //set center logo
        UIImage *logo = [Theme wishDetailBackgroundNonLogo];
        
        CGFloat logoWidth = self.view.frame.size.width/2.5;
        CGPoint center = self.view.center;
        
        self.logoButton = [[UIButton alloc] initWithFrame:CGRectMake(center.x-logoWidth/2,
                                                                     center.y-logoWidth,
                                                                     logoWidth,logoWidth)];
        [self.logoButton setImage:logo forState:UIControlStateNormal];
        [self.logoButton addTarget:self action:@selector(showCamera)
                  forControlEvents:UIControlEventTouchUpInside];
        
        //set text under logo
        self.labelUnderLogo = [[UILabel alloc] initWithFrame:CGRectMake(0,self.logoButton.center.y + logoWidth/2 + 10.0,
                                                                        logoWidth*2, 20.0)];
        self.labelUnderLogo.center = CGPointMake(self.logoButton.center.x + 5.0,self.labelUnderLogo.center.y);
        NSMutableParagraphStyle *paStyle = [NSMutableParagraphStyle new];
        paStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:12.0],
                                NSParagraphStyleAttributeName:paStyle};
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"记录种下愿望这一刻吧！" attributes:attrs];
        self.labelUnderLogo.attributedText = str;
        
        [self.tableView addSubview:self.logoButton];
        [self.tableView addSubview:self.labelUnderLogo];
    }else{
        [self removeCenterIcon];
    }
    
}


#pragma mark - Scroll view delegate (widget animation)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffSet = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.lastContentOffSet < scrollView.contentOffset.y) {
        //hide camera
        if (self.cameraButton.isUserInteractionEnabled) [self animateCameraIcon:YES];
        
    }else if (self.lastContentOffSet > scrollView.contentOffset.y) {
        //show camera
        if (!self.cameraButton.isUserInteractionEnabled) [self animateCameraIcon:NO];
    }

}

- (void)animateCameraIcon:(BOOL)shouldHideCamera{
    CGFloat movingDistance = CGRectGetHeight(self.view.frame) * 0.5f;
    if (shouldHideCamera){
        [UIView animateWithDuration:1.0 animations:^{
            self.cameraButton.center = CGPointMake(self.cameraButton.center.x,
                                                   self.cameraButton.center.y + movingDistance);
            self.cameraButton.userInteractionEnabled = NO;
        }];
    }else{
        [UIView animateWithDuration:0.7 animations:^{
            self.cameraButton.center = CGPointMake(self.cameraButton.center.x,
                                                   self.cameraButton.center.y - movingDistance);
        }];
        self.cameraButton.userInteractionEnabled = YES;
    }
}
#pragma mark - camera

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showPostFeed"]) {
        [segue.destinationViewController setImageForFeed:sender];
        [segue.destinationViewController setPlan:self.plan];
    }
    if ([segue.identifier isEqualToString:@"showEditPage"]){
        [segue.destinationViewController setPlan:sender];
    }

}
- (void)showCamera{
    self.cameraButton.hidden = YES;
    [ImagePicker startPickingImageFromLocalSourceFor:self];
}
- (void)didFinishPickingImage:(UIImage *)image{
    self.cameraButton.hidden = NO;
    [self performSegueWithIdentifier:@"showPostFeed" sender:image];
}
- (void)didFailPickingImage{
    self.cameraButton.hidden = NO;
}


#pragma mark - fetch results controller

- (void)fetchResultsControllerDidInsert{
    [self.tableView setContentOffset:CGPointZero animated:YES]; //scroll to top
}

#pragma mark - wish detail cell delegate
- (void)didPressedMoreOnCell:(WishDetailCell *)cell{
    [UIActionSheet showInView:self.tableView withTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@[@"分享这张照片"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"分享这张照片"]) {
            NSLog(@"share feed");
        }else if ([title isEqualToString:@"删除"]){
            
        }
    }];
}


#pragma mark - delete feed

@end
