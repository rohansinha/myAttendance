//
//  DetailViewController.m
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import "DetailViewController.h"
#import "CoursesViewController.h"
#import "DatesHeldViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
{
    NSNumber *numMissed;
    NSNumber *numHeld;
    NSMutableArray *missedDates;
    NSMutableArray *heldDates;
    NSIndexPath *datePickerIndexPath;
    float pickerCellRowHeight;
    NSDateFormatter *formatDate;
    NSArray *removedDates;
}

@synthesize selection, delegate, label1, label2, percentage, lectures, missedLectures, requirement, estimate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = selection[@"code"];
    formatDate = [[NSDateFormatter alloc] init];
    //[formatDate setDateStyle:NSDateFormatterLongStyle];
    [formatDate setDateFormat:@"EEEE, dd MMMM yyyy"];
    //[formatDate setTimeStyle:NSDateFormatterNoStyle];
    
    UITableViewCell *pickerViewCellToCheck = [datesTable dequeueReusableCellWithIdentifier:@"datePickerCell"];
    pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
    
    // Do any additional setup after loading the view.
    numHeld = [selection objectForKey:@"numHeld"];
    numMissed = [selection objectForKey:@"numMissed"];
    missedDates = [selection objectForKey:@"missedDates"];
    heldDates = [selection objectForKey:@"heldDates"];
    
    [label1 setText:[NSString stringWithFormat:@"%d", [numHeld intValue]]];
    [label2 setText:[NSString stringWithFormat:@"%d", [numMissed intValue]]];
    
    [lectures setValue:[numHeld doubleValue]];
    [lectures setMaximumValue:[[selection objectForKey:@"maxClasses"] doubleValue]];
    [lectures setMinimumValue:0];
    
    [missedLectures setValue:[numMissed doubleValue]];
    [missedLectures setMaximumValue:[lectures value]];
    [missedLectures setMinimumValue:0];
    
    if([numHeld intValue] > 0) {
        [self percentageSet];
    } else {
        [percentage setText:@""];
        [estimate setText:@""];
    }
    [requirement setText:[NSString stringWithFormat:@"Requirement: %d", [[selection objectForKey:@"req"] intValue]]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(editedSelection:)]) {
        // finish editing
        // prepare selection info
        NSDictionary *change = @{@"indexPath" : selection[@"indexPath"],
                                 @"numHeld" : numHeld,
                                 @"numMissed" : numMissed,
                                 @"title" : [selection objectForKey:@"title"],
                                 @"code" : [selection objectForKey:@"code"],
                                 @"maxClasses" : [selection objectForKey:@"maxClasses"],
                                 @"req" : [selection objectForKey:@"req"],
                                 @"missedDates" : missedDates,
                                 @"heldDates" : heldDates,
                                 @"type" : selection[@"type"]};
        [self.delegate editedSelection:change];
    }
}

- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    NSIndexPath *parentCellIndexPath = nil;
    
    if ([self datePickerIsShown])
        parentCellIndexPath = [NSIndexPath indexPathForRow:datePickerIndexPath.row - 1 inSection:0];
    else return;
    
    UITableViewCell *cell = [datesTable cellForRowAtIndexPath:parentCellIndexPath];
    missedDates[parentCellIndexPath.row] = sender.date;
    cell.textLabel.text = [formatDate stringFromDate:sender.date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)datePickerIsShown {
    return datePickerIndexPath != nil;
}

- (void)setNewDates:(NSMutableArray *)newDates remove:(NSArray *)removed
{
    removedDates = [[NSArray alloc] initWithArray:removed];
    [heldDates removeAllObjects];
    heldDates = [newDates mutableCopy];
    int classes = [heldDates count];
    numHeld = [NSNumber numberWithInt:classes];
    [lectures setValue:classes];
    if(classes < (int)[missedLectures value]) {
        int numToRemove = (int)[missedLectures value]-classes;
        [missedLectures setValue:classes];
        [self.label2 setText:[NSString stringWithFormat:@"%d", classes]];
        for(int i = 0; i < numToRemove; i++)
            [missedDates removeLastObject];
        [datesTable reloadData];
    }
    if(classes > 0)
        [self percentageSet];
    
    [missedLectures setMaximumValue:[lectures value]];
    [self.label1 setText:[NSString stringWithFormat:@"%d", classes]];
}

