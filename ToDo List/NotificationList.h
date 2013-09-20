//
//  NotificationList.h
//  ToDo List
//
//  Created by Super Student on 9/19/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationList : NSObject
{
    NSMutableArray *notifications;
}

+ (NotificationList *) getSharedInstance;

- (void) addNotification:(NSCoder  *)notif;
- (void) cancelNotification:(int) index;

- (void) loadNotifications;
- (void) saveNotifications;

- (int) len;

@end
