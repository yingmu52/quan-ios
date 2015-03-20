//
//  PostViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostViewController.h"
#import "Theme.h"
#import "PostDetailViewController.h"
@interface PostViewController () <UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn1;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn2;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn3;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn4;
@property (nonatomic,strong) UIButton *tikButton;
@end

@implementation PostViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
    [self setTitlesWishArray:@[@" 每天一部电影的365天    ", //1 left 4 right
                               @" 当一个小皮匠    ",
                               @" 跑步绕地球一圈    ",
                               @" 在每省都拉过屎    "]];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

- (IBAction)changedTitleOnButtonClick:(UIButton *)sender{
    self.textField.text = nil;
    self.textField.text = sender.titleLabel.text;
    [self textFieldDidUpdate];
}

- (void)setTitlesWishArray:(NSArray *)array{
    NSArray *valids = [array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
    [self.sgtBtn1 setTitle:valids[0] forState:UIControlStateNormal];
    [self.sgtBtn2 setTitle:valids[1] forState:UIControlStateNormal];
    [self.sgtBtn3 setTitle:valids[2] forState:UIControlStateNormal];
    [self.sgtBtn4 setTitle:valids[3] forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews
{
    [self setPatchImageForButtons:self.sgtBtn1];
    [self setPatchImageForButtons:self.sgtBtn2];
    [self setPatchImageForButtons:self.sgtBtn3];
    [self setPatchImageForButtons:self.sgtBtn4];
    self.sgtBtn1.backgroundColor = [UIColor clearColor];
    self.sgtBtn2.backgroundColor = [UIColor clearColor];
    self.sgtBtn3.backgroundColor = [UIColor clearColor];
    self.sgtBtn4.backgroundColor = [UIColor clearColor];
    
    self.textField.layer.borderColor = [Theme postTabBorderColor].CGColor;
    self.textField.layer.borderWidth = 1.0;
    
}

- (void)setPatchImageForButtons:(UIButton *)button
{
    UIImage *image = [Theme tipsBackgroundImage];

    UIImage *patchImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25.0,25.0,25.0,25.0)
                                                resizingMode:UIImageResizingModeTile];
    [button setBackgroundImage:patchImage
                      forState:UIControlStateNormal];
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
}

- (void)textFieldDidUpdate{
    BOOL flag = self.textField.text.length*[self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
    self.navigationItem.rightBarButtonItem.enabled = flag;
    UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
    [self.tikButton setImage:bg forState:UIControlStateNormal];
}


- (void)goToNextView
{
    [self performSegueWithIdentifier:@"showWritePostDetail" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWritePostDetail"]) {
        PostDetailViewController *pdvc = segue.destinationViewController;
        pdvc.titleFromPostView = self.textField.text;
    }
}


@end
