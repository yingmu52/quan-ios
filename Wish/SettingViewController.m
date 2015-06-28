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
@interface SettingViewController () <UIGestureRecognizerDelegate,FetchCenterDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) UIView *currentView;

@property (nonatomic,strong) UIColor *normalBackground;

@property (nonatomic,weak) IBOutlet UIImageView *iconImageView;

@property (nonatomic,strong) NSString *innerNetworkTitle;
@property (nonatomic,strong) NSString *outerNetworkTitle;
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


- (NSString *)innerNetworkTitle{
    BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK];
    return isUsingInnerNetwork ? @"内网✔️" : @"内网";
}

- (NSString *)outerNetworkTitle{
    BOOL isUsingInnerNetwork = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK];
    return isUsingInnerNetwork ? @"外网" : @"外网✔️";
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择环境"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
        [sheet addButtonWithTitle:self.innerNetworkTitle];
        [sheet addButtonWithTitle:self.outerNetworkTitle];
        [sheet showInView:self.view];
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
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"退出后不会删除任何历史数据，下次登录依然可以使用帐号。"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"退出登录"
                                                        otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
//        [self logout];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"退出登录"]){
        [self logout];
    }
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.innerNetworkTitle] &&
       ![[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOULD_USE_INNER_NETWORK];
        [self logout];
    }
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.outerNetworkTitle] &&
       [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOULD_USE_INNER_NETWORK];
        [self logout];
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






