//
//  CartViewController.m
//  CRC
//
//  Created by Jinhui Lee on 12/1/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "CartViewController.h"
#import "EquipmentCell.h"
#import "CartCell.h"
#import "EquipmentData.h"
#import "Kal.h"
#import "NSDate+Convenience.h"
#import "SZTextView.h"
#import "KeyboardHelper.h"
#import "MBProgressHUD.h"

#import <MailCore/MailCore.h>

#define X_MARGIN            5
#define Y_MARGIN            10

#define BUTTON_X_MARGIN     60
#define BUTTON_Y_MARGIN     15
#define BUTTON_HEIGHT       40

#define BOTTOM_BAR_HEIGHT   70


typedef NS_ENUM(NSInteger, CartViewStye) {
    CartViewStyleEdit = 0,
    CartViewStyleSelectDate,
    CartViewStyleSubmit,
    CartViewStyleDone,
};

@interface CartViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL                _bReloading;
    BOOL                _bSendingMail;
    NSUInteger          _processedMailCount;
    NSUInteger          _successedMailCount;

    UIView*             _alertView;
    UIView*             _bottomBar;
    UIView*             _currentView;
    UIButton*           _btNext;
    UIButton*           _btBack;
    UIButton*           _btBackTop;
    
    NSInteger           _viewIndex;
    
    NSMutableArray*     _viewArray;
    
    KalViewController*  _kal;
}

@property (nonatomic, strong) KeyboardHelper* kbHelper;

@property (strong, nonatomic)   UITableView*    tableView;

@property (assign, nonatomic)   NSInteger       selectedIndex;
@property (assign, nonatomic)   NSInteger       highlightedIndex;

@property (strong, nonatomic)   UITextField*    txtName;
@property (strong, nonatomic)   UITextField*    txtMail;
@property (strong, nonatomic)   UITextField*    txtContact;
@property (strong, nonatomic)   UITextField*    txtNRIC;
@property (strong, nonatomic)   SZTextView*     txtComment;
@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.kbHelper = [[KeyboardHelper alloc] initWithViewController:self onDoneSelector:nil];

    // init data
    self.selectedIndex = -1;
    self.highlightedIndex = -1;

    // setup subViews..
    _alertView = [self AlertView];
    _viewArray = [self setupSubViews];

    _currentView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initValues
{
    if(_viewIndex > 0)
    {
        while (_viewIndex > 0) {
            [self OnBack:nil];
        }
        
        // init for equiment table view
        self.selectedIndex = -1;
        self.highlightedIndex = -1;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];

    [self initValues];

    if([[EquipmentData sharedData] cartCount] == 0)
    {
        [_bottomBar removeFromSuperview];
        
        [self.view addSubview:_alertView];
    }
    else
    {
        [_alertView removeFromSuperview];

        _bReloading = YES;

        [self.view addSubview:_bottomBar];
        
        [self.view addSubview:self.tableView];
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _bReloading = NO;
    
    [self.kbHelper enable];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.kbHelper disable];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setup subviews

- (UIView*)AlertView
{
    CGFloat  width      = [[UIScreen mainScreen] bounds].size.width;
    CGFloat  fontSize   = 14.0;

    CGRect  frame       = self.container.frame;
    UIView* view        = [[UIView alloc] initWithFrame:self.container.frame];

    if(width >= 414)
        fontSize = 17;
    else if(width >= 375)
        fontSize = 16;

    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(frame), 100)];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor blackColor];
    title.numberOfLines = 0;
    title.text = @"You have nothing in your basket!\n\nReturn to the equipment list and pick\nsomething to add in here.";
    title.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    [view addSubview:title];
    
    UIImage* image = [UIImage imageNamed:@"mark"];
    CGSize   size = image.size;
    UIImageView* imgView = [[UIImageView alloc] initWithImage:image];

    imgView.frame = CGRectMake((CGRectGetWidth(frame) - size.width)/2, (CGRectGetHeight(frame) - size.height)/2 + 20, size.width, size.height);
    [view addSubview:imgView];

    return view;
}

