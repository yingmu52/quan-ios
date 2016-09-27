//
//  MSCollectionCell.h
//  Stories
//
//  Created by Xinyi Zhuang on 9/28/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSCollectionCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *ms_imageView1;
@property (nonatomic,weak) IBOutlet UIImageView *ms_imageView2;
@property (nonatomic,weak) IBOutlet UIImageView *ms_imageView3;

@property (nonatomic,weak) IBOutlet UILabel *ms_titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *ms_subTitleLabel;

@property (nonatomic,weak) IBOutlet UILabel *ms_infoLabel1;
@property (nonatomic,weak) IBOutlet UILabel *ms_infoLabel2;

@property (nonatomic) BOOL ms_shouldHaveBorder;
@end
