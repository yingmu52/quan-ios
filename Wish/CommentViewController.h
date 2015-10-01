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
@interface CommentViewController : MSSuperViewController
@property (nonatomic,weak) Comment *comment;
@property (nonatomic,weak) FeedDetailViewController *feedDetailViewController;
@end
