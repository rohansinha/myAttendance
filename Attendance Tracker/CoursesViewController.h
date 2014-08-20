//
//  CoursesViewController.h
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoursesViewController : UITableViewController

@property (copy, nonatomic) NSMutableArray *courses;

- (void)addCourse:(NSDictionary *)course;
- (void)editedSelection:(NSDictionary *)course;

@end
