//
//  DatesHeldViewController.h
//  Attendance Tracker
//
//  Created by Rohan Sinha on 21/7/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatesHeldViewController : UITableViewController

@property (weak, nonatomic) id delegate;
@property (copy, nonatomic) NSArray *heldDates;

- (IBAction)dateChanged:(UIDatePicker *)sender;

@end