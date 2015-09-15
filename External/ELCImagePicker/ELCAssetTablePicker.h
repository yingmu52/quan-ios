//
//  ELCAssetTablePicker.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAsset.h"
#import "ELCAssetSelectionDelegate.h"
#import "ELCAssetPickerFilterDelegate.h"

@interface ELCAssetTablePicker : UIViewController <ELCAssetDelegate>

@property (nonatomic, weak) id <ELCAssetSelectionDelegate> parent;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (nonatomic, strong) NSMutableArray *elcAssets;
@property (nonatomic, strong) IBOutlet UILabel *indicatorLabel;
@property (nonatomic, assign) BOOL singleSelection;
@property (nonatomic, assign) BOOL immediateReturn;

// optional, can be used to filter the assets displayed
@property(nonatomic, weak) id<ELCAssetPickerFilterDelegate> assetPickerFilterDelegate;

- (NSUInteger)totalSelectedAssets;
- (void)preparePhotos;

- (void)doneAction:(id)sender;

@end