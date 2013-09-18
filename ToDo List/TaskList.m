//
//  TaskList.m
//  ToDo List
//
//  Created by Super Student on 9/18/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import "TaskList.h"

@interface TaskList ()
{
    NSMutableArray *tasks;
}
@end

@implementation TaskList

static TaskList *sharedInstance;

+ (TaskList *) getSharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[TaskList alloc] init];
    }
    
    return sharedInstance;
}

- (void) loadTasks
{
    
}

- (void) saveTasks
{
    
}

- (void) addTask:(Task *) task
{
    
}

- (void) removeTask:(int) index
{
    
}

@end
