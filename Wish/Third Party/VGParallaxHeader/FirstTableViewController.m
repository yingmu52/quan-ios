//
//  FirstTableViewController.m
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import "FirstTableViewController.h"
#import "HeaderView.h"

@interface FirstTableViewController ()

@end

@implementation FirstTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HeaderView *headerView = [HeaderView instantiateFromNib];
    
    [self.tableView setParallaxHeaderView:headerView
                                     mode:VGParallaxHeaderModeFill
                                   height:200];
        
    self.tableView.parallaxHeader.stickyViewPosition = VGParallaxHeaderStickyViewPositionTop;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView shouldPositionParallaxHeader];

    // Log Parallax Progress
    //NSLog(@"Progress: %f", scrollView.parallaxHeader.progress);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


@end
