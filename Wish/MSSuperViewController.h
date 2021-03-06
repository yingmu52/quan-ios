//
//  MSSuperViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchCenter.h"
#import "SystemUtil.h"
#import "UIImageView+ImageCache.h"
#import "Theme.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "MSTableViewCell.h"
#import "NavigationBar.h"
#import "MBProgressHUD.h"


@import CoreData;

@protocol MSSuperViewControllerDelegate <NSObject>
@optional
- (void)didScrollWithNavigationBar:(BOOL)isTransparent;
@end

@interface MSSuperViewController : UIViewController
<FetchCenterDelegate
,NSFetchedResultsControllerDelegate
,UITableViewDelegate
,UICollectionViewDelegate
,MBProgressHUDDelegate>{
    @protected
    NSFetchRequest *_tableFetchRequest; //让子类可以access实例变量
    NSFetchRequest *_collectionFetchRequest;
}
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) AppDelegate *appDelegate;
@property (nonatomic) BOOL allowTransparentNavigationBar;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,weak) id <MSSuperViewControllerDelegate> superVCDelegate;
- (void)loadNewData;
- (void)loadMoreData;
#pragma mark - Collection View 
@property (nonatomic,strong) NSFetchedResultsController *collectionFetchedRC;
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

#pragma mark - Table View 
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSFetchedResultsController *tableFetchedRC;

//MARK !!!: 必须设置
@property (nonatomic,strong) NSFetchRequest *tableFetchRequest;
@property (nonatomic,strong) NSFetchRequest *collectionFetchRequest;

- (NSString *)tableSectionKeyPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)setUpBackButton:(BOOL)useWhiteButton;
- (void)setupRightBarButtonItem:(BOOL)useWhiteIcon selector:(SEL)method;
- (void)msPopViewController;
@end
