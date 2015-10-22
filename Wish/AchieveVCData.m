//
//  AchieveVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-23.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AchieveVCData.h"
@import CoreData;
#import "AppDelegate.h"
#import "Plan+PlanCRUD.h"
#import "AchieveCell.h"
#import "WishDetailVCOwnerAchieved.h"
#import "User.h"
#import "UIImageView+ImageCache.h"
#import "FetchCenter.h"
@interface AchieveVCData () <NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) UIImageView *emptySignImageView;
@property (nonatomic,strong) UIView *timeLine;
@property (nonatomic,strong) NSDateFormatter *formatter;
@end

@implementation AchieveVCData

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanFromAchievement"]) {
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
    return self.fetchedRC.fetchedObjects.count;
}

- (AchieveCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AchieveCell *cell = [tableView dequeueReusableCellWithIdentifier:ACHIEVECELLID
                                                        forIndexPath:indexPath];

    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ - ",[self.formatter stringFromDate:plan.updateDate]];

    cell.planStatusLabel.text = plan.planStatusTags[plan.planStatus.integerValue];
    cell.planTitleLabel.text = plan.planTitle;
    cell.planSubtitleLabel.text = [NSString stringWithFormat:@"%@个记录\t%@人关注",plan.tryTimes,plan.followCount];
    
    UIImage *badge;
    if (plan.planStatus.integerValue == PlanStatusFinished) badge = [Theme achievementFinish];
    if (plan.planStatus.integerValue == PlanStatusGiveTheFuckingUp) badge = [Theme achievementFail];
    cell.badgeImageView.image = badge;
    [cell.planImageView downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize200];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showPlanFromAchievement" sender:plan];
    
}

#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId == %@ && planStatus != %d",[User uid],PlanStatusOnGoing];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    
    NSFetchedResultsController *newFRC =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedRC = newFRC;
    _fetchedRC.delegate = self;
    
    // Perform Fetch
    NSError *error = nil;
    [_fetchedRC performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    return _fetchedRC;
    
    
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self setupEmptySign];
    [self.tableView reloadData];
}

#pragma mark - application life cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupEmptySign];
}

- (void)setupEmptySign{
    if (!self.fetchedRC.fetchedObjects.count){ //empty data
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
