//
//  AppDelegate.m
//  CRC
//
//  Created by Jinhui Lee on 11/29/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "AppDelegate.h"
#include <netdb.h>

BOOL g_receievedMessage = NO;


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self regisgterNotification];
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(notification)
    {
        g_receievedMessage = YES;
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Apple Notification

- (void)regisgterNotification
{
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

}

#pragma mark - UINotification Delegate Methods

- (void)sendProviderDeviceToken:(NSData *)devToken
{
    NSString *devTokenStr = [[[[devToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                                  stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"Send Device Token");
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.domai.queue", 0);
    
    dispatch_async(backgroundQueue, ^{

        NSMutableString *ms = nil;
        
        ms = [[NSMutableString alloc]
              initWithString:@"http://app.camerarental.biz/api/crc/registerDevice.php?deviceToken="];
        [ms appendString:devTokenStr]; 
        
        // URL request
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:ms]];
        
        //URL connection to the internet
        NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        [connection start];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {

    [self sendProviderDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIViewController* curController = ((UINavigationController*)self.window.rootViewController).visibleViewController;

    if([curController isKindOfClass:[UITabBarController class]])
    {
        ((UITabBarController*)curController).selectedIndex = 2;
    }
    else if(curController.tabBarController)
    {
        curController.tabBarController.selectedIndex = 2;
    }
    else
    {
        g_receievedMessage = YES;
    }
}
@end
