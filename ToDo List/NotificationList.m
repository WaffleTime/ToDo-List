//
//  NotificationList.m
//  ToDo List
//
//  Created by Super Student on 9/19/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import "NotificationList.h"

@interface NotificationList ()

@end

@implementation NotificationList

static NotificationList *sharedInstance;

+ (NotificationList *) getSharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[NotificationList alloc] init];
    }
    return sharedInstance;
}

- (void) addNotification:(UILocalNotification *)notif
{
    if (!notifications)
    {
        notifications = [[NSMutableArray alloc] init];
    }
    
    [notifications addObject:notif];
    
    NSLog(@"%d notifications", [notifications count]);
}

- (void) cancelNotification:(int) index
{
    [[UIApplication sharedApplication] cancelLocalNotification:[notifications objectAtIndex:index]];
    
    [notifications removeObjectAtIndex:index];
}

//Only should be called once at startup.
- (void) loadNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
    
    if (!notifications)
    {
        notifications = [[NSMutableArray alloc] init];
    }
    
    NSLog(@"%d notifications loaded", [defaults integerForKey:@"notification count"]);
    
    for (int i = 0; i < [defaults integerForKey:@"notification count"]; i++)
    {
        if ([defaults objectForKey:[NSString stringWithFormat:@"notification:%d",i]])
        {
            [notifications addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:[NSString stringWithFormat:@"notification:%d",i]]]];
        }
    }
    
    defaults = nil;
}

//Only should be called once at shutdown.
- (void) saveNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:[notifications count] forKey:@"notification count"];
    
    NSLog(@"%d notifications saved.", [notifications count]);

    for (int i = 0; i < [notifications count]; i++)
    {
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[notifications objectAtIndex:i]] forKey:[NSString stringWithFormat:@"notification:%d",i]];
    }
    
    NSLog(@"inserting stuff is done");
         
    [defaults synchronize];
    
    
    for (int i = 0; i < [notifications count]; i++)
    {
        [notifications removeObjectAtIndex:i];
    }
    
    notifications = nil;
    defaults = nil;
}

- (int) len
{
    return [notifications count];
}

@end
