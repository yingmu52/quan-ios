//
//  CommentAcessaryView.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-07.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "Comment.h"
@class CommentAcessaryView;
@protocol CommentAcessaryViewDelegate <NSObject>
@optional
- (void)didPressSend:(CommentAcessaryView *)cav;
@end


@interface CommentAcessaryView : UIView


typedef enum {
    CommentAcessaryViewStateComment = 0,
    CommentAcessaryViewStateReply,
}CommentAcessaryViewState;


@property (nonatomic,strong) Comment *comment; //reply and display info

@property (nonatomic,strong) Feed *feed; //needed for wish detail

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *feedInfoBackground;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) id <CommentAcessaryViewDelegate> delegate;

@property (nonatomic,readonly) CommentAcessaryViewState state;

+ (instancetype)instantiateFromNib:(CGRect)frame;
@end
