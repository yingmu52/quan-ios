//
//  MSSuperViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchCenter.h"
@import CoreData;
@interface MSSuperViewController : UIViewController <FetchCenterDelegate,NSFetchedResultsControllerDelegate>{
    @protected
    NSFetchRequest *_tableFetchRequest; //让子类可以access实例变量
}
@property (nonatomic,strong) FetchCenter *fetchCenter;


#pragma mark - Collection View 
@property (nonatomic,strong) NSFetchedResultsController *collectionFetchedRC;


#pragma mark - Table View 
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSFetchedResultsController *tableFetchedRC;

//MARK !!!: 必须设置
@property (nonatomic,strong) NSFetchRequest *tableFetchRequest;

@end
