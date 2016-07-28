//
//  SplashViewController.m
//  CRC
//
//  Created by Jinhui Lee on 11/29/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "SplashViewController.h"
#import <Foundation/Foundation.h>

#import "SBJSON.h"
#import "EquipmentData.h"


@interface SplashViewController () <NSURLConnectionDataDelegate>
{
    NSMutableData*      _receivedData;
    NSURLConnection*    _connection;
}

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    _receivedData = nil;
    
    [self downloadAppVersion];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* dest = (UIViewController*)segue.destinationViewController;
    
    if([dest isKindOfClass:[UITabBarController class]])
    {
        if(g_receievedMessage)
        {
            g_receievedMessage = NO;
            ((UITabBarController*)dest).selectedIndex = 2;
        }
        else
        {
            ((UITabBarController*)dest).selectedIndex = 0;
        }
    }
}


#pragma mark - Check AppVersin & download data from internet..

- (void)chekcForUpdateApp
{
    NSString*   curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString*   newVersion = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    
    if([curVersion isEqualToString:newVersion])
    {
        [self performSegueWithIdentifier:@"SplashToMain" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"SplashToUpdate" sender:nil];
    }
}

- (void)downloadAppVersion
{
    NSURL           *URL            = [NSURL URLWithString:[EQUIPMENT_VERSION_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest    *request        = [NSURLRequest requestWithURL:URL];
    
    _receivedData = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found.\nIf Wi-Fi is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    NSLog(@"No Internet! : %@", error.description);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self chekcForUpdateApp];
}

@end
