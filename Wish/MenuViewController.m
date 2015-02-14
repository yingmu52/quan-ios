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
#import "UINavigationItem+CustomItem.h"

typedef enum {
    MenuTableLogin = 0,
    MenuTableWishList,
    MenuTableJourney,
    MenuTableDiscover,
    MenuTableFollow
}MenuTable;

@interface MenuViewController ()
@property (nonatomic) BOOL isLogin;
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
    if (indexPath.row == 0){
        return heightLogin;
    }else if (indexPath.row >= 1 && indexPath.row <=4){
        return heightOther;
    }else if (indexPath.row == 5){
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
            
            [cell.menuImageView setImage:[Theme menuLoginDefault]];
            cell.menuTitle.text = @"登录";
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
    if (indexPath.row == MenuTableWishList) {
        [self performSegueWithIdentifier:@"showWishList" sender:nil];
    }else if (indexPath.row == MenuTableFollow){
        [self performSegueWithIdentifier:@"ShowFollowingFeed" sender:nil];
    }
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

@end
