//
//  UpdateViewController.m
//  CRC
//
//  Created by Jinhui Lee on 11/29/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "UpdateViewController.h"

@interface UpdateViewController ()
{
    NSTimer*    _UpdateTimer;
}
@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    _UpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)dealloc
{
    if(_UpdateTimer)
        [_UpdateTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    [_UpdateTimer invalidate];
    _UpdateTimer = nil;
    
    [self performSegueWithIdentifier:@"UpdateToMain" sender:nil];
}

@end
