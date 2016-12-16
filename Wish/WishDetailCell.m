//
//  WishDetailCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+ImageCache.h"

@interface WishDetailCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainStackHeight;
@end
@implementation WishDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    
}


- (IBAction)like:(UIButton *)sender{
    [self.delegate didPressedLikeOnCell:self];
}

- (IBAction)morePressed:(UIButton *)sender{
    [self.delegate didPressedMoreOnCell:self];
}


- (CGFloat)setupForImageCount:(NSArray *)imageIds{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    switch (imageIds.count) {
        case 1: //imageView 1
            self.imageView7.superview.hidden = YES; //hide upper stack 3
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            self.imageView3.superview.hidden = YES; //hide left-down stack
            self.imageView5.superview.hidden = YES; //hide Right stack
            self.imageView2.hidden = YES; //hide left-up second image
            _mainStackHeight.constant = screenWidth;
            [self.imageView1 downloadImageWithImageId:imageIds.lastObject size:FetchCenterImageSize800];
            break;
        case 2: //imageView 1 2
            self.imageView7.superview.hidden = YES; //hide upper stack 3
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            self.imageView3.superview.hidden = YES; //hide left-down stack
            self.imageView5.superview.hidden = YES; //hide Right stack
            _mainStackHeight.constant = screenWidth / 2;
            [self.imageView1 downloadImageWithImageId:imageIds.firstObject size:FetchCenterImageSize400];
            [self.imageView2 downloadImageWithImageId:imageIds.lastObject size:FetchCenterImageSize400];
            break;
        case 3: //imageView 1 5 6
            self.imageView7.superview.hidden = YES; //hide upper stack 3
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            self.imageView2.hidden = YES; //hide left-up second image
            self.imageView3.superview.hidden = YES; //hide left-down stack
            _mainStackHeight.constant = screenWidth * 2 / 3 ;
            [self.imageView1 downloadImageWithImageId:imageIds[0] size:FetchCenterImageSize400];
            [self.imageView5 downloadImageWithImageId:imageIds[1] size:FetchCenterImageSize200];
            [self.imageView6 downloadImageWithImageId:imageIds[2] size:FetchCenterImageSize200];
            break;
        case 4: //imageView 1 2 3 4
            self.imageView7.superview.hidden = YES; //hide upper stack 3
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            self.imageView5.superview.hidden = YES; //hide Right stack
            _mainStackHeight.constant = screenWidth;
            [self.imageView1 downloadImageWithImageId:imageIds[0] size:FetchCenterImageSize400];
            [self.imageView2 downloadImageWithImageId:imageIds[1] size:FetchCenterImageSize400];
            [self.imageView3 downloadImageWithImageId:imageIds[2] size:FetchCenterImageSize400];
            [self.imageView4 downloadImageWithImageId:imageIds[3] size:FetchCenterImageSize400];
            break;
        case 5: //imageView 1 2 7 8 9
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            self.imageView5.superview.hidden = YES; //hide Right stack
            self.imageView3.superview.hidden = YES; //hide left-down stack
            _mainStackHeight.constant = screenWidth * 5 / 6;
            [self.imageView1 downloadImageWithImageId:imageIds[0] size:FetchCenterImageSize400];
            [self.imageView2 downloadImageWithImageId:imageIds[1] size:FetchCenterImageSize400];
            [self.imageView7 downloadImageWithImageId:imageIds[2] size:FetchCenterImageSize200];
            [self.imageView8 downloadImageWithImageId:imageIds[3] size:FetchCenterImageSize200];
            [self.imageView9 downloadImageWithImageId:imageIds[4] size:FetchCenterImageSize200];
            break;
        case 6: //imageView 1 5 6 7 8 9
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            self.imageView2.hidden = YES; //hide left-up second image
            self.imageView3.superview.hidden = YES; //hide left-down stack
            _mainStackHeight.constant = screenWidth;
            [self.imageView1 downloadImageWithImageId:imageIds[0] size:FetchCenterImageSize400];
            [self.imageView5 downloadImageWithImageId:imageIds[1] size:FetchCenterImageSize200];
            [self.imageView6 downloadImageWithImageId:imageIds[2] size:FetchCenterImageSize200];
            [self.imageView7 downloadImageWithImageId:imageIds[3] size:FetchCenterImageSize200];
            [self.imageView8 downloadImageWithImageId:imageIds[4] size:FetchCenterImageSize200];
            [self.imageView9 downloadImageWithImageId:imageIds[5] size:FetchCenterImageSize200];
            break;
        case 7: //imageView 1 2 3 4 7 8 9
            self.imageView5.superview.hidden = YES; //hide Right stack
            self.imageView10.superview.hidden = YES; //hide bottom stack 3
            _mainStackHeight.constant = screenWidth * 4 / 3;
            [self.imageView1 downloadImageWithImageId:imageIds[0] size:FetchCenterImageSize400];
            [self.imageView2 downloadImageWithImageId:imageIds[1] size:FetchCenterImageSize400];
            [self.imageView3 downloadImageWithImageId:imageIds[2] size:FetchCenterImageSize400];
            [self.imageView4 downloadImageWithImageId:imageIds[3] size:FetchCenterImageSize400];
            [self.imageView7 downloadImageWithImageId:imageIds[4] size:FetchCenterImageSize200];
            [self.imageView8 downloadImageWithImageId:imageIds[5] size:FetchCenterImageSize200];
            [self.imageView9 downloadImageWithImageId:imageIds[6] size:FetchCenterImageSize200];
            break;
        case 8: //imageView 1 2 7 8 9 10 11 12
            self.imageView5.superview.hidden = YES; //hide Right stack
            self.imageView3.superview.hidden = YES; //hide left-down stack
            _mainStackHeight.constant = screenWidth * 7 / 6;
            [self.imageView1 downloadImageWithImageId:imageIds[0] size:FetchCenterImageSize400];
            [self.imageView2 downloadImageWithImageId:imageIds[1] size:FetchCenterImageSize400];
            [self.imageView7 downloadImageWithImageId:imageIds[2] size:FetchCenterImageSize200];
            [self.imageView8 downloadImageWithImageId:imageIds[3] size:FetchCenterImageSize200];
            [self.imageView9 downloadImageWithImageId:imageIds[4] size:FetchCenterImageSize200];
            [self.imageView10 downloadImageWithImageId:imageIds[5] size:FetchCenterImageSize200];
            [self.imageView11 downloadImageWithImageId:imageIds[6] size:FetchCenterImageSize200];
            [self.imageView12 downloadImageWithImageId:imageIds[7] size:FetchCenterImageSize200];
        default:
            NSAssert(imageIds.count >= 1 && imageIds.count <= 8, @"Invalid Count Range");
            break;
    }
    [self.contentView layoutIfNeeded];
    NSLog(@"%@",@(_mainStackHeight.constant));
    return _mainStackHeight.constant;
}