- (NSMutableArray*)setupSubViews
{
    CGSize      szString;
    CGRect      bounds;
    CGRect      frame       = self.container.frame;
    CGRect      viewFrame   = self.container.frame;
    UIColor     *color      = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    UIColor     *bkColor    = kForeColor;
    UIFont      *font       = [UIFont fontWithName:@"Helvetica" size:16.0];

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    viewFrame.size.height -= BOTTOM_BAR_HEIGHT;
    
    // bottomBar
    frame = self.container.frame;
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame) - BOTTOM_BAR_HEIGHT,
                                                                 CGRectGetWidth(frame), BOTTOM_BAR_HEIGHT)];
    _bottomBar.backgroundColor = color;
    
    // seperator
    UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), kLineHeight)];
    seperator.backgroundColor = kLineColor;
    [_bottomBar addSubview:seperator];
    
    // btNext
    frame = self.container.frame;
    _btNext = [[UIButton alloc] initWithFrame:CGRectZero];
    _btNext.titleLabel.textAlignment = NSTextAlignmentCenter;
    _btNext.titleLabel.textColor = [UIColor whiteColor];
    _btNext.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _btNext.backgroundColor = bkColor;
    [_btNext setTitle:@"NEXT" forState:UIControlStateNormal];
    [_btNext addTarget:self action:@selector(OnNext:) forControlEvents:UIControlEventTouchDown];
    _btNext.frame = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN,
                               CGRectGetWidth(frame) - BUTTON_X_MARGIN*2, BUTTON_HEIGHT);
    [_bottomBar addSubview:_btNext];

    // btBack
    frame = self.container.frame;
    _btBack = [[UIButton alloc] initWithFrame:CGRectZero];
    _btBack.titleLabel.textAlignment = NSTextAlignmentCenter;
    _btBack.titleLabel.textColor = [UIColor whiteColor];
    _btBack.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _btBack.backgroundColor = bkColor;
    [_btBack setTitle:@"<" forState:UIControlStateNormal];
    [_btBack addTarget:self action:@selector(OnBack:) forControlEvents:UIControlEventTouchDown];
    _btBack.frame = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN,
                               BUTTON_HEIGHT, BUTTON_HEIGHT);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    // init tableView
    frame.size.height -= BOTTOM_BAR_HEIGHT;
    self.tableView = [[UITableView alloc] initWithFrame:frame];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // init calendar view
    _kal = [[KalViewController alloc] initWithFrame:viewFrame withSelectionMode:KalSelectionModeRange];

    _kal.delegate = self;
    _kal.minAvailableDate = [NSDate dateStartOfDay:[NSDate date]];
    _kal.maxAVailableDate = [_kal.minAvailableDate offsetMonth:6];

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // init info view
    frame = self.container.frame;
    frame.size.height -= BOTTOM_BAR_HEIGHT;
    UIView* submitView = [[UIView alloc] initWithFrame:frame];
    submitView.backgroundColor = [UIColor whiteColor];

    // scrollview
    bounds = submitView.bounds;
    bounds.size.height -= BOTTOM_BAR_HEIGHT;

    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    [submitView addSubview:scrollView];
    // textfield

    self.txtName    = [self createTextFieldWithPlaceholder:@"Name" superView:scrollView index:0];
    self.txtMail    = [self createTextFieldWithPlaceholder:@"E-mail Address" superView:scrollView index:1];
    self.txtContact = [self createTextFieldWithPlaceholder:@"Contact Number" superView:scrollView index:2];
    self.txtNRIC    = [self createTextFieldWithPlaceholder:@"NRIC/FIN/Passport No." superView:scrollView index:3];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.txtName.text       = [userDefaults stringForKey:kUserNameKey];
    self.txtMail.text       = [userDefaults stringForKey:kUserMailKey];
    self.txtContact.text    = [userDefaults stringForKey:kUserContactNumKey];
    self.txtNRIC.text       = [userDefaults stringForKey:kUserNRICKey];
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    bounds  = CGRectOffset(self.txtNRIC.frame, 0, CGRectGetHeight(self.txtNRIC.frame));
    bounds.size.height *= 3;
    
    // textfield
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];

    self.txtComment = [[SZTextView alloc] init];
    self.txtComment.backgroundColor = [UIColor clearColor];
    self.txtComment.textAlignment = NSTextAlignmentLeft;
    self.txtComment.textColor = [UIColor blackColor];
    self.txtComment.font = [UIFont fontWithDescriptor:fontD size:16.0];
    self.txtComment.placeholder = @"Comments (if any)";
    self.txtComment.placeholderTextColor = kLightGrayColor;
    self.txtComment.frame = CGRectInset(bounds, -6, 10);
    [scrollView addSubview:self.txtComment];
    
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetMaxY(self.txtComment.frame) + 5);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    [self.kbHelper setInputView:scrollView];
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    // bottom
    bounds  = CGRectInset(CGRectOffset(submitView.bounds, 0, CGRectGetHeight(submitView.bounds) - BOTTOM_BAR_HEIGHT), 20, 0);
    NSString*   strInfo = @"We will process your request and send you a confirmation email once the booking is confirmed.";
    CGSize  szTitle = [self getSizeOfText:strInfo withFont:font widthOftext:CGRectGetWidth(bounds)];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    label.text = strInfo;
    
    label.frame = CGRectMake(20, CGRectGetMinY(bounds) + (BOTTOM_BAR_HEIGHT - szTitle.height)/2,
                             CGRectGetWidth(submitView.bounds) - 40, szTitle.height);
    
    [submitView addSubview:label];

    seperator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(submitView.bounds) - BOTTOM_BAR_HEIGHT, CGRectGetWidth(submitView.bounds), kLineHeight)];
    seperator.backgroundColor = kLineColor;
    [submitView addSubview:seperator];
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // init report view
    UIView* reportView = [[UIView alloc] initWithFrame:frame];
    reportView.backgroundColor = [UIColor whiteColor];
    
    bounds  = CGRectInset(CGRectOffset(reportView.bounds, 0, 50), 40, 0);
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[BOOKING_HTML dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    strInfo = [attrStr string];
    szString = [self getSizeOfText:strInfo withFont:font widthOftext:CGRectGetWidth(bounds)];

    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    label.attributedText = attrStr;
    
    bounds.size.height = szString.height;
    label.frame = bounds;

    [reportView addSubview:label];


    return [[NSMutableArray alloc] initWithArray:@[self.tableView, _kal.view, submitView, reportView]];
}

