//
//  CircleEditViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-07.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleEditViewController.h"
#import "Theme.h"
#import "GCPTextView.h"
#import "ImagePicker.h"
#import "UIImageView+ImageCache.h"
@interface CircleEditViewController () <ImagePickerDelegate,FetchCenterDelegate>
@property (nonatomic,weak) IBOutlet UITextField *titleTextField;
@property (nonatomic,weak) IBOutlet GCPTextView *detailTextView;
@property (nonatomic,weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic,strong) ImagePicker *imagePicker;
@property (nonatomic) BOOL imageButtonImageChanged;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

@implementation CircleEditViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}
- (void)setUpNavigationItem
{
    
    //Left Bar Button
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    //Right Bar Button
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneBtn setFrame:CGRectMake(0, 0, 40, 25)];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTintColor:[Theme globleColor]];
    [doneBtn addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
    
    //Title
    self.navigationItem.title = @"编辑圈子资料";
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    if (self.circle.mCoverImageId.length > 0) {
        [self.coverImageView downloadImageWithImageId:self.circle.mCoverImageId
                                                 size:FetchCenterImageSize100];
    }
    self.titleTextField.text = self.circle.mTitle;
    self.detailTextView.text = self.circle.mDescription;
}

- (void)donePressed:(UIButton *)sender{
    if (self.titleTextField.hasText) {
        [self.titleTextField resignFirstResponder];
        //菊花开放
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        //如果设置了封面就先上传封面
        if (self.imageButtonImageChanged) {
            //缩小图像
            CGSize newSize = self.coverImageView.frame.size;
            UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
            [self.coverImageView.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self.fetchCenter postImageWithOperation:resizedImage complete:^(NSString *fetchedId) {
                //更新圈子
                [self updateCircle:fetchedId sender:sender];
            }];
        }else{
            if ([self.titleTextField.text isEqualToString:self.circle.mTitle] &&
                [self.detailTextView.text isEqualToString:self.circle.mDescription]) {
                [self goBackWithSender:sender];
            }else{
                [self updateCircle:nil sender:sender];
            }
        }
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请填写圈子的名字"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)updateCircle:(NSString *)imageId sender:(UIButton *)sender{
    [self.fetchCenter updateCircle:self.circle.mUID
                              name:self.titleTextField.text
                       description:self.detailTextView.text
                   backgroundImage:imageId
                        completion:^
    {
         [self goBackWithSender:sender];
    }];
}

- (void)goBackWithSender:(UIButton *)sender{
    //返回上一级
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sender];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)imageButtonPressed {
    [self.imagePicker showImagePickerForUploadProfileImage:self type:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    if (assets.count == 1 && [assets.firstObject isKindOfClass:[UIImage class]]) {
        UIImage *image = assets.firstObject;
        self.coverImageView.image = image;
        self.imageButtonImageChanged = YES;
    }
}

@end
