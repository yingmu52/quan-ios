//
//  PostFeedViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostFeedViewController;

@protocol  PostFeedViewControllerDelegate <NSObject>

@required
- (void)didFinishAddingTitleForFeed:(PostFeedViewController *)postFeedVC;

@end
@interface PostFeedViewController : UIViewController

@property (nonatomic,strong) NSString *navigationTitle;
@property (nonatomic,strong) UIImage *previewImage;
@property (nonatomic,readonly) NSString *titleForFeed;
@property (nonatomic,weak) id <PostFeedViewControllerDelegate> delegate;

@end
