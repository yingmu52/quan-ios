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
#import "WishDetailVCFollower.h"
#import "User.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FetchCenter.h"
@interface AchieveVCData () <NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@end

@implementation AchieveVCData

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanFromAchievement"]) {
        [segue.destinationViewController setPlan:sender];
    }
}


#pragma mark - UITableViewController Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}

- (AchieveCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AchieveCell *cell = [tableView dequeueReusableCellWithIdentifier:ACHIEVECELLID
                                                        forIndexPath:indexPath];

    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    cell.dateLabel.text = [SystemUtil stringFromDate:plan.updateDate];
    cell.planStatusLabel.text = plan.planStatusTags[plan.planStatus.integerValue];
    cell.planTitleLabel.text = plan.planTitle;
    cell.planSubtitleLabel.text = [NSString stringWithFormat:@"共有%@条纪录",@(plan.feeds.count)];
    
    UIImage *badge;
    if (plan.planStatus.integerValue == PlanStatusFinished) badge = [Theme achievementFinish];
    if (plan.planStatus.integerValue == PlanStatusGiveTheFuckingUp) badge = [Theme achievementFail];
    cell.badgeImageView.image = badge;
    if (plan.image){
        cell.planImageView.image = plan.image;
    }else{
        [cell.planImageView setImageWithURL:[[FetchCenter new] urlWithImageID:plan.backgroundNum]
                usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }

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
    request.predicate = [NSPredicate predicateWithFormat:@"ownerId == %@ && planStatus != %d",[User uid],PlanStatusOnGoing];
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
    [self.tableView reloadData];
}
@end