- (IBAction)buttonPressed:(UIButton *)sender{
    NSLog(@"%@",@(sender.tag));
}


- (void)prepareForReuse{
    [super prepareForReuse];
    self.imageView2.hidden = NO;
    self.imageView3.superview.hidden = NO;
    self.imageView5.superview.hidden = NO;
    self.imageView7.superview.hidden = NO;
    self.imageView10.superview.hidden = NO;
    
    
    [self.imageView1 setImage:nil forState:UIControlStateNormal];
    [self.imageView2 setImage:nil forState:UIControlStateNormal];
    [self.imageView3 setImage:nil forState:UIControlStateNormal];
    [self.imageView4 setImage:nil forState:UIControlStateNormal];
    [self.imageView5 setImage:nil forState:UIControlStateNormal];
    [self.imageView6 setImage:nil forState:UIControlStateNormal];
    [self.imageView7 setImage:nil forState:UIControlStateNormal];
    [self.imageView8 setImage:nil forState:UIControlStateNormal];
    [self.imageView9 setImage:nil forState:UIControlStateNormal];
    [self.imageView10 setImage:nil forState:UIControlStateNormal];
    [self.imageView11 setImage:nil forState:UIControlStateNormal];
    [self.imageView12 setImage:nil forState:UIControlStateNormal];

}

@end