- (void) percentageSet
{
    int classes = [lectures value];
    int bunk = [missedLectures value];
    int max = [selection[@"maxClasses"] intValue];
    int percent = 100-((bunk*100)/classes);
    int est = 100-((bunk*100)/max);
    
    if (est < [[selection objectForKey:@"req"] intValue]) {
        [estimate setTextColor:[UIColor redColor]];
    } else {
        [estimate setTextColor:[UIColor blackColor]];
    }
    [percentage setText:[NSString stringWithFormat:@"Attendance: %d%%", percent]];
    [estimate setText:[NSString stringWithFormat:@"Estimated attendance: %d%%", est]];
}

- (IBAction)held:(id)sender {
    int classes = [lectures value];
    int old = [numHeld intValue];
    numHeld = [NSNumber numberWithInt:classes];
    int new = [numHeld intValue];
    
    if(old > new)
    {
        if(classes < (int)[missedLectures value]) {
            [missedLectures setValue:classes];
            [self.label2 setText:[NSString stringWithFormat:@"%d", classes]];
            [missedDates removeLastObject];
            [datesTable reloadData];
        }
        [heldDates removeLastObject];
    } else {
        NSDate *now = [NSDate date];
        [heldDates addObject:now];
    }
    
    if(classes > 0)
        [self percentageSet];
    
    [missedLectures setMaximumValue:[lectures value]];
    [self.label1 setText:[NSString stringWithFormat:@"%d", classes]];
}

- (IBAction)missed:(id)sender {
    int classes = [missedLectures value];
    int old = [numMissed intValue];
    numMissed = [NSNumber numberWithInt:classes];
    int new = [numMissed intValue];
    [self percentageSet];
    [self.label2 setText:[NSString stringWithFormat:@"%d", classes]];
    
    if(old > new)
    {
        //minus pressed
        [missedDates removeLastObject];
    } else {
        //plus pressed
        NSDate *now = [NSDate date];
        [missedDates addObject:now];
    }
    //NSLog(@"%@", missedDates);
    [datesTable reloadData];
}

#pragma mark - table View Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = [missedDates count];
    if([self datePickerIsShown])
        numberOfRows++;
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"You missed class on...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([self datePickerIsShown] && (datePickerIndexPath.row == indexPath.row)){
        cell = [self createPickerCell:missedDates[indexPath.row -1]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
        [[cell textLabel] setText:[formatDate stringFromDate:[missedDates objectAtIndex:indexPath.row]]];
    }
    
    return cell;
}

- (UITableViewCell *)createPickerCell:(NSDate *)date {
    
    UITableViewCell *cell = [datesTable dequeueReusableCellWithIdentifier:@"datePickerCell"];
    
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:1];
    
    [targetedDatePicker setDate:date animated:NO];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = datesTable.rowHeight;
    
    if ([self datePickerIsShown] && (datePickerIndexPath.row == indexPath.row)) {
        rowHeight = pickerCellRowHeight;
    }
    return rowHeight;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [missedDates removeObjectAtIndex:indexPath.row];
        int value = [numMissed intValue];
        value--;
        numMissed = [NSNumber numberWithInt:value];
        [missedLectures setValue:value];
        [label2 setText:[NSString stringWithFormat:@"%d", value]];
        [self percentageSet];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } /*else if (editingStyle == UITableViewCellEditingStyleInsert) {
       // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
       NSDictionary *temp = [[NSDictionary alloc] init];
       //add code to accept user input for name and course code to add to temp
       [courses addObject:temp];
       }*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [datesTable beginUpdates];
    
    if ([self datePickerIsShown] && (datePickerIndexPath.row - 1 == indexPath.row)){
        [self hideExistingPicker];
    } else {
        
        NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
        
        if ([self datePickerIsShown])
            [self hideExistingPicker];
        
        [self showNewPickerAtIndex:newPickerIndexPath];
        
        datePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
    }
    
    [datesTable deselectRowAtIndexPath:indexPath animated:YES];
    
    [datesTable endUpdates];
}

- (void)hideExistingPicker {
    
    [datesTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePickerIndexPath.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    datePickerIndexPath = nil;
}

- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath {
    
    NSIndexPath *newIndexPath;
    
    if (([self datePickerIsShown]) && (datePickerIndexPath.row < selectedIndexPath.row)){
        
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
        
    }else {
        
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row  inSection:0];
        
    }
    
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    [datesTable insertRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDates"]) {
        DatesHeldViewController *dhvc = [segue destinationViewController];
        if ([dhvc respondsToSelector:@selector(setDelegate:)]) {
            [dhvc setValue:self forKey:@"delegate"];
        }
        if ([dhvc respondsToSelector:@selector(setHeldDates:)]) {
            [dhvc setValue:heldDates forKey:@"heldDates"];
        }
    }
}


@end
