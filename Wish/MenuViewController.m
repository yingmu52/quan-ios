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
        if (indexPath.row == 0) {
            
            [cell.menuImageView setImage:[UIImage imageNamed:@"tab_ic_login_default"]];
            cell.menuTitle.text = @"登录";
        }else if (indexPath.row == 1){
            cell.menuImageView.image = [UIImage imageNamed:@"tab_ic_home_default"];
            cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab_ic_home_selected"];
            cell.menuTitle.text = @"愿望列表";
        }else if (indexPath.row == 2){
            cell.menuImageView.image = [UIImage imageNamed:@"tab_ic_achieve_default"];
            cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab_ic_achieve_selected"];
            cell.menuTitle.text = @"我的历程";
        }else if (indexPath.row == 3){
            cell.menuImageView.image = [UIImage imageNamed:@"tab_ic_discover_default"];
            cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab_ic_discover_selected"];
            cell.menuTitle.text = @"发现愿望";
        }else if (indexPath.row == 4){
            cell.menuTitle.text = @"关注动态";
            cell.menuImageView.image = [UIImage imageNamed:@"tab_ic_follow_default"];
            cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab_ic_follow_selected"];
        }

    }else if (indexPath.row == 5){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BottomCellLogout"
                                               forIndexPath:indexPath];
    }else return nil;

    return cell;
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
