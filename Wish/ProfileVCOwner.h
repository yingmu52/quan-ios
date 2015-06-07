//
//  ProfileVCOwner.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-06.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ProfileViewController.h"
#import "GCPTextView.h"

@interface ProfileVCOwner : ProfileViewController
@property (nonatomic,weak) IBOutlet GCPTextView *descriptionTextView;
@end
