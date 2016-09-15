//
//  PlanManagementViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/15/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "PlanManagementViewController.h"
#import "MBProgressHUD.h"
@interface PlanManagementViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic,weak) IBOutlet UITextView *textView;
@property (nonatomic,weak) Plan *selectedPlan;
@property (nonatomic,weak) Circle *selectedCircle;
@end

@implementation PlanManagementViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self updateTextView];
}

- (NSFetchRequest *)collectionFetchRequest{ //事件列表，放在collectionFRC
    if (!_collectionFetchRequest) {
        _collectionFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _collectionFetchRequest.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId == %@",[User uid]];
        _collectionFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _collectionFetchRequest;
}


- (NSFetchRequest *)tableFetchRequest{ //圈子列表，放在tableFRC
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Circle"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.collectionFetchedRC.fetchedObjects.count;
    }
    if (component == 1) {
        return self.tableFetchedRC.fetchedObjects.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    if(component == 0){
        Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
        return plan.planTitle;
    }
    if (component == 1) {
        Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
        return circle.circleName;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
    if(component == 0){
        Plan *plan = [self.collectionFetchedRC objectAtIndexPath:index];
        if (plan) {
            self.selectedPlan = plan;
        }
    }
    if (component == 1) {
        Circle *circle = [self.tableFetchedRC objectAtIndexPath:index];
        if (circle) {
            self.selectedCircle = circle;
        }
    }
    [self updateTextView];
}

- (void)updateTextView{
    if (self.selectedCircle && self.selectedPlan) {
        self.textView.text = [NSString stringWithFormat:@"点击完成\n将\n事件：《%@》\n放到\n圈子：%@",self.selectedPlan.planTitle,self.selectedCircle.circleName];
    }else{
        if (!self.selectedPlan) {
            self.textView.text = @"请选择事件";
        }
        if (!self.selectedCircle) {
            self.textView.text = @"请选择归属的圈子";
        }
    }
}

- (Circle *)selectedCircle{
    if (!_selectedCircle) {
        _selectedCircle = self.tableFetchedRC.fetchedObjects.firstObject;
    }
    return _selectedCircle;
}

-(Plan *)selectedPlan{
    if (!_selectedPlan) {
        _selectedPlan = self.collectionFetchedRC.fetchedObjects.firstObject;
    }
    return _selectedPlan;
}

- (IBAction)donePressed{
    if (self.selectedCircle && self.selectedPlan) {
        [self.fetchCenter updatePlanId:self.selectedPlan.planId
                            inCircleId:self.selectedCircle.circleId
                            completion:^
        {
            //提示加入成功
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                                                      animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"设置成功";
            [hud hideAnimated:YES afterDelay:1.0];
        }];
    }
}

@end
