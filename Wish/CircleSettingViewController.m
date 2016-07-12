//
//  CircleSettingViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-04.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleSettingViewController.h"
#import "Theme.h"
#import "FetchCenter.h"
#import "CircleEditViewController.h"
#import "MemberListViewController.h"
#import "InvitationViewController.h"

@interface CircleSettingViewController () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

@implementation CircleSettingViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    
    //Left Bar Button
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    if ([self.circle.ownerId isEqualToString:[User uid]]) {
        UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                              target:self
                                            selector:@selector(deleteCircle:)
                                               frame:frame];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    }
    //Title
    self.navigationItem.title = @"设置";
}

- (void)deleteCircle:(UIButton *)sender{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self.fetchCenter deleteCircle:self.circle.circleId
                        completion:^
     {
         [spinner stopAnimating];
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sender];
//         [self.delegate didFinishDeletingCircle];
         [self.circle.managedObjectContext deleteObject:self.circle];
         AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         [delegate saveContext];
         
         [self.navigationController popToRootViewControllerAnimated:YES];
     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 5.0 : 2.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2.5;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showCircleEditingView"]) {
        CircleEditViewController *cec = segue.destinationViewController;
        cec.circle = self.circle;
    }
    if ([segue.identifier isEqualToString:@"showMemberListView"]) {
        MemberListViewController *mlc = segue.destinationViewController;
        mlc.circle = self.circle;
    }
    
    if ([segue.identifier isEqualToString:@"showInvitationView"]) {
        InvitationViewController *ivc = segue.destinationViewController;
#warning must set ivc properties !
    }
    
}
@end



