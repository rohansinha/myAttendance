//
//  EditCourseViewController.m
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import "EditCourseViewController.h"
#import "CoursesViewController.h"

@interface EditCourseViewController ()

@end

@implementation EditCourseViewController
{
    NSMutableArray *typesOfCourses;
    NSString *selectedType;
}

@synthesize selection, delegate, courseCode, courseName, numClasses, requirement;

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
    
    typesOfCourses = [[NSMutableArray alloc] initWithObjects:@"Lab", @"Theory", nil];
    selectedType = [typesOfCourses lastObject];
    
    [courseCode addTarget:self action:@selector(codeDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [courseName addTarget:self action:@selector(nameDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [numClasses addTarget:self action:@selector(maxDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [requirement addTarget:self action:@selector(reqDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [courseName setText:selection[@"title"]];
    [courseCode setText:selection[@"code"]];
    [numClasses setText:[selection[@"maxClasses"] stringValue]];
    [requirement setText:[selection[@"req"] stringValue]];
    selectedType = selection[@"type"];
    
    [[self navigationItem] setTitle:@"Edit Course"];
}

#pragma mark - PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [typesOfCourses count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return typesOfCourses[row];
}

#pragma mark - PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedType = typesOfCourses[row];
}

- (void) applyChanges
{
    if ([self validate])
    {
        if ([self.delegate respondsToSelector:@selector(editedSelection:)]) {
            // finish editing
            // prepare selection info
            NSDictionary *change = @{@"indexPath" : selection[@"indexPath"],
                                     @"numHeld" : [selection objectForKey:@"numHeld"],
                                     @"numMissed" : [selection objectForKey:@"numMissed"],
                                     @"title" : [courseName text],
                                     @"code" : [courseCode text],
                                     @"maxClasses" : [NSNumber numberWithInteger:[[numClasses text] integerValue]],
                                     @"req" : [NSNumber numberWithInteger:[[requirement text] integerValue]],
                                     @"missedDates" : selection[@"missedDates"],
                                     @"heldDates" : selection[@"heldDates"],
                                     @"type" : selectedType};
            [self.delegate editedSelection:change];
        }
        [[self navigationController] popViewControllerAnimated:YES];
    } else {
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:@"Please provide valid/realistic input."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [fail show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nameDone:(id)sender {
    [sender resignFirstResponder];
    [courseCode becomeFirstResponder];
}

- (void)codeDone:(id)sender {
    [sender resignFirstResponder];
    [numClasses becomeFirstResponder];
}

- (void)maxDone:(id)sender {
    [sender resignFirstResponder];
    [requirement becomeFirstResponder];
}

- (void)reqDone:(id)sender {
    [sender resignFirstResponder];
}

-(IBAction)done:(id)sender
{
    [self applyChanges];
}

- (BOOL)validate
{
    if([courseCode text] == nil || [[courseCode text] length] < 1 || [courseName text] == nil || [[courseName text] length] < 1 || [numClasses text] == nil || [[numClasses text] length] < 1 || [requirement text] == nil || [[requirement text] length] < 1 || [[requirement text] intValue] > 100 || [[numClasses text] intValue] > 100)
        return NO;
    return YES;
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

@end
