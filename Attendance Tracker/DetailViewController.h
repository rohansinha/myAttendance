//
//  DetailViewController.h
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView* datesTable;
}

@property (copy, nonatomic) NSDictionary *selection;
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIStepper *lectures;
@property (weak, nonatomic) IBOutlet UIStepper *missedLectures;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *percentage;
@property (weak, nonatomic) IBOutlet UILabel *requirement;
@property (weak, nonatomic) IBOutlet UILabel *estimate;

- (IBAction)held:(id)sender;
- (IBAction)missed:(id)sender;
- (IBAction)dateChanged:(UIDatePicker *)sender;
- (void)setNewDates:(NSMutableArray *)newDates remove:(NSArray *)removed;

@end
