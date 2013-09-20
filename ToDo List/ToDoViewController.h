//
//  testerViewController.h
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "NotificationList.h"

@interface ToDoViewController : UITableViewController
{
    NotificationList *notifs;
    sqlite3 *taskDB;
    NSString *dbPathString;
}

- (void) createOrOpenDB;

- (IBAction)deleteMode:(id)sender;

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)deleteData:(NSString *)deleteQuery;

- (IBAction)reloadTable;


@end
