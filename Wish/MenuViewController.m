//
//  MenuViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"

@interface MenuViewController ()

@end

@implementation MenuViewController


- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue
{
    //after returning to menue view
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set menu background image
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab-bg"]];
    
    //remove table view separator
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 5 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRef = tableView.frame.size.height;
    CGFloat heightLogin = heightRef * 220 / 1136;
    CGFloat heightOther = heightLogin - 10;

    
    if (indexPath.row == 0){
        return heightLogin;
    }else if (indexPath.row >= 1 || indexPath.row <=4){
        return heightOther;
    }else return 0;
    return heightLogin;

}



- (MenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];

    // Configure the cell...
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.backgroundColor = cell.backgroundColor.CGColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {

        [cell.menuImageView setImage:[UIImage imageNamed:@"tab-ic-login-default"]];
        cell.menuTitle.text = @"登录";
    }else if (indexPath.row == 1){
        cell.menuImageView.image = [UIImage imageNamed:@"tab-ic-home-default"];
        cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab-ic-home-selected"];
        cell.menuTitle.text = @"愿望列表";
    }else if (indexPath.row == 2){
        cell.menuImageView.image = [UIImage imageNamed:@"tab-ic-achieve-default"];
        cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab-ic-achieve-selected"];
        cell.menuTitle.text = @"我的历程";
    }else if (indexPath.row == 3){
        cell.menuImageView.image = [UIImage imageNamed:@"tab-ic-discover-default"];
        cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab-ic-discover-selected"];
        cell.menuTitle.text = @"发现愿望";
    }else if (indexPath.row == 4){
        cell.menuTitle.text = @"关注动态";
        cell.menuImageView.image = [UIImage imageNamed:@"tab-ic-follow-default"];
        cell.menuImageView.highlightedImage = [UIImage imageNamed:@"tab-ic-follow-selected"];

    }

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
