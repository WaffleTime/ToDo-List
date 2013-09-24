//
//  AddItemViewController.m
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import "AddItemViewController.h"


@interface AddItemViewController ()

@end

@implementation AddItemViewController

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
    
    [self createOrOpenDB];
    
    NSLog(@"view did load");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    taskDB = nil;
    dbPathString = nil;
}

- (void)createOrOpenDB
{
    NSString *docPath = PROJECT_DIR;
    
    dbPathString = [docPath stringByAppendingPathComponent:@"ToDoList.db"];
    
    char *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString]) {
        const char *dbPath = [dbPathString UTF8String];
        
        //creat db here
        if (sqlite3_open(dbPath, &taskDB)==SQLITE_OK) {
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TASKS (ID INTEGER PRIMARY KEY, DATE TEXT, TASK TEXT)";
            sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
            sqlite3_close(taskDB);
        }
    }
}


//This method will be called when the add button is pressed. It is supposed to save the data that was entered for the new task.
//  And it will save the data into a SQL database.
- (IBAction)addItem:(id)sender
{
    if (![taskText.text isEqualToString:@""])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        char *error;
        
        if (sqlite3_open([dbPathString UTF8String], &taskDB)==SQLITE_OK)
        {
            //This will help us check to see if a db entry already exists.
            const char *findStmt = [[NSString stringWithFormat:@"SELECT COUNT(*) FROM TASKS WHERE DATE='%@' AND TASK='%@'", [dateFormatter stringFromDate:datePicker.date], taskText.text] UTF8String];
            sqlite3_stmt *compiledStatement;
            
            if (sqlite3_prepare_v2(taskDB, findStmt, -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                //Step through to count rows.
                if (sqlite3_step(compiledStatement) != SQLITE_ERROR)
                {
                    //Check to see if there aren't any duplicates.
                    if (sqlite3_column_int(compiledStatement, 0) == 0)
                    {
                        NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
                        
                        NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO TASKS(ID,DATE,TASK) values ('%@', '%s', '%s')", [NSString stringWithFormat:@"%d", [notifs count]+1],[[dateFormatter stringFromDate:datePicker.date]UTF8String], [taskText.text UTF8String]];
                        
                        const char *insert_stmt = [inserStmt UTF8String];
                        
                        if (sqlite3_exec(taskDB, insert_stmt, NULL, NULL, &error)==SQLITE_OK)
                        {
                            NSLog(@"Task has been added");
                            
                            [self scheduleNotification:datePicker.date :taskText.text];
                        }
                        else
                        {
                            NSLog(@"Error with the insert query");
                        }
                    }
                    else
                    {
                        NSLog(@"This will be a duplicate entry.");
                    }
                }
                else
                {
                    NSLog(@"An error occured when stepping through the db.");
                }
            }
            else
            {
                NSLog(@"Was not able to prepare the find statement for sqlite3.");
            }
            
            sqlite3_finalize(compiledStatement);
            sqlite3_close(taskDB);
                
            findStmt = nil;
            compiledStatement = nil;
        }
        else
        {
            NSLog(@"The database couldn't be opened!");
        }
        
        dateFormatter = nil;
    }
}

//This is called when the Task textfield is done entering text into it. The keyboard's return button and tapping outside of the
//  screen will trigger this.
- (IBAction)taskEntered:(UITextField *)textField
{
    [textField resignFirstResponder];
}

//A delegate method that is called by the UITextField when the user is entering text.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSLog(@"delegate method for UITextField works!");
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 55) ? NO : YES;
}


//This method will schedule a notification for the given date. And it will talk with the AlarmDumpster so that previous notifications that were set are able to be
//  canceled.
//@param itemDaten This is the trigger date for the notification that is to be set.
//@param alarmId This Id represents the alarm that the notification is being made for. It allows us to retrieve that alarm's previous notification from the
//  AlarmDumpster.
- (void) scheduleNotification:(NSDate *) itemDate :(NSString *) task
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    if (localNotif == nil)
        return;
    
    localNotif.fireDate = itemDate;
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody = task;
    
    // Set the action button
    //localNotif.alertAction = @"ToDo";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName; //@"LightSaber.caf";
    
    localNotif.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    localNotif = nil;
}

@end
