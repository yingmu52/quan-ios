//
//  PostDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostDetailViewController.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "ImagePicker.h"
#import "PostFeedViewController.h"
#import "FetchCenter.h"
@interface PostDetailViewController () <ImagePickerDelegate,FetchCenterDelegate>
@property (weak, nonatomic) IBOutlet UIView *cameraBackground;
//@property (nonatomic,strong) FetchCenter *fetchCenter;
//@property (nonatomic,strong) Plan *plan;
//@property (nonatomic,strong) NSArray *images;
@property (nonatomic,strong) ImagePicker *imagePicker;
@end
@implementation PostDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self borderiseCameraBackground];
}

- (void)borderiseCameraBackground{
    self.cameraBackground.layer.borderColor = [SystemUtil colorFromHexString:@"#33C6B4"].CGColor;
    self.cameraBackground.layer.borderWidth = 1.5f;
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backButton = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(goBack)
                                         frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    //set navigation bar title and color
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    
    self.navigationItem.title = self.titleFromPostView;
    
}

- (void)goBack{
//    if (self.plan) [self.plan deleteSelf];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostFeedFromPlanCreation"]) {
        PostFeedViewController *pfvc = (PostFeedViewController *)segue.destinationViewController;
        pfvc.assets = sender;
        pfvc.seugeFromPlanCreation = YES; // important!
        pfvc.navigationItem.title = self.titleFromPostView;
    }
}

#pragma mark - camera

- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (IBAction)toggleCamera:(UIButton *)sender {
    [self.imagePicker showPhotoLibrary:self];
}

- (IBAction)tapOnCameraBackground:(UITapGestureRecognizer *)tap{
    [self toggleCamera:nil];
}

- (void)didFinishPickingPhAssets:(NSArray *)assets{
    [self performSegueWithIdentifier:@"showPostFeedFromPlanCreation" sender:[assets mutableCopy]];
}

- (void)didFailPickingImage{
    [[[UIAlertView alloc] initWithTitle:@"无法获取图片" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)didFinishUploadingPlan:(Plan *)plan{
    self.navigationItem.rightBarButtonItem = nil;
    [self performSegueWithIdentifier:@"showPostFeedFromPlanCreation" sender:plan];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [[[UIAlertView alloc] initWithTitle:@"请求失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    self.navigationItem.rightBarButtonItem = nil;
//    if (self.plan) [self.plan deleteSelf];
}

@end
