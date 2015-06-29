//
//  ViewForEmptyEvent.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-28.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewForEmptyEvent;
@protocol ViewForEmptyEventDelegate <NSObject>
@optional
- (void)didPressButton:(ViewForEmptyEvent *)view;
@end

@interface ViewForEmptyEvent : UIView
@property (nonatomic,weak) id <ViewForEmptyEventDelegate>delegate;
+ (instancetype)instantiateFromNib:(CGRect)frame;
@end
