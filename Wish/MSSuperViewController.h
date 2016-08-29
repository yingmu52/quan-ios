//
//  MSSuperViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchCenter.h"
#import "UIImageView+ImageCache.h"
#import "Theme.h"
#import "WishDetailCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

#define NSLog if(DEBUG) NSLog

@import CoreData;
@interface MSSuperViewController : UIViewController
<FetchCenterDelegate
,NSFetchedResultsControllerDelegate
,UITableViewDelegate
,UICollectionViewDelegate>{
    @protected
    NSFetchRequest *_tableFetchRequest; //让子类可以access实例变量
    NSFetchRequest *_collectionFetchRequest;
}
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,weak) AppDelegate *appDelegate;

#pragma mark - Collection View 
@property (nonatomic,strong) NSFetchedResultsController *collectionFetchedRC;
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

#pragma mark - Table View 
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSFetchedResultsController *tableFetchedRC;

//MARK !!!: 必须设置
@property (nonatomic,strong) NSFetchRequest *tableFetchRequest;
@property (nonatomic,strong) NSFetchRequest *collectionFetchRequest;

- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
