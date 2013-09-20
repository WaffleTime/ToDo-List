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
        NSLog(@"The sql quey is, %@",[NSString stringWithFormat:@"SELECT * FROM TASKS WHERE ID=%d",(int)indexPath.row+1]);
        
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * FROM TASKS WHERE ID=%d",(int)indexPath.row+1] UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare(taskDB, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (!compiledStatement)
            {
                NSLog(@"The compiled statement for the sql query is invalid");
            }
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                NSLog(@"Looking at a row");

                //Task text label
                UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/4,0,cell.frame.size.width-cell.frame.size.width/4,cell.frame.size.height)];
                textView.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                textView.textColor = [UIColor blackColor];
                textView.numberOfLines = 2;
                textView.minimumScaleFactor = 8;
                textView.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:textView];
                
                //date text label
                textView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width/4,cell.frame.size.height)];
                textView.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                textView.textColor = [UIColor blackColor];
                textView.numberOfLines = 2;
                textView.minimumScaleFactor = 5;
                textView.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:textView];
                
                textView = nil;
                
            }
        }
        else
        {
            NSLog(@"Something went wrong in populating the row, %d", indexPath.row + 1);
            [cell.textLabel setText:@"DB couldn't find the task"];
            [cell.detailTextLabel setText:@"DB couldn't find the date"];
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
        
        sqlStatement = nil;
        compiledStatement = nil;
    }
    sqlite3_close(taskDB);
    
    return cell;
}

- (IBAction)deleteMode:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    NSLog(@"delete mode!");
}

//Make sure that this method updates the ID's of the subsequent rows in the database after removing one. Do this because the db rows are dependent on the index of the table's rows. And deleting a row will move cells up a row.
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteData:[NSString stringWithFormat:@"DELETE * FROM TASKS WHERE ID=%d", indexPath.row+1]];
        
        [notifs cancelNotification:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)deleteData:(NSString *)deleteQuery
{
    char *error;
    
    if (sqlite3_exec(taskDB, [deleteQuery UTF8String], NULL, NULL, &error)==SQLITE_OK) {
        NSLog(@"Task deleted");
    }
    else
    {
        NSLog(@"Task wasn't deleted!");
    }
}

- (IBAction)reloadTable
{
    [self.tableView reloadData];
}

@end