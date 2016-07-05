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
#import "JTSImageViewController.h"
#import "PostImageCell.h"
#import "ImagePicker.h"
#import "ImagePreviewController.h"

static NSUInteger maxWordCount = 1000;
static NSUInteger distance = 10;

@interface PostFeedViewController () <FetchCenterDelegate,UICollectionViewDataSource,UICollectionViewDelegate,ImagePickerDelegate,ImagePreviewControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UILabel *wordCountLabel;
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) ImagePicker *imagePicker;
@property (weak, nonatomic) IBOutlet SZTextView *textView;
//@property (nonatomic,strong) Feed *feed;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@end

@implementation PostFeedViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

//- (Feed *)feed{
//    if (!_feed){
//        _feed = [Feed createFeedInPlan:self.plan feedTitle:self.textView.text];
//    }
//    return _feed;
//}
//
//- (Plan *)plan{
//    if (!_plan) {
//        if (self.circle) {
//            _plan = [Plan createPlan:self.navigationItem.title inCircle:self.circle];
//        }else{
//            NSLog(@"No Circle Exists");
//        }
//        
//    }
//    return _plan;
//}


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
    if (self.plan) {
        self.navigationItem.title = self.plan.planTitle;
    }
    self.wordCountLabel.text = [NSString stringWithFormat:@"0/%@ 字",@(maxWordCount)];
}


- (void)createFeed{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    //处理用户选取的图片 array of PHAsset/UIImage
    PHImageManager *manager = [PHImageManager defaultManager];
    NSMutableArray *arrayOfUIImages = [NSMutableArray arrayWithCapacity:self.assets.count];
    for (id item in self.assets) {
        
        //this method is async
        if ([item isKindOfClass:[PHAsset class]]) {
            [manager requestImageDataForAsset:item
                                      options:nil
                                resultHandler:^(NSData * _Nullable imageData,
                                                NSString * _Nullable dataUTI,
                                                UIImageOrientation orientation,
                                                NSDictionary * _Nullable info)
            {

                [arrayOfUIImages addObject:[UIImage imageWithData:imageData scale:0.5]];
                if (arrayOfUIImages.count == self.assets.count) {
                    [self.fetchCenter uploadImages:arrayOfUIImages
                                        completion:^(NSArray *imageIds) {
                        [self finishUploadingImages:imageIds];
                    }];
                }
            }];
        }
    }
    
    self.progressBar.hidden = NO;
}

- (void)goBack{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"是否放弃此次编辑？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
    {
        //取消所有上传任何
        if (self.fetchCenter.uploadManager.uploadTasks.count > 0) {
            [self.fetchCenter.uploadManager clear];
        }
        
        //返回上一级
        [self.navigationController popViewControllerAnimated:YES];

    }];
    
    [actionSheet addAction:confirm];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];

}
#pragma mark - text view delegate


