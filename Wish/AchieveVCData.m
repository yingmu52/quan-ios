//
//  AchieveVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-23.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AchieveVCData.h"
@import CoreData;
#import "Plan.h"
#import "User.h"
#define ACHIEVECELLID @"AchievementCell"
#import "WishDetailVCOwner.h"
@interface AchieveVCData () <NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) UIImageView *emptySignImageView;
@property (nonatomic,strong) UIView *timeLine;
@property (nonatomic,strong) NSDateFormatter *formatter;
@end

@implementation AchieveVCData

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWishDetailFromAchievement"]) {
        [segue.destinationViewController setPlan:sender];
    }
}

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy-MM-dd";
    }
    return _formatter;
}
#pragma mark - UITableViewController Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableFetchedRC.fetchedObjects.count;
}

- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ACHIEVECELLID
                                                        forIndexPath:indexPath];

    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    
    cell.ms_dateLabel.text = [NSString stringWithFormat:@"%@ - ",[self.formatter stringFromDate:plan.updateDate]];

    cell.ms_statusLabel.text = plan.planStatusTags[plan.planStatus.integerValue];
    cell.ms_title.text = plan.planTitle;
    cell.ms_subTitle.text = [NSString stringWithFormat:@"%@个记录\t%@人关注",plan.tryTimes,plan.followCount];
    
    UIImage *badge;
    if (plan.planStatus.integerValue == PlanStatusFinished) badge = [Theme achievementFinish];
    cell.ms_imageView2.image = badge;
    [cell.ms_imageView1 downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize200];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showWishDetailFromAchievement" sender:plan];
    
}

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId == %@ && planStatus != %d",[User uid],PlanStatusOnGoing];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    }
    return _tableFetchRequest;
}


- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    if (self.tableFetchedRC.fetchedObjects.count == 0) {
        [self setupEmptySign];
    }
}

#pragma mark - application life cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupEmptySign];
}

- (void)setupEmptySign{
    if (!self.tableFetchedRC.fetchedObjects.count){ //empty data
        self.tableView.scrollEnabled = NO;
        if (!self.emptySignImageView){
            
            CGFloat width = 206.0f/640 * CGRectGetWidth(self.view.bounds);
            CGFloat height = width * 249.0f / 206;
            CGFloat x = self.view.center.x - width/2;
            CGFloat y = self.view.center.y - height;
            self.emptySignImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)];
            self.emptySignImageView.image = [Theme achieveBadageEmpty];
            [self.view addSubview:self.emptySignImageView];
        }
        if (self.timeLine) [self.timeLine removeFromSuperview];
    }else{
        self.tableView.scrollEnabled = YES;
        if (self.emptySignImageView) [self.emptySignImageView removeFromSuperview];
        if (!self.timeLine){
            CGRect rect = CGRectMake(self.view.bounds.origin.x + self.view.bounds.size.width * 178/640,0,2,self.view.bounds.size.height*2);
            self.timeLine = [[UIView alloc] initWithFrame:rect];
            
            //add timeline to background
            self.timeLine.backgroundColor = [SystemUtil colorFromHexString:@"#33c7b7"];
            
            UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
            [bgView addSubview:self.timeLine];
            self.tableView.backgroundView = bgView;
        }
    }
}

@end
