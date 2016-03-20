//
//  CircleCreationViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-01.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleCreationViewController.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "GCPTextView.h"
#import "ImagePicker.h"
@interface CircleCreationViewController () <ImagePickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet GCPTextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (nonatomic,strong) ImagePicker *imagePicker;
@property (nonatomic) BOOL hasUserSelectedCircleCoverImage;
@end

@implementation CircleCreationViewController

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
    self.navigationItem.title = @"新建圈子";
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpNavigationItem];
    
    //设置描述框UI
    [self.detailTextView setPlaceholder:@"给圈子添加描述能让别人更快了解哦。"];
    self.detailTextView.layer.borderColor = [UIColor lightTextColor].CGColor;
    self.detailTextView.layer.borderWidth = 1.0f;
    
    [self resetImageButton];
}



- (void)donePressed:(UIButton *)sender{
    if (self.titleTextField.hasText) {
        [self.titleTextField resignFirstResponder];
        //菊花开放
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        UIImage *image = self.imageButton.imageView.image;
        //如果设置了封面就先上传封面
        if (image) {
            //缩小图像
            CGSize newSize = self.imageButton.frame.size;
            UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
            [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self.fetchCenter postImageWithOperation:resizedImage complete:^(NSString *fetchedId) {
                //创建圈子
                [self createCircle:fetchedId sender:sender];
            }];
        }else{
            [self createCircle:nil sender:sender];
        }
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请填写圈子的名字"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)createCircle:(NSString *)imageId sender:(UIButton *)sender{
    [self.fetchCenter createCircle:self.titleTextField.text
                       description:self.detailTextView.text
                 backgroundImageId:imageId
                        completion:^(Circle *circle)
     {
//         [self.delegate didFinishCreatingCircle];
         //返回上一级
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sender];
         [self.navigationController popViewControllerAnimated:YES];
     }];
}


#pragma mark - 圈子封面图
- (void)resetImageButton{
    //设置封面按扭UI
    self.imageButton.layer.borderWidth = 2.0f;
    self.imageButton.layer.borderColor = [Theme globleColor].CGColor;
    [self.imageButton setTitle:@"添加圈子头像" forState:UIControlStateNormal];
    [self.imageButton setBackgroundImage:[Theme circleCreationImageBackground]
                                forState:UIControlStateNormal];
    [self.imageButton setImage:nil forState:UIControlStateNormal];
}

- (void)setupImageButton:(UIImage *)image{
    [self.imageButton setTitle:nil forState:UIControlStateNormal];
    [self.imageButton setImage:image forState:UIControlStateNormal];
    self.hasUserSelectedCircleCoverImage = YES;
}


- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (IBAction)imageButtonPressed:(UIButton *)sender {
    if (self.hasUserSelectedCircleCoverImage) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self resetImageButton];
        }];
        
        UIAlertAction *pickImageAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.imagePicker showImagePickerForUploadProfileImage:self type:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        [actionSheet addAction:pickImageAction];
        [actionSheet addAction:deleteAction];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }else{
        [self.imagePicker showImagePickerForUploadProfileImage:self type:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    if (assets.count == 1 && [assets.firstObject isKindOfClass:[UIImage class]]) {
        UIImage *image = assets.firstObject;
        [self setupImageButton:image];
    }
}

#pragma mark - 创建圈子

@end




