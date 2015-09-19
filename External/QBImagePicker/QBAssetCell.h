//
//  QBAssetCell.h
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBVideoIndicatorView;

@class QBAssetCell;

@protocol  QBAssetCellDelegate <NSObject>
- (void)didTapOnInvisibleButton:(QBAssetCell *)cell;
@end

@interface QBAssetCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet QBVideoIndicatorView *videoIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (nonatomic, assign) BOOL showsOverlayViewWhenSelected;

@property (nonatomic,weak) id <QBAssetCellDelegate> invisibleButtonDelegate;
@end
