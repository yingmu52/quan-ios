//
//  PostViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostViewController.h"
#import "Theme.h"
#import "PostFeedViewController.h"
#import "NHAlignmentFlowLayout.h"
#import "CirclePickerViewController.h"
#import "ImagePicker.h"
#import "PlansViewController.h"
@interface PostViewController () <CirclePickerViewControllerDelegate,ImagePickerDelegate>
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UILabel *infoLabel;
@property (nonatomic,strong) ImagePicker *imagePicker;
@end

@implementation PostViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
    //为快速创建事件推荐一个圈子
    NSString *circleId = [User currentCircleId];
    if (circleId.length > 0 && !self.circle) {
        Circle *circle = [Circle fetchID:circleId inManagedObjectContext:[AppDelegate getContext]];
        self.circle = circle;
    }
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

- (void)setTextField:(UITextField *)textField{
    _textField = textField;
    _textField.layer.borderColor = [Theme postTabBorderColor].CGColor;
    _textField.layer.borderWidth = 1.0;
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,1)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setupViews
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDisable]
                                           target:self
                                         selector:@selector(goToNextView)
                                            frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.textField addTarget:self action:@selector(textFieldDidUpdate) forControlEvents:UIControlEventEditingChanged];
    
    if (self.circle) {
        self.infoLabel.text = [NSString stringWithFormat:@"所属圈子：%@",self.circle.mTitle];
    }
}

- (void)textFieldDidUpdate{
    if (self.textField.isFirstResponder){
        BOOL flag = self.textField.text.length*[self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
        
        //keep maximum 50 characters
        NSInteger maxCount = 50;
        if (self.textField.text.length > maxCount) [self.textField setText:[self.textField.text substringToIndex:maxCount]];
    }
}


- (void)goToNextView
{
    if (!self.circle) {
        [self performSegueWithIdentifier:@"showCirclePickerFromPost" sender:nil];
        [self.textField resignFirstResponder];
    }else{
        //打开照片选取器
        [self.imagePicker showPhotoLibrary:self];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPostFeedFromPostView"]) {
        PostFeedViewController *pfvc = (PostFeedViewController *)segue.destinationViewController;
        pfvc.circle = self.circle;
        pfvc.assets = sender;
        pfvc.seugeFromPlanCreation = YES; // important!
        pfvc.navigationItem.title = self.textField.text;
    }
    
    if ([segue.identifier isEqualToString:@"showCirclePickerFromPost"]) {
        CirclePickerViewController *cpc = segue.destinationViewController;
        cpc.delegate = self;
    }
}

- (void)didFinishPickingCircle:(Circle *)circle{
    //设置圈子
    self.circle = circle;
}

- (void)setCircle:(Circle *)circle{
    _circle = circle;
    self.infoLabel.text = [NSString stringWithFormat:@"所属圈子：%@",circle.mTitle];
}


#pragma mark - 选取照片

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    [self performSegueWithIdentifier:@"ShowPostFeedFromPostView" sender:[assets mutableCopy]];
}

- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}


@end










