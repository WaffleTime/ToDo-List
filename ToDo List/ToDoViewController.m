//
//  testerViewController.m
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import "ToDoViewController.h"

@interface ToDoViewController ()


@end

@implementation ToDoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Grab the static task list.
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
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"How many rows are there %d?", [notifs len]);
    
    // Return the number of rows in the section.
    return [notifs len];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSLog(@"get a cell!");
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Gotta get the stuff from the database!
    
    // Open the database from the users filessytem
    if(sqlite3_open([dbPathString UTF8String], &taskDB) == SQLITE_OK)
    {
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * FROM TASKS WHERE ID='%d'",indexPath.row] UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(taskDB, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                NSLog(@"Looking at a row");
                
                // Read the data from the result row
                NSString *date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                NSString *task = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                
                NSLog(@"task:%@",task);
                NSLog(@"date:%@",date);
                
                //Display the task that needs done.
                [cell.textLabel setText:task];
                
                //Display the date and time the task needs done.
                [cell.detailTextLabel setText:date];
                
                date = nil;
                task = nil;
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(taskDB);
    
    return cell;
}

- (IBAction)reloadTable
{
    [self.tableView reloadData];
}

@end