//
//  CoursesViewController.m
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import "CoursesViewController.h"
#import "CourseTableViewCell.h"
#import "DetailViewController.h"
#import "AddCourseViewController.h"
#import "EditCourseViewController.h"

@interface CoursesViewController ()

@end

@implementation CoursesViewController
{
    NSString *filePath;
    NSMutableArray *typesOfCourses;
}

@synthesize courses;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    courses = [[NSMutableArray alloc] init];
    typesOfCourses = [[NSMutableArray alloc] init];
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filePath = [NSString stringWithFormat:@"%@/data.plist", docDirectory];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        courses = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        for (NSMutableDictionary* course in courses)
        {
            if(!course[@"missedDates"]) [course setObject:[[NSMutableArray alloc] init] forKey:@"missedDates"];
            
            if(!course[@"heldDates"]) [course setObject:[[NSMutableArray alloc] init] forKey:@"heldDates"];
            
            if([typesOfCourses containsObject:[course objectForKey:@"type"]])
                continue;
            else [typesOfCourses addObject:[course objectForKey:@"type"]];
        }
        [courses writeToFile:filePath atomically:YES];
    } else courses = [[NSMutableArray alloc] init];
    
    self.navigationItem.title = @"Courses";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

/*
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Operations
- (void)addCourse:(NSDictionary *)course
{
    [courses addObject:course];
    [courses writeToFile:filePath atomically:YES];
    [self.tableView reloadData];
}

- (void)editedSelection:(NSDictionary *)course
{
    NSIndexPath *indexPath = course[@"indexPath"];
    NSDictionary *newValue = @{@"code" : course[@"code"],
                               @"title" : course[@"title"],
                               @"numHeld" : course[@"numHeld"],
                               @"numMissed" : course[@"numMissed"],
                               @"maxClasses" : course[@"maxClasses"],
                               @"req" : course[@"req"],
                               @"missedDates" : course[@"missedDates"],
                               @"heldDates" : course[@"heldDates"],
                               @"type" : course[@"type"]};
    [courses replaceObjectAtIndex:indexPath.row withObject:newValue];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [courses writeToFile:filePath atomically:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [courses count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"course" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *course = [courses objectAtIndex:indexPath.row];
    
    [[cell code] setText:[course objectForKey:@"code"]];
    [[cell name] setText:[course objectForKey:@"title"]];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [courses removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } /*else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSDictionary *temp = [[NSDictionary alloc] init];
        //add code to accept user input for name and course code to add to temp
        [courses addObject:temp];
    }*/
    [courses writeToFile:filePath atomically:YES];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSDictionary *courseToMove = courses[fromIndexPath.row];
    [courses removeObjectAtIndex:fromIndexPath.row];
    [courses insertObject:courseToMove atIndex:toIndexPath.row];
    [courses writeToFile:filePath atomically:YES];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [courses writeToFile:filePath atomically:YES];
    
    if ([segue.identifier isEqualToString:@"showCourse"] )
    {
        DetailViewController *dvc = [segue destinationViewController];
        if ([dvc respondsToSelector:@selector(setDelegate:)]) {
            [dvc setValue:self forKey:@"delegate"];
        }
        if ([dvc respondsToSelector:@selector(setSelection:)]) {
            // prepare selection info
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSMutableDictionary *selection = [[courses objectAtIndex:[indexPath row]] mutableCopy];
            [selection setValue:indexPath forKey:@"indexPath"];
            [dvc setValue:selection forKey:@"selection"];
        }
    } else if ([segue.identifier isEqualToString:@"editCourse"]) {
        EditCourseViewController *ecvc = [segue destinationViewController];
        if ([ecvc respondsToSelector:@selector(setDelegate:)]) {
            [ecvc setValue:self forKey:@"delegate"];
        }
        if ([ecvc respondsToSelector:@selector(setSelection:)]) {
            // prepare selection info
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSMutableDictionary *selection = [[courses objectAtIndex:[indexPath row]] mutableCopy];
            [selection setValue:indexPath forKey:@"indexPath"];
            [ecvc setValue:selection forKey:@"selection"];
        }
    } else if ([segue.identifier isEqualToString:@"addCourse"]) {
        AddCourseViewController *acvc = [segue destinationViewController];
        if ([acvc respondsToSelector:@selector(setDelegate:)]) {
            [acvc setValue:self forKey:@"delegate"];
        }
    }
}


@end
