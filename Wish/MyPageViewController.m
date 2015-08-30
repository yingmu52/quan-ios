//
//  MyPageViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MyPageViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "UIActionSheet+Blocks.h"
#import "ImagePicker.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Theme.h"
@interface MyPageViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,FetchCenterDelegate,ImagePickerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic,weak) IBOutlet UIImageView *profilePicture;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) IBOutlet UILabel *versionLabel;
@end

@implementation MyPageViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.iconImageView.hidden = YES;
    [self.fetchCenter checkVersion];
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame),324.0f / 1136 * CGRectGetHeight(self.tableView.frame));
    
    NSString *newPicId = [User updatedProfilePictureId];
    if (newPicId){
        [self.profilePicture setImageWithURL:[self.fetchCenter urlWithImageID:newPicId]
                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }else{
        self.profilePicture.image = [Theme menuLoginDefault];
    }
    
    self.versionLabel.text = [self.fetchCenter.buildVersion stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

#define GET_USER_INFO @"获取个人信息"
#define GET_LOCAL_LOGS @"获取请求日志"

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK];
    
    NSString *titleForInnerNetWork = isUsingInnerNetwork ? @"内网✔️" : @"内网";
    NSString *titleFOrOutterNetWork = isUsingInnerNetwork ? @"外网" : @"外网✔️";
    if (motion == UIEventSubtypeMotionShake) {
        [UIActionSheet showInView:self.view
                        withTitle:@"选择环境"
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:nil
                otherButtonTitles:@[titleForInnerNetWork,titleFOrOutterNetWork,GET_USER_INFO,GET_LOCAL_LOGS]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:titleForInnerNetWork] &&
                                !isUsingInnerNetwork){
                                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOULD_USE_INNER_NETWORK];
                                 [self logout];
                                 [self clearCoreData];
                             }
                             if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:titleFOrOutterNetWork] &&
                                isUsingInnerNetwork){
                                 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOULD_USE_INNER_NETWORK];
                                 [self logout];
                                 [self clearCoreData];
                             }
                             if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:GET_USER_INFO]){
                                 [[[UIAlertView alloc] initWithTitle:@"用户信息"
                                                             message:[NSString stringWithFormat:@"uid:%@\nukey:%@\npicUrl:%@",[User uid],[User uKey],[User updatedProfilePictureId]]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil] show];
                             }
                             if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:GET_LOCAL_LOGS]){
                                 [self performSegueWithIdentifier:@"showLocalRequestLog" sender:nil];
                             }
                             
                         }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 104.0f / 1136 * self.view.frame.size.height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return 48.0f / 1136 * self.view.frame.size.height;
    }else{
        return 0.0f;
    }
}


- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 2){ //退出登录不做处理
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = [SystemUtil colorFromHexString:@"#E7F0ED"];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 2){ //退出登录不做处理
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = [SystemUtil colorFromHexString:@"#F6FAF9"];
    }
}

#pragma mark - Functionality


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (indexPath.row == 0){ //个人资料
            [self performSegueWithIdentifier:@"showProfileView" sender:nil];
        }
        if (indexPath.row == 1){ // 完成的事儿
            [self performSegueWithIdentifier:@"ShowAcheivementList" sender:nil];
        }
    }
    
    if (indexPath.section == 1){
        if (indexPath.row == 2){ //用户反馈
            [self performSegueWithIdentifier:@"showFeedbackView" sender:nil];
        }
    }
    
    if (indexPath.section == 2){
        [UIActionSheet showInView:self.view
                        withTitle:@"退出后不会删除任何历史数据，下次登录依然可以使用帐号。"
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:@"退出登录"
                otherButtonTitles:nil
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"退出登录"]){
                                 [self logout];
                             }
                         }];
    }
}


- (void)logout{    
    //delete user info, this lines must be below [self clearCoreData];
    [User updateOwnerInfo:nil];
    [self performSegueWithIdentifier:@"showLoginViewFromMyPage" sender:nil];
}

- (void)clearCoreData{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
//    request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId != %@",[User uid]];
    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * objects = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    //error handling goes here
    for (Plan *plan in objects) {
        [delegate.managedObjectContext deleteObject:plan];
    }
    [delegate saveContext];
}


#pragma mark - upload image 
- (IBAction)tapOnCamera:(id)sender{
    [ImagePicker startPickingImageFromLocalSourceFor:self];
}

- (void)didFinishPickingImage:(UIImage *)image{
    self.profilePicture.image = image;
    [self.fetchCenter uploadNewProfilePicture:image];
}

- (void)didFailPickingImage{
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark fetchcenter Delegate

- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
}

- (void)didFinishUploadingPictureForProfile{
    [self.fetchCenter setPersonalInfo:[User userDisplayName]
                               gender:[User gender]
                              imageId:[User updatedProfilePictureId]
                           occupation:[User occupation]
                         personalInfo:[User personalDetailInfo]];
}

- (void)didFinishCheckingNewVersion:(BOOL)hasNewVersion{
    self.iconImageView.hidden = !hasNewVersion;
    NSLog(@"%@",hasNewVersion ? @"has new version" : @"this is latest version");
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    NSLog(@"%@",info);
}

- (void)didFinishSettingPersonalInfo{
    NSLog(@"done");
}

@end






