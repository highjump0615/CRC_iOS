//
//  ContainerViewController.m
//  CRC
//
//  Created by Jinhui Lee on 12/1/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "ContainerViewController.h"
#import "TabBar.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width  = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGRect  frame  = CGRectMake(0, 80, width, height - 80 - [TabBar height] );
    
    self.container = [[UIView alloc] initWithFrame:frame];

    self.view.backgroundColor = kForeColor;
    self.container.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.container];
    
    // setup mask
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGPathRef   path = nil;
    
    CGRect  bounds  = CGRectMake(0, 0, width, height - [TabBar height]);
    
    path = CGPathCreateWithRect(bounds, NULL);
    maskLayer.path = path;
    CGPathRelease(path);
    
    self.view.layer.mask = maskLayer;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)enableControls:(BOOL)enable
{
    for(UITabBarItem *item in self.tabBarController.tabBar.items)
        item.enabled = enable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