- (UITextField*)createTextFieldWithPlaceholder:(NSString*)placeholder superView:(UIView*)view index:(NSUInteger)index
{
    CGRect  bounds  = CGRectOffset(view.bounds, 0, 50*index);
    
    bounds.size.height = 46;

    // seperator
    UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bounds)-1, CGRectGetWidth(bounds), kLineHeight)];
    seperator.backgroundColor = kLineColor;
    [view addSubview:seperator];

    // textfield
    UITextField* tf = [[UITextField alloc] init];
    
    tf.borderStyle = UITextBorderStyleNone;
    tf.backgroundColor = [UIColor clearColor];
    tf.textAlignment = NSTextAlignmentLeft;
    tf.textColor = [UIColor blackColor];
    tf.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    tf.placeholder = placeholder;
    tf.frame = CGRectInset(bounds, 20, 5);
    [view addSubview:tf];

    return tf;
}

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

- (void)updateLayout
{
    CGRect frame;

    if(_viewIndex < 2)
        [_btNext setTitle:@"NEXT" forState:UIControlStateNormal];
    else if(_viewIndex < (_viewArray.count-1))
        [_btNext setTitle:@"SUBMIT" forState:UIControlStateNormal];
    else
        [_btNext setTitle:@"DONE" forState:UIControlStateNormal];

    if(_viewIndex == 0 || _viewIndex == (_viewArray.count-1))
    {
        frame = self.container.frame;
        _btNext.frame = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN,
                                   CGRectGetWidth(frame) - BUTTON_X_MARGIN*2, BUTTON_HEIGHT);
        
        [_btBack removeFromSuperview];
    }
    else
    {
        frame = self.container.frame;
        _btNext.frame = CGRectMake(BUTTON_X_MARGIN + 40, BUTTON_Y_MARGIN,
                                   CGRectGetWidth(frame) - BUTTON_X_MARGIN*2 - 30, BUTTON_HEIGHT);
        
        _btBack.frame = CGRectMake(BUTTON_X_MARGIN - 10, BUTTON_Y_MARGIN,
                                   BUTTON_HEIGHT, BUTTON_HEIGHT);

        
        [_bottomBar addSubview:_btBack];
    }
}

#pragma mark - Check mail address

- (BOOL) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Mail Send

