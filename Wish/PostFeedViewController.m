//
//  PostFeedViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostFeedViewController.h"
#import "Theme.h"
#import "KeyboardAcessoryView.h"
#import "SystemUtil.h"
#import "FetchCenter.h"
@interface PostFeedViewController () <UITextFieldDelegate,FetchCenterDelegate>
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UIImageView *previewIcon;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PostFeedViewController

- (NSString *)titleForFeed{
    return self.textField.text;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDisable]
                                     target:self
                                   selector:@selector(createFeed)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.textField addTarget:self action:@selector(textFieldDidUpdate) forControlEvents:UIControlEventEditingChanged];
    self.textField.inputAccessoryView = [KeyboardAcessoryView instantiateFromNib:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 88 / 1136)];

    self.previewIcon.image = self.imageForFeed;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    self.title = self.plan.planTitle;
}
- (void)createFeed{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    
    Feed *feed = [Feed createFeedWithImage:self.imageForFeed inPlan:self.plan];
    feed.feedTitle = self.textField.text;
    FetchCenter *fc = [FetchCenter new];
    fc.delegate = self;
    [fc uploadToCreateFeed:feed];
}

- (void)didFinishUploadingFeed:(Feed *)feed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
        [self.navigationController popViewControllerAnimated:YES];
        
    });
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)didFailUploadingImageWithInfo:(NSDictionary *)info{
    [self handleFailure:info];
}

- (void)handleFailure:(NSDictionary *)info{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:[NSString stringWithFormat:@"%@",info]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    });

}

- (void)textFieldDidUpdate{
    BOOL flag = self.textField.text.length*[self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
    self.navigationItem.rightBarButtonItem.enabled = flag;
    UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
    [self.tikButton setImage:bg forState:UIControlStateNormal];
}

@end
