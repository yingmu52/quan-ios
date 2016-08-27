//
//  CommentViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-28.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"
#import "Comment.h"
#import "FeedDetailViewController.h"

@class CommentViewController;
@protocol CommentViewControllerDelegate <NSObject>
- (void)commentViewDidFinishInsertingComment;
@end
@interface CommentViewController : MSSuperViewController
@property (nonatomic,strong) Comment *comment;
@property (nonatomic,strong) Feed *feed;
@property (nonatomic,weak) id <CommentViewControllerDelegate> delegate;
@end
