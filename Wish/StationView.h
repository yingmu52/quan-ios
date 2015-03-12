//
//  StationView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StationView : UIView

typedef enum {
    StationViewSelectionDelete = 0,
    StationViewSelectionGiveUp,
    StationViewSelectionFinish
}StationViewSelection;


@property (nonatomic,weak) IBOutlet UIView *cardView;
@property (nonatomic,weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic) CGPoint currentCardLocation;
@property (nonatomic,weak) IBOutlet UIImageView *giveupButton;
@property (nonatomic,weak) IBOutlet UIImageView *deleteButton;
@property (nonatomic,weak) IBOutlet UIImageView *finishButton;

@property (nonatomic,readonly) StationViewSelection selection;

+ (instancetype)instantiateFromNib:(CGRect)frame;
@end