- (void)textViewDidChange:(UITextView *)textView{
    if (textView.isFirstResponder){
        BOOL flag = textView.text.length*[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0 && self.assets.count > 0;
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
        self.navigationController.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"showImagePreviewFromPostFeedDetail"]) {
        //sender : @[self.imagesForFeed,indexPath]];
        NSArray *array = (NSArray *)sender;
        ImagePreviewController *ipvc = segue.destinationViewController;
        ipvc.assets = self.assets;
        ipvc.entryIndexPath = array.lastObject;
        ipvc.delegate = self;
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //这个方法修复了创建事件完成后进入动态详情时，按返回又回到发布页面
    if ([viewController isKindOfClass:[WishDetailVCOwner class]]) {
        [navigationController setViewControllers:@[navigationController.viewControllers.firstObject,viewController] animated:NO];
    }
}

#pragma mark - fetch center delegate

- (void)didFailUploadingImage:(UIImage *)image{
    //图片上传失败
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                   message:@"上传失败"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"重试"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
    {
        //重新上传
        [self.progressBar setProgress:0.0f];
        [self createFeed];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action)
    {
        //取掉进度条
        [self.progressBar removeFromSuperview];
        
        //初始化上传button
        self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                         target:self
                                       selector:@selector(createFeed)
                                          frame:CGRectMake(0, 0, 25, 25)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];

    }];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)finishUploadingImages:(NSArray *)imageIds{
    if (self.plan) {
        [self.fetchCenter createFeed:self.textView.text
                              planId:self.plan.planId
                     fetchedImageIds:imageIds
                          completion:^(NSString *feedId) {
                              [Feed createFeed:feedId
                                         title:self.textView.text
                                        images:imageIds
                                        planID:self.plan.planId];
                              [self.navigationController popViewControllerAnimated:YES];
        }];

    }else{
        [self.fetchCenter createPlan:self.navigationItem.title
                            circleId:self.circle.circleId
                          completion:^(NSString *planId, NSString *backgroundID)
        {
            [self.fetchCenter createFeed:self.textView.text
                                  planId:planId
                         fetchedImageIds:imageIds
                              completion:^(NSString *feedId)
            {
                Plan *plan = [Plan createPlan:self.navigationItem.title
                                     inCircle:self.circle
                                       planId:planId
                                 backgroundID:imageIds.firstObject];
                //create local feed
                [Feed createFeed:feedId title:self.textView.text images:imageIds planID:planId];
                [self performSegueWithIdentifier:@"showWishDetailOnPlanCreation" sender:plan];
            }];
                              
            
        }];
    }
}


//- (void)finishUploadingFeed:(Feed *)feed
//{
//    [self.textView resignFirstResponder];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
//    if (!self.seugeFromPlanCreation) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [self performSegueWithIdentifier:@"showWishDetailOnPlanCreation" sender:feed.plan];
//    }
//    self.progressBar.hidden = NO;
//}

- (void)didReceivedCurrentProgressForUploadingImage:(CGFloat)percentage{
    [self.progressBar setProgress:percentage animated:YES];
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


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - collection view delegate and data source

- (PostImageCell *)collectionView:(UICollectionView *)aCollectionView
         cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostImageCell *cell;
    if (indexPath.row != self.assets.count) { //is not the last row
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:POSTIMAGECELL forIndexPath:indexPath];
        
        id imageItem = self.assets[indexPath.row];
        if ([imageItem isKindOfClass:[PHAsset class]]) {
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestImageForAsset:self.assets[indexPath.row]
                               targetSize:CGSizeMake(140.0f, 140.0f)
                              contentMode:PHImageContentModeAspectFit
                                  options:nil
                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                cell.imageView.image = result;
                            }];

        }else if ([imageItem isKindOfClass:[UIImage class]]){
            cell.imageView.image = imageItem;
        }
        
    }else{
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"PostDetailAddCell" forIndexPath:indexPath];
        
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
//    return self.imagesForFeed.count + 1; //including the last button
    return self.assets.count + 1; //including the last button
}

- (void)setCollectionView:(UICollectionView *)collectionView{
    _collectionView = collectionView;
    _collectionView.layer.borderColor = [SystemUtil colorFromHexString:@"#DFE1E0"].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.assets.count) { //is not the last row
        [self performSegueWithIdentifier:@"showImagePreviewFromPostFeedDetail" sender:@[self.assets,indexPath]];
    }else{
        if (self.assets.count < defaultMaxImageSelectionAllowed) {
            NSInteger remain = defaultMaxImageSelectionAllowed - self.assets.count;
            [self.imagePicker showPhotoLibrary:self maxImageCount:remain];
        }else{
            //show notification
        }
    }

}

- (void)didRemoveImageAtIndexPath:(NSIndexPath *)indexPath{
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Image Picker Delegate
- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    [self.assets addObjectsFromArray:assets];
    [self.collectionView reloadData];
}

@end




