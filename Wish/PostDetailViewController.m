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
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    //set navigation bar title and color
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    self.title = self.titleFromPostView;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostFeedFromPlanCreation"]) {
        PostFeedViewController *pfvc = (PostFeedViewController *)segue.destinationViewController;
        Plan *plan = sender;
        pfvc.plan = plan;
        pfvc.imageForFeed = plan.image;
        pfvc.seugeFromPlanCreation = YES; // important!
    }
}

#pragma mark - camera

- (IBAction)toggleCamera:(UIButton *)sender {
    [ImagePicker startPickingImageFromLocalSourceFor:self];
}

- (IBAction)tapOnCameraBackground:(UITapGestureRecognizer *)tap{
    [self toggleCamera:nil];
}

- (void)didFinishPickingImage:(UIImage *)image{
    //activity indicator
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0, 25,25)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    //create plan
    FetchCenter *fc = [[FetchCenter alloc] init];
    fc.delegate = self;
    [fc uploadToCreatePlan:[Plan createPlan:self.titleFromPostView privacy:NO image:image]];
}
- (void)didFailPickingImage{
#warning didFailPickingImage_PostDetail
}

- (void)didFinishUploadingPlan:(Plan *)plan{
    self.navigationItem.rightBarButtonItem = nil;
    [self performSegueWithIdentifier:@"showPostFeedFromPlanCreation" sender:plan];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
#warning didFailSendingRequestWithInfo_PostDetail
}

@end
