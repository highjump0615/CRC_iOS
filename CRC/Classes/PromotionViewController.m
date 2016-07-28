//
//  PromotionViewController.m
//  CRC
//
//  Created by Jinhui Lee on 11/30/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "PromotionViewController.h"

@interface PromotionViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation PromotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView = [[UIWebView alloc] initWithFrame:self.container.bounds];
    [self.container addSubview:self.webView];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:EQUIPMENT_PROMOTION_URL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];
}

@end
