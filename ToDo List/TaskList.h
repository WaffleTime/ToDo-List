//
//  TaskList.h
//  ToDo List
//
//  Created by Super Student on 9/18/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface TaskList : NSObject
{
}

- (void) loadTasks;
- (void) saveTasks;
- (void) addTask:(Task *) task;
- (void) removeTask:(int) index;

@end