- (NSString*)mailBody
{
    NSString* userName = (self.txtName.text.length > 0) ? self.txtName.text : @"";
    NSString* contactNum = (self.txtContact.text.length > 0) ? self.txtContact.text : @"";
    NSString* userNRIC = (self.txtNRIC.text.length > 0) ? self.txtNRIC.text : @"";
    NSString* beginDate = _kal.beginDate ? [NSDateFormatter localizedStringFromDate:_kal.beginDate dateStyle:NSDateFormatterMediumStyle
                                                                                                    timeStyle:NSDateFormatterNoStyle] : @"";
    NSString* endDate = _kal.endDate ? [NSDateFormatter localizedStringFromDate:_kal.endDate dateStyle:NSDateFormatterMediumStyle
                                                                                                timeStyle:NSDateFormatterNoStyle] : @"";
    NSString* comment = (self.txtComment.text.length > 0) ? self.txtComment.text : @"";
    NSString* date = @"";
    NSString* equipList = @"";
    
    NSString *string = [MAIL_TEMPLATE stringByReplacingOccurrencesOfString:USER_NAME withString:userName] ;
    string = [string stringByReplacingOccurrencesOfString:CONTACT_NUM   withString:contactNum];
    string = [string stringByReplacingOccurrencesOfString:USER_NRIC    withString:userNRIC];
    string = [string stringByReplacingOccurrencesOfString:COMMENT    withString:comment];

    // equimpent list
    if(beginDate.length > 0 && endDate.length > 0)
    {
        date = [DOUBLE_DATE_TEMPLATE stringByReplacingOccurrencesOfString:BEGIN_DATE    withString:beginDate];
        date = [date stringByReplacingOccurrencesOfString:END_DATE withString:endDate];
    }
    else
    {
        date = [SINGLE_DATE_TEMPLATE stringByReplacingOccurrencesOfString:BEGIN_DATE    withString:beginDate];
    }
    
    string = [string stringByReplacingOccurrencesOfString:DATE    withString:date];

    // equimpent list
    NSUInteger count = [[EquipmentData sharedData] cartCount];
    
    for(NSUInteger i=0; i<count; i++)
    {
        NSDictionary* dic = [[EquipmentData sharedData] cartDataWithIndex:i];
        NSString* strEquipment = [NSString stringWithFormat:@"%ld × %@", (long)[[dic objectForKey:kEquipmentCountKey] integerValue],
                                                                         [dic objectForKey:kEquipmentInfomationKey]];
        NSString* str = [EQUIPMENT_TEMPLATE stringByReplacingOccurrencesOfString:EQUIPMENT    withString:strEquipment];
        equipList = [equipList stringByAppendingString:str];
    }
        
    string = [string stringByReplacingOccurrencesOfString:EQUIPMENT_LIST    withString:equipList];

    return string;
}

- (void)SendMail:(BOOL)toUser
{
    MCOAddress*         from        = nil;
    MCOAddress*         to          = nil;
    MCOAddress*         reply       = nil;

    MCOMessageBuilder*  builder     = [[MCOMessageBuilder alloc] init];
    MCOSMTPSession*     smtpSession = [[MCOSMTPSession alloc]init];
    
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = kUserNameForMail;
    smtpSession.password = kPasswordForMail;
    smtpSession.authType = MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    if(toUser)
    {
        from    = [MCOAddress addressWithDisplayName:kEMailUserNameForCRC
                                          mailbox:kEMailAddressForCRC];
        to      = [MCOAddress addressWithDisplayName:nil
                                        mailbox:self.txtMail.text];
        reply   = [MCOAddress addressWithDisplayName:kEMailUserNameForCRC
                                           mailbox:kEMailAddressForCRC];
    }
    else
    {
        from    = [MCOAddress addressWithDisplayName:self.txtName.text
                                             mailbox:self.txtMail.text];
        to      = [MCOAddress addressWithDisplayName:nil
                                             mailbox:kEMailAddressForCRC];
        reply   = [MCOAddress addressWithDisplayName:self.txtName.text
                                             mailbox:self.txtMail.text];
    }

    [[builder header] setFrom:from];
    [[builder header] setReplyTo:@[reply]];
    
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:[NSString stringWithFormat:@"Camera Rental Centre - Booking Order (%@)", self.txtName.text]];
    [builder setHTMLBody:[self mailBody]];
    NSData * rfc822Data = [builder data];
    
    _bSendingMail = YES;
    [self enableControls:!_bSendingMail];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        
        _processedMailCount ++;
        
        if(error) {
            NSLog(@"Error sending email: %@", error);
        } else {
            _successedMailCount ++;
            NSLog(@"Successfully sent email!");
        }
        
        if(_processedMailCount == 2)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:_currentView animated:YES];
            });
            
            _bSendingMail = NO;
            [self enableControls:!_bSendingMail];
            
            if(_successedMailCount == 2)
            {
                [self reset];
                [self showNextView];
            }
            else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"We are unable to process your booking at the moment as the internet connection seems to be down. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alert show];
            }
            _processedMailCount = 0;
            _successedMailCount = 0;
        }
    }];
}

