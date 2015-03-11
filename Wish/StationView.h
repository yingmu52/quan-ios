//
//  StationView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StationView : UIView

@property (nonatomic,weak) IBOutlet UIView *cardView;
@property (nonatomic,weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic) CGPoint currentCardLocation;
+ (instancetype)instantiateFromNib:(CGRect)frame;
@end
