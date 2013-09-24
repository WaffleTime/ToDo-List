//
//  testerAppDelegate.m
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    application.applicationIconBadgeNumber = [notifs count];
    
    NSLog(@"Did launch with options the app has.");
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    application.applicationIconBadgeNumber = [notifs count];
    
    NSLog(@"Did become active the app has.");
    
    [self updateDatabase];
    
    [myViewController reloadTable];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self createOrOpenDBAndDelete:notification.alertBody :notification.fireDate];
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
     
}

- (void)createOrOpenDBAndDelete:(NSString *) taskText :(NSDate *) taskDate
{
    NSLog(@"An entry is about to be deleted.");
    NSString *docPath = PROJECT_DIR;
    
    docPath = [docPath stringByAppendingPathComponent:@"ToDoList.db"];
    
    const char *dbPath = [docPath UTF8String];
    
    char *error;
    
    sqlite3 *taskDB;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docPath]) {
        
        //creat db here
        if (sqlite3_open(dbPath, &taskDB)==SQLITE_OK)
        {
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TASKS (ID INTEGER PRIMARY KEY AUTOINCREMENT, DATE TEXT, TASK TEXT)";
            sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
            
            sqlite3_close(taskDB);
        }
    }

    //creat db here
    if (sqlite3_open(dbPath, &taskDB)==SQLITE_OK)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        const char *sql_stmt= [[NSString stringWithFormat:@"SELECT * FROM TASKS WHERE TASK='%@' AND DATE='%@'",taskText, [dateFormatter stringFromDate:taskDate]] UTF8String];
        sqlite3_stmt *compiledStatement;
        
        int deletedItemID = -1;
        
        if(sqlite3_prepare(taskDB, sql_stmt, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                deletedItemID = (int)[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            }
        }

        if (deletedItemID != -1)
        {
            sql_stmt = [[NSString stringWithFormat:@"DELETE FROM TASKS WHERE TASK='%@' AND DATE='%@'", taskText, [dateFormatter stringFromDate:taskDate]] UTF8String];
            sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
            
            sql_stmt = [[NSString stringWithFormat:@"UPDATE TASKS SET ID=ID-1 WHERE ID>%d",deletedItemID] UTF8String];
            sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
        }
        
        NSLog(@"An entry of the db has been deleted!");

        sqlite3_close(taskDB);
    }
}

//This will check through the database to see if it has entries that should have been cleared when a notification went off.
- (void)updateDatabase
{
    NSString *dbPathString = PROJECT_DIR;
    
    dbPathString = [dbPathString stringByAppendingPathComponent:@"ToDoList.db"];
    
    const char *dbPath = [dbPathString UTF8String];
    
    char *error;
    
    sqlite3 *taskDB;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString]) {
        
        //creat db here
        if (sqlite3_open(dbPath, &taskDB)==SQLITE_OK)
        {
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TASKS (ID INTEGER PRIMARY KEY AUTOINCREMENT, DATE TEXT, TASK TEXT)";
            sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
            
            sqlite3_close(taskDB);
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    if (sqlite3_open([dbPathString UTF8String], &taskDB)==SQLITE_OK)
    {
        const char *findStmt = "SELECT COUNT(*) FROM TASKS";
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(taskDB, findStmt, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            //Step through to count rows.
            if (sqlite3_step(compiledStatement) != SQLITE_ERROR)
            {
                NSLog(@"db entries:%d", sqlite3_column_int(compiledStatement, 0));
                NSLog(@"notifications:%d", [notifs count]);
                
                //Check to see if there are more db entries than notifications
                if (sqlite3_column_int(compiledStatement, 0) > [notifs count])
                {
                    NSString *taskList = @"";
                    NSString *dateList = @"";
                    
                    //Loop through the notifications to build a String that holds all tasks and dates for the sql query.
                    for (int i = 0; i < [notifs count]; i++)
                    {
                        taskList = [taskList stringByAppendingString:@"'"];
                        taskList = [taskList stringByAppendingString:((UILocalNotification *)[notifs objectAtIndex:i]).alertBody];
                        taskList = [taskList stringByAppendingString:@"'"];
                        
                        dateList = [dateList stringByAppendingString:@"'"];
                        dateList = [dateList stringByAppendingString:[dateFormatter stringFromDate:((UILocalNotification *)[notifs objectAtIndex:i]).fireDate]];
                        dateList = [dateList stringByAppendingString:@"'"];
                        
                        if (i != [notifs count]-1)
                        {
                            taskList = [taskList stringByAppendingString:@","];
                            dateList = [dateList stringByAppendingString:@","];
                        }
                    }
                    
                    if ([notifs count] == 0)
                    {
                        taskList = @"''";
                        dateList = @"''";
                    }
                    
                    //Now we must look through the db for the odd ball that shouldn't be there.
                    const char *sql_stmt = [[NSString stringWithFormat:@"DELETE FROM TASKS WHERE TASK NOT IN (%@) OR DATE NOT IN (%@)", taskList, dateList] UTF8String];
                    
                    sqlite3_exec(taskDB, sql_stmt, NULL, NULL, &error);
                    
                    NSLog(@"Extra db entries should have been deleted with query: '%s.'", sql_stmt);
                }
                else
                {
                    NSLog(@"The db is up to date according to the notification list");
                }
            }
            else
            {
                NSLog(@"There was an error stepping through the db entries");
            }
        }
        else
        {
            NSLog(@"The select all query was not prepared");
        }
        sqlite3_finalize(compiledStatement);
        sqlite3_close(taskDB);
    }
    else
    {
        NSLog(@"db was not loaded");
    }
}

@end