#pragma mark - process

- (void)reset
{
    // reset equipment data..
    [[EquipmentData sharedData] clearCart];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEquipmentClearNotification object:nil];
    
    // reset calenda
    _kal.beginDate = nil;
    _kal.endDate = nil;
    
    // save user info
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.txtName.text forKey:kUserNameKey];
    [userDefaults setObject:self.txtMail.text forKey:kUserMailKey];
    [userDefaults setObject:self.txtNRIC.text forKey:kUserNRICKey];
    [userDefaults setObject:self.txtContact.text forKey:kUserContactNumKey];
    
    self.txtComment.text = @"";
}

- (void)processSubmit
{
    if(self.txtName.text.length == 0 ||
       self.txtMail.text.length == 0 ||
       self.txtContact.text.length == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please ensure that you have included your name, email and contact number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    if(![self validEmail:self.txtMail.text])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your Mail Address is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    _bSendingMail      = NO;
    
    _processedMailCount = 0;
    _successedMailCount = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:_currentView animated:YES];
    });

    [self SendMail:YES];
    [self SendMail:NO];
}

- (void)processDone
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)showNextView
{
    UIView * orgView = _viewArray[_viewIndex++];
    UIView * newView = _viewArray[_viewIndex];
    
    CGRect  orgFrame = orgView.frame;
    CGRect  newFrame = CGRectOffset(orgFrame, CGRectGetWidth(orgFrame), 0);
    
    newView.frame = newFrame;
    [self.view addSubview:newView];
    [UIView animateWithDuration:0.5
                     animations:^{
                         orgView.frame = CGRectOffset(orgFrame, -CGRectGetWidth(orgFrame), 0);
                         newView.frame = orgFrame;
                         [self updateLayout];
                     }
                     completion:^(BOOL finished){
                         [orgView removeFromSuperview];
                         _currentView = newView;
                     }];
    [UIView commitAnimations];
}

- (IBAction)OnNext:(id)sender
{
    if(_bSendingMail)
        return;

    if(_viewIndex == CartViewStyleSelectDate)
    {
        if(_kal.beginDate == nil)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select the date(s) required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            return;
        }
    }
    
    if(_viewIndex == CartViewStyleSubmit)
    {
        [self processSubmit];
        return;
    }
    
    if(_viewIndex == CartViewStyleDone)
    {
        [self processDone];
        return;
    }
    
    [self showNextView];
}

- (IBAction)OnBack:(id)sender
{
    if(_bSendingMail)
        return;

    if(_viewIndex == 0)
        return;
    
    UIView * orgView = _viewArray[_viewIndex--];
    UIView * newView = _viewArray[_viewIndex];
    
    CGRect  orgFrame = orgView.frame;
    CGRect  newFrame = CGRectOffset(orgFrame, -CGRectGetWidth(orgFrame), 0);
    
    CGFloat duration = (sender == nil) ? 0.0 : 0.5;
    newView.frame = newFrame;
    [self.view addSubview:newView];
    [UIView animateWithDuration:duration
                     animations:^{
                         orgView.frame = CGRectOffset(orgFrame, CGRectGetWidth(orgFrame), 0);
                         newView.frame = orgFrame;
                         [self updateLayout];
                    }
                     completion:^(BOOL finished){
                         [orgView removeFromSuperview];
                         _currentView = newView;
                    }];
    [UIView commitAnimations];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger count = [[EquipmentData sharedData] cartCount];
    
    if (count == 0 && _bottomBar.superview == self.view) {
        [_bottomBar removeFromSuperview];
        
        [self.view addSubview:_alertView];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellID = @"CartCellID";
    CartCell *cell = (CartCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[CartCell alloc] initWithReuseIdentifier:cellID];
    }
    
    NSMutableDictionary* dic = [[EquipmentData sharedData] cartDataWithIndex:indexPath.row];
    
    cell.information = [EquipmentData infoOfEquipment:dic];
    cell.count = [EquipmentData equipmentCartCount:dic];
    cell.imageURL = [NSURL URLWithString:[EquipmentData imagePathOfEquipment:dic]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [EquipmentCell height];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        [[EquipmentData sharedData] changeCartWithIndex:indexPath.row withCount:0];
                                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    }];
    button.backgroundColor = kForeColor;
    
    return @[button];
}
@end
