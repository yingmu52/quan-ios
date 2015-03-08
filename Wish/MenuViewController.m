//
//  MenuViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "UIImageView+WebCache.h"

#import "UIViewController+ECSlidingViewController.h"
#import "Third Party/TencentOpenAPI.framework/Headers/TencentOAuth.h"
#import "Third Party/TencentOpenAPI.framework/Headers/TencentApiInterface.h"
typedef enum {
    MenuTableLogin = 0,
    MenuTableWishList,
    MenuTableJourney,
    MenuTableDiscover,
    MenuTableFollow
}MenuTable;

@interface MenuViewController () <TencentSessionDelegate>
@property (nonatomic) BOOL isLogin;
@property (nonatomic,strong) TencentOAuth *tencentOAuth;
@end

@implementation MenuViewController


- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue
{
    //after returning to menue view
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set menu background image
    self.tableView.backgroundColor = [Theme menuBackground];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 6 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRef = tableView.frame.size.height;
    CGFloat heightLogin = heightRef * 220 / 1136;
    CGFloat heightOther = (heightRef - heightLogin)/5;
    if (indexPath.row == MenuTableLogin){
        return heightLogin;
    }else if (indexPath.row <= MenuTableFollow + 1){
        return heightOther;
    }else return 0;

}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.backgroundColor = cell.backgroundColor.CGColor;
}
- (MenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell;
    if (indexPath.row != 5){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"
                                               forIndexPath:indexPath];
        
        // Configure the cell...
        if (indexPath.row == MenuTableLogin) {
            if (![SystemUtil isUserLogin]) {
                cell.menuImageView.image = [Theme menuLoginDefault];
                cell.menuTitle.text = @"登录";
            }else{
                [cell.menuImageView sd_setImageWithURL:[SystemUtil userProfilePictureURL]
                                      placeholderImage:[Theme menuLoginDefault]];
                cell.menuTitle.text = [SystemUtil userDisplayName];
            }

        }else if (indexPath.row == MenuTableWishList){
            cell.menuImageView.image = [Theme menuWishListDefault];
            cell.menuImageView.highlightedImage = [Theme menuWishListSelected];
            cell.menuTitle.text = @"愿望列表";
        }else if (indexPath.row == MenuTableJourney){
            cell.menuImageView.image = [Theme menuJourneyDefault];
            cell.menuImageView.highlightedImage = [Theme menuJourneySelected];
            cell.menuTitle.text = @"我的历程";
        }else if (indexPath.row == MenuTableDiscover){
            cell.menuImageView.image = [Theme menuDiscoverDefault];
            cell.menuImageView.highlightedImage = [Theme menuDiscoverSelected];
            cell.menuTitle.text = @"发现愿望";
        }else if (indexPath.row == MenuTableFollow){
            cell.menuTitle.text = @"关注动态";
            cell.menuImageView.image = [Theme menuFollowDefault];
            cell.menuImageView.highlightedImage = [Theme menuFollowSelected];
        }

    }else if (indexPath.row == 5){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BottomCellLogout"
                                               forIndexPath:indexPath];
    }else return nil;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    switch (indexPath.row) {
        case MenuTableLogin:
            [self login];
            return;
            break;
        case MenuTableWishList:
            identifier = @"showWishList";
            break;
        case MenuTableJourney:
            identifier = @"ShowAcheivementList";
            break;
        case MenuTableFollow:
            identifier = @"ShowFollowingFeed";
            break;
        case MenuTableDiscover:
            identifier = @"ShowDiscoveryList";
            break;
        default:
            break;
    }
    [self performSegueWithIdentifier:identifier sender:nil];
}


- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCell:tableView at:indexPath];

}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCell:tableView at:indexPath];
}
- (void)toggleCell:(UITableView *)tableView at:(NSIndexPath *)indexPath
{
    MenuCell *selectedCell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [selectedCell.menuImageView setHighlighted:!selectedCell.menuImageView.isHighlighted];

}

#pragma mark - login

- (TencentOAuth *)tencentOAuth{
    if (!_tencentOAuth) {
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"222222" andDelegate:self];
        _tencentOAuth.redirectURI = @"www.qq.com";
#warning set local app id
    }
    return _tencentOAuth;
}
- (void)login{
    NSArray *permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO];
    [self.tencentOAuth authorize:permissions inSafari:NO];
}

//login successed
- (void)tencentDidLogin
{
    NSLog(@"login successed");
    if (self.tencentOAuth.accessToken && [self.tencentOAuth.accessToken length]){
        [self.tencentOAuth getUserInfo];
    }else{
        NSLog(@"login fail, no accesstoken");
    }
}

- (void)getUserInfoResponse:(APIResponse *)response{
    //store access token, openid, expiration date, user photo, username, gender
    NSDictionary *fetchedUserInfo = [response jsonResponse];
    NSDictionary *localUserInfo = @{ACCESS_TOKEN:self.tencentOAuth.accessToken,
                                    OPENID:self.tencentOAuth.openId,
                                    EXPIRATION_DATE:self.tencentOAuth.expirationDate,
                                    PROFILE_PICTURE_URL:fetchedUserInfo[@"figureurl_qq_2"],
                                    GENDER:fetchedUserInfo[@"gender"],
                                    USER_DISPLAY_NAME:fetchedUserInfo[@"nickname"],
                                    LOGIN_STATUS:@(YES)};
    [SystemUtil updateOwnerInfo:localUserInfo];
    NSLog(@"%@",localUserInfo);
    [self.tableView reloadData];
}
//login fail
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        NSLog(@"user cancelled");
    }else{
        NSLog(@"login fail");
    }
}

//no internet
-(void)tencentDidNotNetWork
{
    NSLog(@"无网络连接，请设置网络");
}


/*
 特别提示：
 1.由于登录是异步过程，这里可能会由于用户的行为导致整个登录的的流程无法正常走完，即有可能由于用户行为导致登录完成后不会有任何登录回调被调用。开发者在使用SDK进行开发的时候需要考虑到这点，防止由于一直在同步等待登录的回调而造成应用的卡死，建议在登录的时候将这个实现做成一个异步过程。
 2.获取到的access token具有3个月有效期，过期后提示用户重新登录授权。
 3. 第三方网站可存储access token信息，以便后续调用OpenAPI访问和修改用户信息时使用。如果需要保存授权信息，需要保存登录完成后返回的accessToken，openid 和 expirationDate三个数据，下次登录的时候直接将这三个数据是设置到TencentOAuth对象中即可。
 4. 建议应用在用户登录后，即调用getUserInfo接口获得该用户的头像、昵称并显示在界面上，使用户体验统一。
 */
@end
