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

    notifs = [NotificationList getSharedInstance];
    
    [self createOrOpenDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    notifs = nil;
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
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TASKS (ID INTEGER PRIMARY KEY AUTOINCREMENT, DATE TEXT, TASK TEXT)";
            sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
            sqlite3_close(taskDB);
        }
    }
}


//This method will be called when the add button is pressed. It is supposed to save the data that was entered for the new task.
//  And it will save the data into a SQL database.
- (IBAction)addItem:(id)sender
{
    
    NSLog(@"db not opened yet");
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    char *error;
    
    
    
    if (sqlite3_open([dbPathString UTF8String], &taskDB)==SQLITE_OK) {
        NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO TASKS(DATE,TASK) values ('%s', '%s')",[[dateFormatter stringFromDate:datePicker.date]UTF8String], [taskText.text UTF8String]];
        
        NSLog(@"db opened");
        
        const char *insert_stmt = [inserStmt UTF8String];
        
        if (sqlite3_exec(taskDB, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Task has been added");
            
            [self scheduleNotification:datePicker.date :taskText.text];
        }
        sqlite3_close(taskDB);
    }
    
    dateFormatter = nil;
}

//This is called when the Task textfield is done entering text into it. The keyboard's return button and tapping outside of the
//  screen will trigger this.
- (IBAction)taskEntered:(UITextField *)textField {
    [textField resignFirstResponder];
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
    localNotif.alertAction = @"View";
    
    localNotif.soundName = @"LightSaber.caf";
    
    localNotif.applicationIconBadgeNumber = 1;
    
    if (localNotif)
    {
        [notifs addNotification:(NSCoder *)localNotif];
    }
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    localNotif = nil;
}

@end
