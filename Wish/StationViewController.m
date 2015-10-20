//
//  StationViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-19.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "StationViewController.h"
#import "UIImageView+ImageCache.h"

typedef enum {
    StationViewSelectionNone = -1,
    StationViewSelectionDelete = 0,
    StationViewSelectionFinish = 1
}StationViewSelection;



@interface StationViewController ()
@property (nonatomic,readonly) StationViewSelection selection;
@end

@implementation StationViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //设置模糊背影
    UIToolbar *layer = [[UIToolbar alloc] initWithFrame:self.view.frame];
    layer.barStyle = UIBarStyleBlackOpaque;
    [self.view insertSubview:layer atIndex:0];
    
    //设置小卡片封面
    NSURL *imageUrl = [self.fetchCenter urlWithImageID:self.plan.backgroundNum size:FetchCenterImageSize50];
    [self.cardImageView showImageWithImageUrl:imageUrl];

}

- (void)setLongPress:(UILongPressGestureRecognizer *)longPress{
    _longPress = longPress;
    _longPress.delegate = self;
    [_longPress addTarget:self action:@selector(handleLongPress:)];
    self.cardImageView.center = [_longPress locationInView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.longPress removeTarget:self action:@selector(handleLongPress:)];
}

- (StationViewSelection)selection
{
    if (CGRectIntersectsRect(self.deleteButton.frame, self.cardView.frame)) {
        return StationViewSelectionDelete;
    }else if (CGRectIntersectsRect(self.finishButton.frame, self.cardView.frame)){
        return StationViewSelectionFinish;
    }else{
        return StationViewSelectionNone;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    
    if (self.plan) {
        if (longPress.state == UIGestureRecognizerStateBegan) {

        }else if (longPress.state == UIGestureRecognizerStateChanged){
            
            //移动小卡片
            self.cardView.center = [longPress locationInView:self.view];
            
            //检测用户选择
            if (self.selection == StationViewSelectionDelete) {
                self.deleteButton.highlighted = YES;
            }else if (self.selection == StationViewSelectionFinish){
                self.finishButton.highlighted = YES;
            }else{
                self.deleteButton.highlighted = NO;
                self.finishButton.highlighted = NO;
            }

            
        }else if (longPress.state == UIGestureRecognizerStateEnded ||
                  longPress.state == UIGestureRecognizerStateFailed ||
                  longPress.state == UIGestureRecognizerStateCancelled) {
            if (self.selection != StationViewSelectionNone) {
                
                //执行用户执行的选择
                NSString *title;
                if (self.selection == StationViewSelectionFinish){
                    title = @"确定完成？";
                }else if (self.selection == StationViewSelectionDelete){
                    title = @"删除的事件不恢复哦！";
                }

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                //确定归档或删除
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action)
                                          {
                                              if (self.selection == StationViewSelectionFinish){
                                                  [self.plan updatePlanStatus:PlanStatusFinished];
                                              }else if (self.selection == StationViewSelectionDelete){
                                                  [self.plan deleteSelf];
                                              }
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                          }];
                
                //取消
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * _Nonnull action)
                                         {
                                             [self dismissViewControllerAnimated:YES completion:nil];
                                         }];
                
                [alert addAction:confirm];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

@end
