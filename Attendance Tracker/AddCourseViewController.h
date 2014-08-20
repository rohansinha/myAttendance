//
//  AddCourseViewController.h
//  Attendance Tracker
//
//  Created by Rohan Sinha on 14/07/14.
//  Copyright (c) 2014 rohansinha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCourseViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    IBOutlet UIPickerView *courseType;
}

@property (copy, nonatomic) NSDictionary *selection;
@property (weak, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet UITextField *courseName;
@property (weak, nonatomic) IBOutlet UITextField *courseCode;
@property (weak, nonatomic) IBOutlet UITextField *numClasses;
@property (weak, nonatomic) IBOutlet UITextField *requirement;
//@property (weak, nonatomic) IBOutlet UIPickerView *courseType;

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

@end
