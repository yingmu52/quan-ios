//
//  SettingViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "SettingViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "UIActionSheet+Blocks.h"
@interface SettingViewController () <UIGestureRecognizerDelegate,FetchCenterDelegate>
@property (nonatomic,weak) IBOutlet UIImageView *iconImageView;
@end

@implementation SettingViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.iconImageView.hidden = YES;
    [self checkUpdate];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"设置";
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}


//- (NSString *)innerNetworkTitle{
//    BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK];
//    return isUsingInnerNetwork ? @"内网✔️" : @"内网";
//}
//
//- (NSString *)outerNetworkTitle{
//    BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK];
//    return isUsingInnerNetwork ? @"外网" : @"外网✔️";
//}

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
                            }
                            if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:titleFOrOutterNetWork] &&
                                isUsingInnerNetwork){
                                 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOULD_USE_INNER_NETWORK];
                                 [self logout];
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
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                     target:self
                                   selector:@selector(dismissModalViewControllerAnimated:)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 104.0f / 1136 * self.view.frame.size.height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 45.0f / 1136 * self.view.frame.size.height;
    }else if (section == 1){
        return 30.0f / 1136 * self.view.frame.size.height;
    }else if (section == 2){
        return 431.0f / 1136 * self.view.frame.size.height;
    }else{
        return 0.0f;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    cell.backgroundColor = [SystemUtil colorFromHexString:@"#E7F0ED"];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [SystemUtil colorFromHexString:@"#F6FAF9"];

}

#pragma mark - Functionality


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
    //delete plans that do not belong to self in core data
    [self clearCoreData];

    //delete user info, this lines must be below [self clearCoreData];
    [User updateOwnerInfo:nil];

    [self showLoginView];
}

- (void)showLoginView{
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"]
                       animated:NO
                     completion:nil];
}

- (void)clearCoreData{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId != %@",[User uid]];
    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * objects = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    //error handling goes here
    for (Plan *plan in objects) {
        [delegate.managedObjectContext deleteObject:plan];
    }
    [delegate saveContext];
}

#pragma mark - check update
- (void)checkUpdate{
    FetchCenter *fc = [[FetchCenter alloc] init];
    fc.delegate = self;
    [fc checkVersion];
}

- (void)didFinishCheckingNewVersion:(BOOL)hasNewVersion{
    self.iconImageView.hidden = !hasNewVersion;
    NSLog(@"%@",hasNewVersion ? @"has new version" : @"this is latest version");
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    NSLog(@"%@",info);
}
@end






