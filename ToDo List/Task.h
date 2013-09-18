//
//  task.h
//  ToDo List
//
//  Created by Super Student on 9/18/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *task;
@property (strong, nonatomic) NSCoder *notification;

@end
