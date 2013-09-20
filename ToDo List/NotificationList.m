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

- (void) dealloc
{
    for (int i = 0; i < [notifications count]; i++)
    {
        [notifications removeObjectAtIndex:i];
    }
    
    notifications = nil;
}

- (void) addNotification:(NSCoder *)notif
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
    [[UIApplication sharedApplication] cancelLocalNotification:(UILocalNotification *)[notifications objectAtIndex:index]];
}

//Only should be called once at startup.
- (void) loadNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i < [notifications count]; i++)
    {
        [notifications addObject:[defaults objectForKey:[NSString stringWithFormat:@"notification:%d",i]]];
    }
}

//Only should be called once at shutdown.
- (void) saveNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (int i = 0; i < [notifications count]; i++)
    {
        [defaults setObject:[notifications objectAtIndex:i] forKey:[NSString stringWithFormat:@"notification:%d",i]];
    }
         
    [defaults synchronize];
}

- (int) len
{
    return [notifications count];
}

@end
