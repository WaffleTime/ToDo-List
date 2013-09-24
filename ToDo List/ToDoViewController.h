//
//  testerViewController.h
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ToDoViewController : UITableViewController
{
    sqlite3 *taskDB;
    NSString *dbPathString;
}

- (void) createOrOpenDB;

- (void)updateDatabase;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (IBAction)deleteMode:(id)sender;

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)deleteData:(NSString *)deleteQuery;

-(void)reloadTable;

@end
