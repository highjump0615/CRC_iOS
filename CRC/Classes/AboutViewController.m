//
//  AboutViewController.m
//  CRC
//
//  Created by Jinhui Lee on 12/1/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "AboutViewController.h"
#import "InfoView.h"
#import <MapKit/MapKit.h>

@interface AboutViewController () <MKMapViewDelegate>

@property (strong, nonatomic)   UIScrollView* scrollView;
@property (strong, nonatomic)   MKMapView* mapView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupControls];

    [self findLocationWithAddress:@"23 New Bridge Road, Singapore 059389"];
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

#pragma mark - setup controls..

- (void)setupControls
{
    CGRect  frame  = self.container.frame;
    CGFloat width  = CGRectGetWidth(frame);
    CGFloat height = 0;
    CGRect  bounds;
    InfoView* infoView;

    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    
    bounds = CGRectMake(0, 0, width, 200);
    self.mapView = [[MKMapView alloc] initWithFrame:bounds];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = NO;
    [self.scrollView addSubview:self.mapView];
    height += 200;

    bounds = self.mapView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleLocation
                                 withTitle:@"23 New Bridge Road, Singapore 059389\nLevel 3 - Photography Camera & Lens\nLevel 4 - Studio & Video Equipment"
                                 withDescription:nil];
    [infoView setUserData:self.mapView];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleURL withTitle:@"www.camerarental.biz" withDescription:nil];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleMail withTitle:@"info@camerarental.biz" withDescription:nil];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStylePhone withTitle:@"+65 96504158" withDescription:nil];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleTime
                                 withTitle:@"Mon-Thu (11am-7pm), Fri (11am-7:30pm)\nSat-Sun (11am-5pm), Public Holidays (11am-3pm)\nClose on New Year's Day, Lunar New Year and Christmas."
                                 withDescription:nil];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleInfo withTitle:@"How does your rental pricing work?"
                               withDescription:@"There is a bundled discount when you rent more than one item or for more than one day. The more you rent, the cheaper it gets! 😊"];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleInfo withTitle:@"I didn't receive any reply!"
                               withDescription:@"If you do not receive an email reply to your booking enquiry within 24 hours, please call/SMS us at 96504158 or email to \"info@camerarental.biz\" so that we can check on the status of your request."];
    [infoView setUserData:INFO_HTML_BODY];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleInfo withTitle:@"What is the collection & return time?"
                               withDescription:@"We allow customers to collect the equipment a day before their shoot and return a day after their shoot.\n\nCollection\nWeekdays between 4-7pm\nWeekends between 2:30-4:30pm\nPublic Holidays between 12noon-2:30pm\n\nReturn\nEveryday between 11:30am-1:30pm."];
    
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    bounds = infoView.frame;
    bounds = CGRectMake(0, CGRectGetMaxY(bounds), width, 0);
    infoView = [[InfoView alloc] initWithFrame:bounds withStyle:InfoViewStyleInfo withTitle:@"Do you provide delivery service?"
                               withDescription:@"Yes, we provide delivery service at additional charge (depending on size and weight of equipment). This will be subject to availability of the delivery schedule. Please indicate your preference for a one-way or two-way delivery service under comments when you submit your booking request. New customers will need to register with us before delivery can be arranged."];
    [self.scrollView addSubview:infoView];
    height += CGRectGetHeight(infoView.frame);
    
    self.scrollView.contentSize = CGSizeMake(width, height);
    [self.view addSubview:self.scrollView];
}

#pragma mark - find location for address

- (void)findLocationWithAddress:(NSString*)address
{
    NSString *location = address;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = self.mapView.region;
                         region.center = [(CLCircularRegion *)placemark.region center];
                         region.span.longitudeDelta /= 20.0;
                         region.span.latitudeDelta /= 20.0;
                         
                         [self.mapView setRegion:region animated:YES];
                         [self.mapView addAnnotation:placemark];
                     }
                 }];
}
@end
