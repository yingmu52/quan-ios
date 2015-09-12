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
#import "PopupView.h"
@interface WishDetailVCOwner () <UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ImagePickerDelegate,PopupViewDelegate>

//@property (nonatomic,strong) UIButton *logoButton;
//@property (nonatomic,strong) UILabel *labelUnderLogo;
//@property (nonatomic,strong) UIImage *capturedImage;
@property (nonatomic,strong) UIButton *cameraButton;
@property (nonatomic) CGFloat lastContentOffSet; // for camera animation
@property (nonatomic,strong) ImagePicker *imagePicker;
@end
@implementation WishDetailVCOwner


- (void)viewWillAppear:(BOOL)animated
{
    self.headerView.descriptionTextView.userInteractionEnabled = YES; //enable text view to enable owner edit permission
    [super viewWillAppear:animated];
    [self loadCornerCamera];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.cameraButton removeFromSuperview];
    
}

- (void)setUpNavigationItem{
    [super setUpNavigationItem];
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *planEditBtn = [Theme buttonWithImage:[Theme navComposeButtonDefault]
                                            target:self
                                          selector:@selector(editPlan)
                                            frame:frame];
    
    UIButton *shareBtn = [Theme buttonWithImage:[Theme navShareButtonDefault]
                                         target:self
                                       selector:nil
                                          frame:frame];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil action:nil];
    space.width = 25.0f;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:shareBtn],
                                                space,
                                                [[UIBarButtonItem alloc] initWithCustomView:planEditBtn]];
    
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
    
    CGFloat trailing = 58.0/640 * self.view.frame.size.width;
    CGFloat bottom = 32.0/1136 * self.view.frame.size.height;
    
    CGFloat width = cameraIcon.size.width/1.8;
    CGFloat height = cameraIcon.size.height/1.8;
    [cameraButton setFrame:CGRectMake(topView.frame.size.width - trailing - width,
                                      topView.frame.size.height - bottom - height,
                                      width,
                                      height)];
    [topView addSubview:cameraButton];
    
    [cameraButton addTarget:self action:@selector(showCamera)
           forControlEvents:UIControlEventTouchUpInside];
    self.cameraButton = cameraButton;
    
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
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"showPostFeed"]) {
        [segue.destinationViewController setImagesForFeed:sender];
        [segue.destinationViewController setPlan:self.plan];
    }
    if ([segue.identifier isEqualToString:@"showEditPage"]){
        [segue.destinationViewController setPlan:sender];
    }
}

- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (void)showCamera{
    self.cameraButton.hidden = YES;
    [self.imagePicker startPickingImageFromLocalSourceFor:self];
}

- (void)didFinishPickingImage:(NSArray *)images{
    self.cameraButton.hidden = NO;
    [self performSegueWithIdentifier:@"showPostFeed" sender:images];
}
- (void)didFailPickingImage{
    self.cameraButton.hidden = NO;
}


#pragma mark - wish detail cell delegate
- (void)didPressedMoreOnCell:(WishDetailCell *)cell{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [UIActionSheet showInView:window
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:@"删除"
            otherButtonTitles:@[@"分享这张照片"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"分享这张照片"]) {
            NSLog(@"share feed");
        }else if ([title isEqualToString:@"删除"]){
            
            NSString *popupViewTitle = [self isDeletingTheLastFeed] ?
            @"这是最后一条记录啦！\n这件事儿也会被删除哦~" : @"真的要删除这条记录吗？";
            
            PopupView *popupView = [PopupView showPopupDeleteinFrame:window.frame
                                                           withTitle:popupViewTitle];
            popupView.delegate = self;
            popupView.feed = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [window addSubview:popupView];
        }
    }];
}
#pragma mark - delete feed


- (BOOL)isDeletingTheLastFeed{
    return self.fetchedRC.fetchedObjects.count == 1;
}

- (void)popupViewDidPressConfirm:(PopupView *)popupView{
    Feed *feed = popupView.feed;
    if (feed.feedId && feed.plan.planId && feed.imageId){
        
        [self.fetchCenter deleteFeed:feed];
        
    }else if (!feed.feedId){ //local feed
        
        if ([self isDeletingTheLastFeed]){ // delete the last plan
            [self deletePlan];
        }else{
            [feed deleteSelf];
        }
    }
    [self popupViewDidPressCancel:popupView];

}

- (void)popupViewDidPressCancel:(PopupView *)popupView{
    [popupView removeFromSuperview];
}


- (void)deletePlan{
    //delete plan and pop back. Notice place deletion is cascade
    [self.plan deleteSelf];
    [self.navigationController popToRootViewControllerAnimated:YES];

}
#pragma mark - fetch center delegate

- (void)didFinishDeletingFeed:(Feed *)feed{
    if ([self isDeletingTheLastFeed]) {
        [self deletePlan];
    }else{
        [feed deleteSelf];
    }
}

- (NSString *)segueForFeed{
    return @"showFeedDetailFromOwner";
}

@end
