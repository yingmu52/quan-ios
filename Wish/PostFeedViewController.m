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
#import "GCPTextView.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "WishDetailVCOwner.h"
#import "UIActionSheet+Blocks.h"
#import "JTSImageViewController.h"
static NSUInteger maxWordCount = 1000;
static NSUInteger distance = 10;

@interface PostFeedViewController () <FetchCenterDelegate>
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UIButton *previewButton;
@property (nonatomic,weak) IBOutlet UILabel *wordCountLabel;
@property (weak, nonatomic) IBOutlet GCPTextView *textView;
@property (nonatomic,strong) Feed *feed;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

@implementation PostFeedViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (Feed *)feed{
    if (!_feed){
        _feed = [Feed createFeedWithImage:self.imageForFeed inPlan:self.plan];
        _feed.feedTitle = self.textView.text;
    }
    return _feed;
}

- (NSString *)titleForFeed{
    return self.textView.text;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupViews];
    
    //add observer to detect keyboard height
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

#define placeHolder @"说点什么吧"

- (void)setTextView:(GCPTextView *)textView{
    _textView = textView;
    _textView.showsVerticalScrollIndicator = NO;
    [_textView setPlaceholder:placeHolder];
    _textView.textContainerInset = UIEdgeInsetsZero;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}


- (void)setupViews
{
    CGRect frame = CGRectMake(0, 0, 25, 25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(goBack)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDisable]
                                     target:self
                                   selector:@selector(createFeed)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    self.title = self.plan.planTitle;
    self.wordCountLabel.text = [NSString stringWithFormat:@"0/%@ 字",@(maxWordCount)];
}

- (void)setPreviewButton:(UIButton *)previewButton{
    _previewButton = previewButton;
    [_previewButton setImage:self.imageForFeed forState:UIControlStateNormal];
}

- (IBAction)preViewButtonPressed:(UIButton *)button{
    [self.textView resignFirstResponder];
    
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = button.imageView.image;
    imageInfo.referenceRect = button.frame;
    imageInfo.referenceView = button.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];

}
- (void)createFeed{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    [self.fetchCenter uploadToCreateFeed:self.feed];
}

#define CONFIRM @"确定"
- (void)goBack{
    [UIActionSheet showInView:self.view withTitle:@"是否放弃此次编辑？" cancelButtonTitle:@"取消" destructiveButtonTitle:CONFIRM otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:CONFIRM]){
            [[AppDelegate getContext] deleteObject:self.feed];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
#pragma mark - text view delegate


- (void)textViewDidChange:(UITextView *)textView{
    if (textView.isFirstResponder){
        BOOL flag = textView.text.length*[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
        
        //limit text length
        if (textView.text.length > maxWordCount - distance ) { //快到时字数限制的时候显示提示
            
            if (textView.text.length > maxWordCount) {
                
                //correct Range location
                NSUInteger curserLocation = textView.selectedRange.location;
                
                //删除超出的字数, 光标位置会改变
                NSUInteger exceedCount = textView.text.length - maxWordCount;
                NSRange range = NSMakeRange(textView.selectedRange.location - exceedCount, exceedCount);
                textView.text = [textView.text stringByReplacingCharactersInRange:range withString:@""];
                
                //恢复光标正确的位置
                textView.selectedRange = NSMakeRange(curserLocation - exceedCount, 0);;
                
            }
            
            //en-visible wordCountLabel
            self.wordCountLabel.hidden = NO;
        }
        
        if (!self.wordCountLabel.isHidden){
            //update word count label
            self.wordCountLabel.text = [NSString stringWithFormat:@"%@/%@",@(textView.text.length),@(maxWordCount)];

        }
        
        //追着光标的位置展示
        [textView scrollRangeToVisible:textView.selectedRange];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= maxWordCount;
}


- (void)backspaceDidOccurInEmptyField{
    //this method prevents crash when user keep hitting back space
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showWishDetailOnPlanCreation"]){
        [segue.destinationViewController setPlan:sender]; //sender is plan
    }
}
#pragma mark - fetch center delegate 


- (void)didFinishUploadingFeed:(Feed *)feed
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    
    if (!self.seugeFromPlanCreation) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self performSegueWithIdentifier:@"showWishDetailOnPlanCreation" sender:self.plan];

    }
    
    //update plan here instead of in createFeedWithImage:inPlan: method
    feed.plan.image = self.imageForFeed;
    feed.plan.backgroundNum = feed.imageId;
    [feed.plan updateTryTimesOfPlan:YES];

}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}


- (void)handleFailure:(NSDictionary *)info{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

#pragma mark - keyboard interaction notification

- (void)keyboardWillHide:(NSNotification *)note{
    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]];
}

- (void)keyboardDidChange:(NSNotification *)note{
    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]];
}

- (void)updateFrameWithKeyboardSize:(CGRect)KBRect{
    //update text view frame
    CGRect newTVFrame = self.textView.frame;
    newTVFrame.size.height = KBRect.origin.y - CGRectGetMinY(newTVFrame) - 20.0; //20.0 must be the same as storyboard constraint
    self.textView.frame = newTVFrame;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - dismiss keyboard when tap on background
- (IBAction)tapOnBackground:(id)sender{
    [self.textView resignFirstResponder];
}
@end




