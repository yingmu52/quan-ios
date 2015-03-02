//
//  PostFeedViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "Plan.h"
//@class PostFeedViewController;

//@protocol  PostFeedViewControllerDelegate <NSObject>

//@required
//- (void)didFinishAddingTitleForFeed:(PostFeedViewController *)postFeedVC;

//@end
@interface PostFeedViewController : UIViewController

@property (nonatomic,strong) Feed *feed;
//@property (nonatomic,strong) NSString *navigationTitle;
//@property (nonatomic,strong) UIImage *previewImage;
//@property (nonatomic,weak) id <PostFeedViewControllerDelegate> delegate;


//@property (nonatomic,readonly) NSString *titleForFeed;


@end
