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
#import "SDImageCache.h"
#import "MBProgressHUD.h"

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

    [self.fetchCenter checkVersion:^(BOOL hasNewVersion) {
        self.iconImageView.hidden = !hasNewVersion;
    }];
    
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame),324.0f / 1136 * CGRectGetHeight(self.tableView.frame));
    
    //设置头像
//    self.iconImageView.hidden = YES;
    NSString *newPicId = [User updatedProfilePictureId];
    if (newPicId){
        [self.profilePicture setImageWithURL:[self.fetchCenter urlWithImageID:newPicId size:FetchCenterImageSize200]
                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    //设置标题
    self.versionLabel.text = [NSString stringWithFormat:@"用户ID: %@  版本号: v%@",[User uid],self.fetchCenter.buildVersion];
    
    //左返回图标
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [backButton setImage:[Theme navWhiteButtonDefault] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    //手势开启菜单
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSecretMenu)];
    [tap setNumberOfTapsRequired:3];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //导航透明
    NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
    [nav showClearBackground];
    
//    //用于检测摇一摇
//    [self becomeFirstResponder];

    //检测自己是否在白名单
    [self.fetchCenter checkWhitelist:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //回复导航颜色
    NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
    [nav showDefaultBackground];
    
//    [self resignFirstResponder];
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
        if (indexPath.row == 0) {
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/quan-li-shi/id1140426882?ls=1&mt=8"];
            UIApplication *app = [UIApplication sharedApplication];
            if ([app canOpenURL:url]) {
                [app openURL:url];
            }
        }
        if (indexPath.row == 1) {
            
            //清除本地所以图片
            SDImageCache *imageCache = [SDImageCache sharedImageCache];

            NSNumber *fileSize = @([imageCache getSize] / 1024 / 1024);
            
            if (fileSize.integerValue > 0) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                                                          animated:YES];
                hud.label.text = @"清除中...";
                [imageCache clearDiskOnCompletion:^{
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = [NSString stringWithFormat:@"已清理临时文件 %@ MB",fileSize];
                    [hud hideAnimated:YES afterDelay:1.0];
                }];
            }else{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                                                          animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = [NSString stringWithFormat:@"暂无临时文件"];
                [hud hideAnimated:YES afterDelay:1.0];
            }
            
            
            //Garbage fucking collection
            [AppDelegate clearCoreData:YES];
        }
        if (indexPath.row == 2){ //用户反馈
            [self performSegueWithIdentifier:@"showFeedbackView" sender:nil];
        }
    }
    
    if (indexPath.section == 2){
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"退出后不会删除任何历史数据，下次登录依然可以使用帐号。" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [AppDelegate logout];
        }];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:logoutAction];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}


#pragma mark - 上传头像

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
        [self.fetchCenter uploadNewProfilePicture:self.profilePicture.image
                                       completion:^(NSArray *imageIds)
        {
            [self.fetchCenter setPersonalInfo:[User userDisplayName]
                                       gender:[User gender]
                                      imageId:[User updatedProfilePictureId]
                                   occupation:[User occupation]
                                 personalInfo:[User personalDetailInfo]
                                   completion:^{
                                       NSLog(@"done");
                                   }];
        }];
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationController.navigationBar.hidden = NO;
    segue.destinationViewController.hidesBottomBarWhenPushed = YES;
}

#pragma mark - 内网菜单

- (void)showSecretMenu{
    BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_TESTURL];
    //支持摇一摇的条件是 1. 外网的已知id 2. 用户在内网
    if ([User isSuperUser] || isUsingInnerNetwork) {
        
        NSString *testEnvTitle = isUsingInnerNetwork ? @"内网✔️" : @"内网";
        NSString *proEnvTitle = isUsingInnerNetwork ? @"外网" : @"外网✔️";

        
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"此功能只对内部公开" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        //选择内网
        UIAlertAction *testEnv = [UIAlertAction actionWithTitle:testEnvTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (!isUsingInnerNetwork) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOULD_USE_TESTURL];
                [AppDelegate logout];
                [AppDelegate clearCoreData:NO];
            }
        }];
        
        //选择外网
        UIAlertAction *proEnv = [UIAlertAction actionWithTitle:proEnvTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isUsingInnerNetwork) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOULD_USE_TESTURL];
                [AppDelegate logout];
                [AppDelegate clearCoreData:NO];
            }
        }];
        
        //获取用户信息
        UIAlertAction *getUserInfo = [UIAlertAction actionWithTitle:@"获取个人信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *userInfo = [NSString stringWithFormat:@"uid:%@\n ukey:%@\n deviceToken:%@",[User uid],[User uKey],[User deviceToken]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:userInfo
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"点击复制到粘帖板"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [[UIPasteboard generalPasteboard] setString:userInfo];
                              }]];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
        //获取请求日志
        UIAlertAction *getRequestLog = [UIAlertAction actionWithTitle:@"获取请求日志" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"showLocalRequestLog" sender:nil];
        }];
        
        
        //远程控制
        UIAlertAction *callSpider;
        
        if ([[SPIntrospect sharedIntrospector] isOpen]) {
            callSpider = [UIAlertAction actionWithTitle:@"马上停止可怕的通灵之术"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                          {
                              [[SPIntrospect sharedIntrospector] closeSpider];
                          }];
            
        }else{
            callSpider = [UIAlertAction actionWithTitle:@"通灵之术：召唤阎罗溢"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                          {
                              //启动Spider
                              [self startSpider];
                              
                              //让用户复制Device Token
                              NSString *deviceToken = [User deviceToken];
                              NSString *message = [NSString stringWithFormat:@"把这串咒语念给阎罗溢听：%@",deviceToken];
                              UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"阎罗溢【🦁】已从天而降"
                                                                                             message:message
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                              [alert addAction:[UIAlertAction actionWithTitle:@"点击复制到粘帖板"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action)
                                                {
                                                    [[UIPasteboard generalPasteboard] setString:deviceToken];
                                                }]];
                              [self presentViewController:alert animated:YES completion:nil];
                          }];
        }
        
        
        [actionSheet addAction:testEnv];
        [actionSheet addAction:proEnv];
        [actionSheet addAction:getUserInfo];
        [actionSheet addAction:getRequestLog];
        [actionSheet addAction:callSpider];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)startSpider{
    [[SPIntrospect sharedIntrospector] setSpiderId:[User deviceToken]];
    [[SPIntrospect sharedIntrospector] openSpider];
}

@end






