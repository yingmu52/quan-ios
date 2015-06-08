
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
#import "User.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIViewController+ECSlidingViewController.h"
#import "FetchCenter.h"
#import "UIView+Shake.h"
#import "CustomBadge.h"
#import "UIView+Shake.h"
typedef enum {
    MenuTableMyEvent = 0,
//    MenuTableJourney,
    MenuTableDiscover,
    MenuTableFollow,
    MenuTableMessage
}MenuMidSection;

typedef enum {
    MenuSectionLogin = 0,
    MenuSectionMid,
    MenuSectionLower
}MenuSection;


@interface MenuViewController () 

@property (nonatomic,weak) IBOutlet UILabel *versionLabel;
@property (nonatomic,strong) CustomBadge *badage;
@end


@implementation MenuViewController


#pragma mark - observe message notification
- (void)tuneInMessageNotification{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate addObserver:self
               forKeyPath:@"numberOfMessages"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)tuneOutMessageNotification{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate removeObserver:self forKeyPath:@"numberOfMessages"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self tuneInMessageNotification];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self tuneOutMessageNotification];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if ([keyPath isEqualToString:@"numberOfMessages"]) {
        id value = [change objectForKey:@"new"];
        NSInteger count = [value integerValue];
        MenuCell *cell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MenuTableMessage
                                                                                              inSection:MenuSectionMid]];
        if (count > 0) {
            //update message cell
            
            //remove badage in case it exist previously
            [self.badage removeFromSuperview];
            self.badage = nil;
            
            //set badge text
            self.badage.badgeText = [NSString stringWithFormat:@"%@",value];
            
            //set position of the badage
            CGPoint point = cell.menuTitle.center;
            point.x += cell.menuTitle.frame.size.width/2 + self.badage.frame.size.width;
            self.badage.center = point;
            [cell addSubview:self.badage];
            
            //shake
            if (!self.badage.isShaking) {
                [self.badage shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationExpDown | SCShakeOptionsAtEndRestart | SCShakeOptionsAutoreverse force:0.15 duration:2.0 iterationDuration:0.03 completionHandler:nil];

            }
        }else{
            //resume message cell
            [self.badage endShake];
            [self.badage removeFromSuperview];
            self.badage = nil;
            cell.menuTitle.text = @"消息";
        }
    }
}

- (CustomBadge *)badage{
    if (!_badage) {
        _badage = [CustomBadge customBadgeWithString:nil withStyle:[BadgeStyle oldStyle]];
    }
    return _badage;
}
#pragma mark -

- (void)setVersionLabel:(UILabel *)versionLabel{
    _versionLabel = versionLabel;
    _versionLabel.text = @"Version 3.1.1";
}

- (IBAction)showSettingsView:(UIButton *)sender{
    [self performSegueWithIdentifier:@"showSettingView" sender:nil];
}

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue
{
    //after returning to menue view
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set menu background image
    self.tableView.backgroundColor = [Theme menuBackground];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRef = tableView.frame.size.height;
    if (indexPath.section == MenuSectionLogin) {
        return heightRef * 278 / 1136;
    }else if (indexPath.section == MenuSectionMid){
        return heightRef * 178 / 1136;
    }else if (indexPath.section == MenuSectionLower){
        return heightRef * 146/ 1136;
    }else{
        return 0;
    }
}


- (MenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == MenuSectionLogin) {
                
        [cell.menuImageView setImageWithURL:[[FetchCenter new] urlWithImageID:[User updatedProfilePictureId]]
                usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        cell.menuTitle.text = [User userDisplayName];
    }
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == MenuSectionMid) {
        NSString *identifier;
        switch (indexPath.row) {
            case MenuTableMyEvent:
                identifier = @"showWishList";
                break;
            case MenuTableDiscover:
                identifier = @"ShowDiscoveryList";
                break;
            case MenuTableFollow:
                identifier = @"ShowFollowingFeed";
                break;
            case MenuTableMessage:{
                identifier = @"showMessageListView";
                [self.badage removeFromSuperview];
                self.badage = nil;   
            }
                break;
            default:
                break;
        }
        [self performSegueWithIdentifier:identifier sender:nil];
    }else if (indexPath.section == MenuSectionLogin){
        [self performSegueWithIdentifier:@"ShowAcheivementList" sender:nil];
    }
}


#pragma mark - cell highlight behavior
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

@end
