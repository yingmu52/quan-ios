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
#import "SZTextView.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "WishDetailVCOwner.h"
#import "UIActionSheet+Blocks.h"
#import "JTSImageViewController.h"
#import "PostImageCell.h"
#import "ImagePicker.h"
#import "ImagePreviewController.h"
static NSUInteger maxWordCount = 1000;
static NSUInteger distance = 10;

@interface PostFeedViewController () <FetchCenterDelegate,UICollectionViewDataSource,UICollectionViewDelegate,ImagePickerDelegate,ImagePreviewControllerDelegate>
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UILabel *wordCountLabel;
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) ImagePicker *imagePicker;
@property (weak, nonatomic) IBOutlet SZTextView *textView;
@property (nonatomic,strong) Feed *feed;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (nonatomic,strong) NSMutableArray *fetchedImageIds;
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
        _feed = [Feed createFeedInPlan:self.plan feedTitle:self.textView.text];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}

#define placeHolder @"说点什么吧"

- (void)setTextView:(SZTextView *)textView{
    _textView = textView;
    _textView.showsVerticalScrollIndicator = NO;
    _textView.placeholder = placeHolder;
    _textView.placeholderTextColor = [UIColor lightGrayColor];
    _textView.textContainerInset = UIEdgeInsetsZero;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [self.textView resignFirstResponder];
//}


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


//- (IBAction)preViewButtonPressed:(UIButton *)button{
//    [self.textView resignFirstResponder];
//    
//    // Create image info
//    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
//    imageInfo.image = button.imageView.image;
//    imageInfo.referenceRect = button.frame;
//    imageInfo.referenceView = button.superview;
//    
//    // Setup view controller
//    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
//                                           initWithImageInfo:imageInfo
//                                           mode:JTSImageViewControllerMode_Image
//                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
//    
//    // Present the view controller.
//    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
//
//}

- (void)createFeed{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    self.fetchedImageIds = [NSMutableArray arrayWithCapacity:self.imagesForFeed.count];
    [self.fetchCenter uploadImages:self.imagesForFeed toCreateFeed:self.feed];
}

#define CONFIRM @"确定"
- (void)goBack{
    [UIActionSheet showInView:self.view withTitle:@"是否放弃此次编辑？" cancelButtonTitle:@"取消" destructiveButtonTitle:CONFIRM otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        __weak typeof(self) weakSelf = self;
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
        if ([title isEqualToString:CONFIRM]){
            if (weakSelf.feed) {
                [[AppDelegate getContext] deleteObject:weakSelf.feed];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];

}
#pragma mark - text view delegate


- (void)textViewDidChange:(UITextView *)textView{
    if (textView.isFirstResponder){
        BOOL flag = textView.text.length*[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0 && self.imagesForFeed.count > 0;
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
    if ([segue.identifier isEqualToString:@"showImagePreviewFromPostFeedDetail"]) {
        //sender : @[self.imagesForFeed,indexPath]];
        NSArray *array = (NSArray *)sender;
        ImagePreviewController *ipvc = segue.destinationViewController;
        ipvc.previewImages = array.firstObject;
        ipvc.entryIndexPath = array.lastObject;
        ipvc.delegate = self;
    }
}

#pragma mark - ImagePickerDelegate


- (void)didRemoveImageAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",@(self.imagesForFeed.count));
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - fetch center delegate 

- (void)didFinishUploadingImage:(NSString *)fetchedImageId forFeed:(Feed *)feed{
    [self.fetchedImageIds addObject:fetchedImageId];
    if (self.fetchedImageIds.count == self.imagesForFeed.count) { //所有的图片都上传成功了
        [self.fetchCenter uploadToCreateFeed:feed fetchedImageIds:self.fetchedImageIds];
    }
}

- (void)didFinishUploadingFeed:(Feed *)feed
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    
    if (!self.seugeFromPlanCreation) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self performSegueWithIdentifier:@"showWishDetailOnPlanCreation" sender:self.plan];

    }
    
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

- (void)keyboardDidHide:(NSNotification *)notification{
    [self updateViewForNewHeight:0];
}

- (void)keyboardDidChange:(NSNotification *)notification{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateViewForNewHeight:CGRectGetHeight(keyboardFrame)];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateViewForNewHeight:CGRectGetHeight(keyboardFrame)];
    
}
- (void)updateViewForNewHeight:(CGFloat)height{
    self.keyboardHeight.constant = height;
    [self.view layoutIfNeeded];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - dismiss keyboard when tap on background
- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - collection view delegate and data source

- (PostImageCell *)collectionView:(UICollectionView *)aCollectionView
         cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostImageCell *cell;
    if (indexPath.row != self.imagesForFeed.count) { //is not the last row
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:POSTIMAGECELL forIndexPath:indexPath];
        cell.imageView.image = self.imagesForFeed[indexPath.row];
//        [cell layoutIfNeeded]; //fixed auto layout error on iphone 5s or above
    }else{
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"PostDetailAddCell" forIndexPath:indexPath];
        
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    return self.imagesForFeed.count + 1; //including the last button
}

- (void)setCollectionView:(UICollectionView *)collectionView{
    _collectionView = collectionView;
    _collectionView.layer.borderColor = [SystemUtil colorFromHexString:@"#DFE1E0"].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.imagesForFeed.count) { //is not the last row
        [self performSegueWithIdentifier:@"showImagePreviewFromPostFeedDetail" sender:@[self.imagesForFeed,indexPath]];
    }else{
        if (self.imagesForFeed.count < defaultMaxImageSelectionAllowed) {
            NSInteger remain = defaultMaxImageSelectionAllowed - self.imagesForFeed.count;
            [self.imagePicker showPhotoLibrary:self maxImageCount:remain];
        }else{
            //show notification
        }
    }

}

#pragma mark - Image Picker Delegate
- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (void)didFinishPickingImage:(NSArray *)images{
    [self.imagesForFeed addObjectsFromArray:images];
    [self.collectionView reloadData];
}
@end




