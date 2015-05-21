
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
@end


@implementation MenuViewController


- (void)setVersionLabel:(UILabel *)versionLabel{
    _versionLabel = versionLabel;
    _versionLabel.text = @"Version 3.0.1";
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
            case MenuTableMessage:
                identifier = @"showMessageListView";
                break;
            default:
                break;
        }
        [self performSegueWithIdentifier:identifier sender:nil];
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
