//
//  PreviewCell.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-25.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PREVIEWCELLNORMAL @"PreviewCell"
@interface PreviewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *planImageView;
@property (weak, nonatomic) IBOutlet UIView *transparentLayer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordCountLabel;
@property (nonatomic,strong) UIColor *borderColor;


- (void)showHeightlightedState;
- (void)showNormalState;
@end
