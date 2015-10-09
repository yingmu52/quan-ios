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
#import "ImagePicker.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Theme.h"
#import "NavigationBar.h"

@interface MyPageViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,FetchCenterDelegate,ImagePickerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic,weak) IBOutlet UIImageView *profilePicture;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) IBOutlet UILabel *versionLabel;
@property (nonatomic,strong) ImagePicker *imagePicker;
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

    [self.fetchCenter checkVersion];
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame),324.0f / 1136 * CGRectGetHeight(self.tableView.frame));
    
    //设置头像
//    self.iconImageView.hidden = YES;
    NSString *newPicId = [User updatedProfilePictureId];
    if (newPicId){
        [self.profilePicture setImageWithURL:[self.fetchCenter urlWithImageID:newPicId size:FetchCenterImageSize200]
                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }else{
        self.profilePicture.image = [Theme menuLoginDefault];
    }
    
    //设置标题
    self.versionLabel.text = [NSString stringWithFormat:@"版本号: v%@",self.fetchCenter.buildVersion];
    
    //左返回图标
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [backButton setImage:[Theme navWhiteButtonDefault] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //导航透明
    NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
    [nav showClearBackground];
    
    //隐藏下方菜单
    self.tabBarController.tabBar.hidden = YES;
    
    //用于检测摇一摇
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //回复导航颜色
    NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
    [nav showDefaultBackground];
    
    [self resignFirstResponder];
}

#define GET_USER_INFO @"获取个人信息"
#define GET_LOCAL_LOGS @"获取请求日志"

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSArray *knownLists = @[@"100004",@"100014",@"100005",@"100007",@"100015",@"100001"]; //Vicky,R,Cliff,Amy,Jie,Xinyi

    if ([knownLists containsObject:[User uid]]) {
        BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK];
        
        NSString *testEnvTitle = isUsingInnerNetwork ? @"内网✔️" : @"内网";
        NSString *proEnvTitle = isUsingInnerNetwork ? @"外网" : @"外网✔️";
        if (motion == UIEventSubtypeMotionShake) {
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"此功能只对内部公开" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            //选择内网
            UIAlertAction *testEnv = [UIAlertAction actionWithTitle:testEnvTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (!isUsingInnerNetwork) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOULD_USE_INNER_NETWORK];
                    [self logout];
                    [self clearCoreData];
                }
            }];
            
            //选择外网
            UIAlertAction *proEnv = [UIAlertAction actionWithTitle:proEnvTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (isUsingInnerNetwork) {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOULD_USE_INNER_NETWORK];
                    [self logout];
                    [self clearCoreData];
                }
            }];
            
            //获取用户信息
            UIAlertAction *getUserInfo = [UIAlertAction actionWithTitle:GET_USER_INFO style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *userInfo = [NSString stringWithFormat:@"uid:%@\nukey:%@\npicUrl:%@",[User uid],[User uKey],[User updatedProfilePictureId]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:userInfo preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }];
            
            
            UIAlertAction *getRequestLog = [UIAlertAction actionWithTitle:GET_LOCAL_LOGS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self performSegueWithIdentifier:@"showLocalRequestLog" sender:nil];
            }];
            
            [actionSheet addAction:testEnv];
            [actionSheet addAction:proEnv];
            [actionSheet addAction:getUserInfo];
            [actionSheet addAction:getRequestLog];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        }        
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
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"退出后不会删除任何历史数据，下次登录依然可以使用帐号。" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self logout];
        }];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:logoutAction];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}


- (void)logout{    
    //delete user info, this lines must be below [self clearCoreData];
    [User updateOwnerInfo:[NSDictionary dictionary]];
    NSLog(@"%@",[User getOwnerInfo]);
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

- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (IBAction)tapOnCamera:(id)sender{
    [self.imagePicker showImagePickerForUploadProfileImage:self type:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    if (assets.count == 1 && [assets.firstObject isKindOfClass:[UIImage class]]) {
        self.profilePicture.image = assets.firstObject;
        [self.fetchCenter uploadNewProfilePicture:self.profilePicture.image];
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark fetchcenter Delegate

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

- (void)didFinishSettingPersonalInfo{
    NSLog(@"done");
}

@end






