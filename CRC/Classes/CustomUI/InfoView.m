//
//  InfoView.m
//  CRC
//
//  Created by Jinhui Lee on 12/1/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "InfoView.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

#define X_MARGIN    10
#define Y_MARGIN    10
#define LINE_BREAK  10

@interface InfoView () <MFMailComposeViewControllerDelegate>
{
    InfoViewStyle   _style;
    id              _userData;
}
@property (nonatomic, strong) UIImageView*  icon;
@property (nonatomic, strong) UILabel*      title;
@property (nonatomic, strong) UILabel*      info;
@property (nonatomic, strong) UIView*       line;

@end

@implementation InfoView

- (instancetype)initWithFrame:(CGRect)frame withStyle:(InfoViewStyle)style
                    withTitle:(NSString*)title withDescription:(NSString*)description
{
    self = [super initWithFrame:CGRectZero];
    
    if(self)
    {
        if(style != InfoViewStyleInfo)
            [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];

        UIFont* font = [UIFont fontWithName:@"Helvetica" size:14.0];
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = 0;
        CGRect  bounds;
        
        _style = style;
        
        // icon
        self.icon = [[UIImageView alloc] initWithImage:[self imageWithStyle]];
        bounds = self.icon.bounds;
        [self addSubview:self.icon];
        
        // config
        bounds = self.icon.bounds;
        CGFloat textWidth = width - X_MARGIN*3 - CGRectGetWidth(bounds);
        CGSize  szTitle = [self getSizeOfText:title withFont:font widthOftext:textWidth];
        CGSize  szDesc  = [self getSizeOfText:description withFont:font widthOftext:textWidth];

        height = MAX(CGRectGetHeight(bounds), (szTitle.height + szDesc.height)) + Y_MARGIN*2;
        
        if(description.length > 0)
            height += Y_MARGIN;
        
        self.icon.frame = CGRectMake(X_MARGIN, (height - CGRectGetHeight(bounds))/2,
                                     CGRectGetWidth(bounds), CGRectGetHeight(bounds));

        // title
        bounds = self.icon.bounds;
        self.title = [[UILabel alloc] init];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment = NSTextAlignmentLeft;
        self.title.textColor = [UIColor blackColor];
        self.title.numberOfLines = 0;
        self.title.text = title;
        self.title.font = font;
        self.title.frame = CGRectMake(X_MARGIN*2 + CGRectGetWidth(bounds), Y_MARGIN,
                                      szTitle.width, szTitle.height);
        [self addSubview:self.title];
        
        if(_style == InfoViewStyleInfo)
        {
            self.icon.frame = CGRectMake(X_MARGIN, Y_MARGIN,
                                         CGRectGetWidth(bounds), CGRectGetHeight(bounds));

            bounds = self.title.frame;
            self.info = [[UILabel alloc] init];
            self.info.backgroundColor = [UIColor clearColor];
            self.info.textAlignment = NSTextAlignmentLeft;
            self.info.textColor = [UIColor grayColor];
            self.info.numberOfLines = 0;
            self.info.text = description;
            self.info.font = font;
            self.info.frame = CGRectMake(CGRectGetMinX(bounds), Y_MARGIN + CGRectGetMaxY(bounds),
                                          szDesc.width, szDesc.height);
            self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
            
            [self addSubview:self.info];
            
        }
        else{
            self.title.frame = CGRectMake(X_MARGIN*2 + CGRectGetWidth(bounds), (height - szTitle.height)/2,
                                          szTitle.width, szTitle.height);

            self.line = [[UIView alloc] initWithFrame:CGRectMake(0, height - kLineHeight, width, kLineHeight)];
            self.line.backgroundColor = kLineColor;
            [self addSubview:self.line];

            self.backgroundColor = [UIColor whiteColor];
        }
        
        self.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), (int)(height + 0.5));
        
        [self addTarget:self action:@selector(OnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc
{
    if(_style != InfoViewStyleInfo)
        [self removeObserver:self forKeyPath:@"highlighted"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay];
}

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.highlighted == YES)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        [RGBCOLOR(230, 230, 230) setFill];
        CGContextFillRect(ctx, rect);
    }
    else
    {
       // Do custom drawing for normal state
    }
}

#pragma mark - set UserData

- (void)setUserData:(id)userData
{
    _userData = userData;
    
    if(_style == InfoViewStyleInfo && _userData && [_userData isKindOfClass:[NSString class]])
    {
        self.info.text = @"";
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[(NSString*)_userData dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        self.info.attributedText = attrStr;
    }
}

#pragma mark - Button touch action

- (void)findLocationWithAddress:(NSString*)address
{
    if(_userData == nil || ![_userData isKindOfClass:[MKMapView class]])
        return;
    
    MKMapView* mapView = (MKMapView*)_userData;
    NSString *location = [address componentsSeparatedByString:@"\n"][0];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = mapView.region;
                         region.center = [(CLCircularRegion *)placemark.region center];
                         region.span.longitudeDelta /= 1.0;
                         region.span.latitudeDelta /= 1.0;
                         
                         [mapView setRegion:region animated:YES];
                     }
                 }];
}

- (void)sendMail:(NSString*)address
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Unfortunately can't send mail.\nPlease check if you registered email or not."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSString *emailTitle = @"To Camera Rental Center";
    NSString *messageBody = @"";
    NSArray *toRecipents = [NSArray arrayWithObject:address];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:mc animated:YES completion:NULL];
}
- (IBAction)OnAction:(id)sender
{
    NSString* title = self.title.text;
    switch (_style) {
        case InfoViewStyleLocation:
            [self findLocationWithAddress:title];
            break;
        case InfoViewStyleURL:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://" stringByAppendingString:title]]];
            break;
        case InfoViewStyleMail:
            [self sendMail:title];
            break;
        case InfoViewStylePhone:
            title = [@"tel://" stringByAppendingString:[[title stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@""]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:title]];
            break;
        case InfoViewStyleTime:
            break;
        case InfoViewStyleInfo:
            break;
            
        default:
            break;
    }
}

#pragma mark - Get Icon with Style
- (UIImage*)imageWithStyle
{
    NSString* strIconName = nil;
    
    switch (_style) {
        case InfoViewStyleLocation:
            strIconName = @"symbol_location";
            break;
        case InfoViewStyleURL:
            strIconName = @"symbol_url";
            break;
        case InfoViewStyleMail:
            strIconName = @"symbol_mail";
            break;
        case InfoViewStylePhone:
            strIconName = @"symbol_phone";
            break;
        case InfoViewStyleTime:
            strIconName = @"symbol_time";
            break;
        case InfoViewStyleInfo:
            strIconName = @"symbol_info";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:strIconName];
}

#pragma mark - Get Text Size
- (CGSize)getSizeOfText:(NSString *)text withFont:(UIFont *)font widthOftext:(int )txtWidth
{
    if(text.length == 0)
        return CGSizeMake(txtWidth, 0);
    
    CGSize boundingSize = CGSizeMake(txtWidth, 9999);
    CGSize size;

    CGRect textRect = [text boundingRectWithSize:boundingSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    size=textRect.size;

    return size;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
}

@end
