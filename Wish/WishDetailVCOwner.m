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
@interface WishDetailVCOwner () <UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>

@property (nonatomic,strong) UIButton *cameraButton;
@property (nonatomic) CGFloat lastContentOffSet; // for camera animation
@property (nonatomic,strong) ImagePicker *imagePicker;
@end
@implementation WishDetailVCOwner


- (void)viewWillAppear:(BOOL)animated
{
    self.headerView.descriptionTextView.userInteractionEnabled = YES; //enable text view to enable owner edit permission
    [super viewWillAppear:animated];
    self.cameraButton.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeCameraButton];
}

#pragma mark - 主人有权限的操作

-(void)deletePlan{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除的事件不恢复哦！"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  //执行删除操作
                                  [self.fetchCenter deletePlanId:self.plan.planId completion:^{
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }];
                              }];
    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    //添加主人有权限操作的选项
    UIAlertAction *editOption = [UIAlertAction actionWithTitle:@"编辑"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
    {
        //跳转到编辑页
        [self performSegueWithIdentifier:@"showEditPage" sender:self.plan];        
    }];
    
    UIAlertAction *deleteOption = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action)
    {
        //删除
        [self deletePlan];
    }];

    [self.moreActionSheet addAction:deleteOption];
    [self.moreActionSheet addAction:editOption];
}

- (void)showMoreOptions{
    [self removeCameraButton];
    [super showMoreOptions];
}
#pragma mark - setup views

- (void)removeCameraButton{
    [self.cameraButton removeFromSuperview];
    self.cameraButton = nil;
}
- (UIButton *)cameraButton{
    if (!_cameraButton) {
        //load camera image
        UIImage *cameraIcon = [Theme wishDetailCameraDefault];
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setImage:cameraIcon forState:UIControlStateNormal];
        _cameraButton.hidden = NO;
        
        
        UIWindow *topView = [[UIApplication sharedApplication] keyWindow];
        
        CGFloat trailing = 58.0/640 * self.view.frame.size.width;
        CGFloat bottom = 32.0/1136 * self.view.frame.size.height;
        
        CGFloat width = cameraIcon.size.width/1.8;
        CGFloat height = cameraIcon.size.height/1.8;
        [_cameraButton setFrame:CGRectMake(topView.frame.size.width - trailing - width,
                                          topView.frame.size.height - bottom - height,
                                          width,
                                          height)];
        [topView addSubview:_cameraButton];
        
        [_cameraButton addTarget:self action:@selector(showCamera)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
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
        PostFeedViewController *pfvc = segue.destinationViewController;
        pfvc.assets = sender;
        pfvc.plan = self.plan;
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
    [self.imagePicker showPhotoLibrary:self];
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    self.cameraButton.hidden = NO;
    [self performSegueWithIdentifier:@"showPostFeed" sender:assets];
}
- (void)didFailPickingImage{
    self.cameraButton.hidden = NO;
}


#pragma mark - wish detail cell delegate
- (void)didPressedMoreOnCell:(WishDetailCell *)cell{

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action)
    {
        NSString *popupViewTitle = [self isDeletingTheLastFeed] ?
        @"这是最后一条记录啦！\n这件事儿也会被删除哦~" : @"真的要删除这条记录吗？";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:popupViewTitle
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action)
        {
            //执行删除操作
            Feed *feed = [self.tableFetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            if (feed.feedId && feed.plan.planId && feed.imageId){
                [self.fetchCenter deleteFeed:feed completion:^{
                    if ([self isDeletingTheLastFeed]) {
                        [self deletePlan];
                    }else{
                        [feed deleteSelf];
                    }
                }];
            }else if (!feed.feedId){ //local feed
                if ([self isDeletingTheLastFeed]){ // delete the last plan
                    [self deletePlan];
                }else{
                    [feed deleteSelf];
                }
            }
        }];
        [alert addAction:confirm];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    [actionSheet addAction:delete];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - delete feed


- (BOOL)isDeletingTheLastFeed{
    return self.tableFetchedRC.fetchedObjects.count == 1;
}

//- (void)deletePlan{
//    //delete plan and pop back. Notice place deletion is cascade
//    [self.plan deleteSelf];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//
//}

#pragma mark - fetch center delegate


- (NSString *)segueForFeed{
    return @"showFeedDetailFromOwner";
}

@end
