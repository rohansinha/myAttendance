//
//  CourseTableViewCell.h
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
