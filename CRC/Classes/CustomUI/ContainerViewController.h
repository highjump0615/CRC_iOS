//
//  ContainerViewController.h
//  CRC
//
//  Created by Jinhui Lee on 12/1/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController

@property (nonatomic, strong) UIView* container;

- (void)enableControls:(BOOL)enable;

@end
