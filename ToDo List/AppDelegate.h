//
//  testerAppDelegate.h
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "ToDoViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    @public
    ToDoViewController *myViewController;
}

@property (strong, nonatomic) UIWindow *window;

- (void)createOrOpenDBAndDelete:(NSString *) taskText :(NSDate *) taskDate;

- (void)updateDatabase;

@end
