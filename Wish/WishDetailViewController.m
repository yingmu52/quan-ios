//
//  WishDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailViewController.h"
//#import "CustomBarItem.h"
#import "UINavigationItem+CustomItem.h"
#import "Theme.h"
@interface WishDetailViewController ()
@property  (nonatomic,strong) CustomBarItem *backButton;
@property  (nonatomic,strong) CustomBarItem *composeButton;
@property  (nonatomic,strong) CustomBarItem *shareButton;

@end

@implementation WishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    // Do any additional setup after loading the view.
}

- (void)setUpNavigationItem
{
    self.backButton = [self.navigationItem setItemWithImage:[Theme navBackButtonDefault]
                                                       size:CGSizeMake(30,30)
                                                   itemType:left];
    self.composeButton = [self.navigationItem setItemWithImage:[Theme navComposeButtonDefault]
                                                      size:CGSizeMake(30,30)
                                                  itemType:center];
//    [self.composeButton setOffset:40];
    
    self.shareButton = [self.navigationItem setItemWithImage:[Theme navShareButtonDefault]
                                                          size:CGSizeMake(30,30)
                                                      itemType:right];
    [self.navigationItem setRightBarButtonItems:@[self.composeButton,self.shareButton]];


}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %@", @(section)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishDetailCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Row %@", @(indexPath.row)];
    
    return cell;
}

@end
