//
//  AddItemViewController.h
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AddItemViewController : UIViewController
{
    IBOutlet UITextField *taskText;
    IBOutlet UIDatePicker *datePicker;
    
    sqlite3 *taskDB;
    NSString *dbPathString;
}

- (void)createOrOpenDB;

- (void)updateDatabase;

- (IBAction)addItem:(id)sender;

- (IBAction)taskEntered:(UITextField *)textField;

- (void) scheduleNotification:(NSDate *) itemDate :(NSString *) task;

@end