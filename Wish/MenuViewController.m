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
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat heightRef = self.tableView.frame.size.height;
//    CGFloat ratioHead = 278 / 1136;
//    CGFloat ratioBody = ( 100 + 10 + 32 + 26 ) / 1136;
//    CGFloat ratioFoot = 1 - ratioHead - ratioBody;
//    
//    NSInteger section = indexPath.section;
//    if (section == 0){
//        return heightRef * ratioHead;
//    }else if (section == 1){
//        return heightRef * ratioBody;
//    }else if (section == 2){
//        return heightRef * ratioFoot;
//    }else{
//        return 0;
//    }
//}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 5 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRef = tableView.frame.size.height;
    CGFloat heightLogin = heightRef * 278 / 1136;
    CGFloat heightOther = heightRef * ( 100 + 10 + 32 + 30 ) / 1136;
    
    if (indexPath.row == 0){
        return heightLogin;
    }else if (indexPath.row >= 1 || indexPath.row <=4){
        return heightOther;
    }else return 0;


}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.backgroundColor = cell.backgroundColor.CGColor;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (MenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"
                                                            forIndexPath:indexPath];

    // Configure the cell...
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.backgroundColor = cell.backgroundColor.CGColor;
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}



@end
