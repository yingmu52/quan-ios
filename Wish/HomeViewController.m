//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeViewController.h"
#import "UINavigationItem+CustomItem.h"
#import "Theme.h"
#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "HomeCardView.h"
#import "Plan+PlanCRUD.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "WishDetailViewController.h"
#import "MKPagePeekFlowLayout.h"
const NSUInteger maxCardNum = 10;

@interface HomeViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,HomeCardViewDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView *cardCollectionView;

@property (nonatomic,strong) NSMutableArray *myPlans;

@property (nonatomic,strong) UIImage *capturedImage;

@end

@implementation HomeViewController

- (void)reloadCards{
    dispatch_queue_t reloadQ =  dispatch_queue_create("reload cards", NULL);
    dispatch_async(reloadQ, ^{
        self.myPlans = [[Plan loadMyPlans:[AppDelegate getContext]] mutableCopy];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cardCollectionView reloadData];
            
        });
        
    });

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadCards];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupCollectionView];

}


- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self
                                      selector:@selector(openMenu)
                                         frame:frame];
    
    UIButton *addBtn = [Theme buttonWithImage:[Theme navAddDefault]
                                       target:self
                                     selector:@selector(addWish)
                                        frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    

}

- (void)openMenu{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark - db operation



- (void)addWish{
    if (self.myPlans.count > maxCardNum){
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"Life is too short for too many goddamn plans"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }else{
        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
    }
}


#pragma mark - Home Card View Delegate

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
        
        
//        [plan deleteSelf:[AppDelegate getContext]];

//        [self reloadCards];
        
    }
}

- (void)didTapOnHomeCardView:(HomeCardView *)cardView
{
//    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:nil];
}
#pragma mark - Camera Util

- (IBAction)showCamera:(UIButton *)sender{
    UIImagePickerController *controller = [SystemUtil showCamera:self];
    if (controller) {
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        self.capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage]; // this line and next line is sequentally important
//        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
//        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
//        NSLog(@"%@",NSStringFromCGSize(editedImage.size));
    }];
}


#pragma - 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
//        WishDetailViewController *controller = segue.destinationViewController;
#warning need to update!
    }
}

#pragma mark -
#pragma mark UICollectionView methods

-(void)setupCollectionView {

//    NSString *nibName = [NSString stringWithFormat:@"%@", [HomeCardView class]];
//    UINib *nib = [UINib nibWithNibName:nibName
//                                bundle:[NSBundle mainBundle]];
//    [self.cardCollectionView registerNib:nib
//              forCellWithReuseIdentifier:@"HomeCardCell"];
    self.cardCollectionView.backgroundColor = [UIColor clearColor];
    [self.cardCollectionView setPagingEnabled:YES];
//    MKPagePeekFlowLayout *layout = [[MKPagePeekFlowLayout alloc] init];
//    [self.cardCollectionView setCollectionViewLayout:layout];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.myPlans.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCardCell" forIndexPath:indexPath];
    
//    cell.plan = [self.myPlans objectAtIndex:indexPath.row];
    
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}




@end
