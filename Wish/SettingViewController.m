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
@interface SettingViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIView *currentView;

@property (nonatomic,strong) UIColor *normalBackground;

@property (nonatomic,weak) IBOutlet UIImageView *iconImageView;
@end

@implementation SettingViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.iconImageView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"设置";
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
        [self logout];
    }
}

- (void)logout{
    //delete user info
    [User updateOwnerInfo:nil];
    
    //reload menu
    ECSlidingViewController *slidingVC = (ECSlidingViewController *)self.presentingViewController;
    MenuViewController *menuVC = (MenuViewController *)slidingVC.underLeftViewController;
    [menuVC.tableView reloadData];
    
    //reset top view
    slidingVC.topViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    //delete all objects in core data
//    [self clearCoreData];

}

- (void)clearCoreData{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSEntityDescription *entity in delegate.managedObjectModel.entities){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity.name];
        [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        NSError * error = nil;
        NSArray * objects = [delegate.managedObjectContext executeFetchRequest:request error:&error];
        //error handling goes here
        for (NSManagedObject *object in objects) {
            [delegate.managedObjectContext deleteObject:object];
        }
        NSError *saveError = nil;
        [delegate.managedObjectContext save:&saveError];
        
    }

}
@end
