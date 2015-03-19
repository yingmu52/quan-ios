//
//  WishDetailVCOwner.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCOwner.h"
#import "PostFeedViewController.h"
@interface WishDetailVCOwner () <UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate>
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
                                         selector:nil
                                            frame:frame];
    
    UIButton *shareBtn = [Theme buttonWithImage:[Theme navShareButtonDefault]
                                         target:self
                                       selector:nil
                                          frame:frame];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:shareBtn],
                                                [[UIBarButtonItem alloc] initWithCustomView:composeBtn]];
    

    
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
                                      cameraIcon.size.width/2,
                                      cameraIcon.size.height/2)];
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
        NSLog(@"up");
        //hide camera
        if (self.cameraButton.isUserInteractionEnabled) [self animateCameraIcon:YES];
        
    }else if (self.lastContentOffSet > scrollView.contentOffset.y) {
        NSLog(@"down");
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
}
- (void)showCamera{
    UIImagePickerController *controller = [SystemUtil showCamera:self];
    if (controller) {
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage]; // this line and next line is sequentally important
        //        NSLog(@"%@",NSStringFromCGSize(editedImage.size));
        //create Task
        if (capturedImage) {
//            Feed *feed = [Feed createFeedWithImage:capturedImage inPlan:self.plan];
            [self performSegueWithIdentifier:@"showPostFeed" sender:capturedImage];
        }
    }];
}
@end
