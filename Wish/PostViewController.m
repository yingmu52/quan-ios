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
#import "KeyWordCell.h"
#import "NHAlignmentFlowLayout.h"
@interface PostViewController () <UITextFieldDelegate>
//<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,strong) UIButton *tikButton;

//@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

//@property (nonatomic,strong) NSArray *keywordArray;
@end

@implementation PostViewController

//- (NSArray *)keywordArray{
//    if (!_keywordArray){
//        _keywordArray = @[@"每天一部电影的365天",
//                          @"当一个小皮匠",
//                          @"跑步绕地球一圈",
//                          @"在每省都拉过屎"];
//    }
//    return _keywordArray;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.textField.text = nil;
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
    
    
    
//    //set up collection view
//    NHAlignmentFlowLayout *layout = [[NHAlignmentFlowLayout alloc] init];
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    layout.alignment = NHAlignmentTopLeftAligned;
//    layout.minimumInteritemSpacing = 10.0f;
//    layout.minimumLineSpacing = 10.0f;
//
////    layout.itemSize = CGSizeMake((arc4random_uniform(1)+1)*100.0f, 44.0f);
//    self.collectionView.collectionViewLayout = layout;
    
    
}

- (void)textFieldDidUpdate{
    if (self.textField.isFirstResponder){
        BOOL flag = self.textField.text.length*[self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
        
    }
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


#pragma mark - text field 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger limit = 15;
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > limit){
        return NO;
    }
    return YES;
}
#pragma mark - collection view delegate
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.keywordArray.count;
//}
//
//
//- (KeyWordCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    KeyWordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KeyWordCell"
//                                                                    forIndexPath:indexPath];
//
//    cell.keywordLabel.text = self.keywordArray[indexPath.row];
//    return cell;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UILabel *label = [UILabel new];
//    label.text = self.keywordArray[indexPath.row];
//    label.font = [UIFont systemFontOfSize:14.0];
//    [label sizeToFit];
//    
////    [collectionView layoutIfNeeded];
//    CGFloat expectedWidth = label.intrinsicContentSize.width + 25.0f;
//    CGFloat maxWidth = CGRectGetWidth(collectionView.frame);
//    if (maxWidth < expectedWidth) {
//        expectedWidth = maxWidth;
//    }
//    return CGSizeMake(expectedWidth,69.0 / 1136 * self.view.frame.size.height);
//}
//
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    KeyWordCell *cell = (KeyWordCell *)[collectionView cellForItemAtIndexPath:indexPath];
//
//    self.textField.text = cell.keywordLabel.text;
//    [self textFieldDidUpdate];
//
//
//}
//
//
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    KeyWordCell *cell = (KeyWordCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundImageView.alpha = 0.67f;
//}
//
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    KeyWordCell *cell = (KeyWordCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundImageView.alpha = 1.0f;
//
//}
@end
