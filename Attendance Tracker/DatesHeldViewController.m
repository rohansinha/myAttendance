//
//  DatesHeldViewController.m
//  Attendance Tracker
//
//  Created by Rohan Sinha on 21/7/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import "DatesHeldViewController.h"
#import "DetailViewController.h"

@interface DatesHeldViewController ()

@end

@implementation DatesHeldViewController
{
    NSIndexPath *datePickerIndexPath;
    float pickerCellRowHeight;
    NSDateFormatter *formatDate;
    NSMutableArray *dates;
    NSMutableArray *removed;
}

@synthesize heldDates, delegate;

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
    // Do any additional setup after loading the view.
    formatDate = [[NSDateFormatter alloc] init];
    //[formatDate setDateStyle:NSDateFormatterLongStyle];
    [formatDate setDateFormat:@"EEEE, dd MMMM yyyy"];
    //[formatDate setTimeStyle:NSDateFormatterNoStyle];
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:@"datePickerCell"];
    pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
    
    dates = [[NSMutableArray alloc] initWithArray:heldDates];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(setNewDates:remove:)]) {
        // finish editing
        // prepare selection info
        [self.delegate setNewDates:dates remove:removed];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    NSIndexPath *parentCellIndexPath = nil;
    
    if ([self datePickerIsShown])
        parentCellIndexPath = [NSIndexPath indexPathForRow:datePickerIndexPath.row - 1 inSection:0];
    else return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:parentCellIndexPath];
    dates[parentCellIndexPath.row] = sender.date;
    cell.textLabel.text = [formatDate stringFromDate:sender.date];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)datePickerIsShown {
    return datePickerIndexPath != nil;
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
    NSInteger numberOfRows = [dates count];
    if([self datePickerIsShown])
        numberOfRows++;
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Classes held on...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([self datePickerIsShown] && (datePickerIndexPath.row == indexPath.row)){
        cell = [self createPickerCell:dates[indexPath.row -1]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
        [[cell textLabel] setText:[formatDate stringFromDate:[dates objectAtIndex:indexPath.row]]];
    }
    
    return cell;
}

- (UITableViewCell *)createPickerCell:(NSDate *)date {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"datePickerCell"];
    
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
    
    CGFloat rowHeight = self.tableView.rowHeight;
    
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
        removed = [[NSMutableArray alloc] init];
        [removed addObject:[dates objectAtIndex:indexPath.row]];
        [dates removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } /*else if (editingStyle == UITableViewCellEditingStyleInsert) {
       // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
       NSDictionary *temp = [[NSDictionary alloc] init];
       //add code to accept user input for name and course code to add to temp
       [courses addObject:temp];
       }*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    
    if ([self datePickerIsShown] && (datePickerIndexPath.row - 1 == indexPath.row)){
        [self hideExistingPicker];
    } else {
        
        NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
        
        if ([self datePickerIsShown])
            [self hideExistingPicker];
        
        [self showNewPickerAtIndex:newPickerIndexPath];
        
        datePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
}

- (void)hideExistingPicker {
    
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePickerIndexPath.row inSection:0]]
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
    
    [self.tableView insertRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationFade];
}

@end
