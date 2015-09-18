//
//  QBAssetCell.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetCell.h"
#import "Theme.h"
@interface QBAssetCell ()

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation QBAssetCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Show/hide overlay view
//    self.overlayView.hidden = !(selected && self.showsOverlayViewWhenSelected);
    if (selected && self.showsOverlayViewWhenSelected) {
        self.checkMark.image = [Theme checkmarkSelected];
    }else{
        self.checkMark.image = [Theme checkmarkUnSelected];
    }
}

@end
