//
//  CartCell.m
//  CRC
//
//  Created by Jinhui Lee on 12/18/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "CartCell.h"

#import "UIImageView+WebCache.h"
#import "EquipmentData.h"
#import "ActionSheetStringPicker.h"

#define X_MARGIN        5
#define X_MARGIN2       16
#define Y_MARGIN        10

#define IMAGE_MARGIN    10

#define BUTTON_X_MARGIN 60
#define BUTTON_Y_MARGIN 15
#define BUTTON_HEIGHT   40

#define IMAGE_WIDTH     80
#define COUNT_WIDTH     50
#define COUNT_HEIGHT    42
#define COUNT_HEIGHT2   18
#define NORMAL_HEIGHT   80


@interface CartCell () <UIActionSheetDelegate, UIAlertViewDelegate>
{
    UIActionSheet* _actionSheet;
}
@property (nonatomic, assign) CGSize        imgSize;

@property (strong, nonatomic) UITableView   *parentView;

@property (strong, nonatomic) UIImageView   *imgView;
@property (strong, nonatomic) UILabel       *lblInfo;
@property (strong, nonatomic) UILabel       *lblCount;
@property (strong, nonatomic) UIButton      *btCount;

@property (strong, nonatomic) UIView        *seperator;

@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;

@end

@implementation CartCell

+ (CGFloat)height
{
    return NORMAL_HEIGHT;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat  width          = [[UIScreen mainScreen] bounds].size.width;
        CGFloat  infoFontSize   = 14.0;
        UIColor* color          = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
        
        _count = -1;
        if(width >= 414)
            infoFontSize = 17;
        else if(width >= 375)
            infoFontSize = 16;
        
        self.seperator = [[UIView alloc] initWithFrame:CGRectMake(0, NORMAL_HEIGHT-kLineHeight, width, kLineHeight)];
        self.seperator.backgroundColor = kLineColor;
        [self addSubview:self.seperator];
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imgView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(imageChanged:)
                                                     name:kSDWebImageChangedNotification object:self.imgView];
        
        self.lblInfo = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblInfo.textAlignment = NSTextAlignmentLeft;
        self.lblInfo.backgroundColor = [UIColor clearColor];
        self.lblInfo.textColor = [UIColor blackColor];
        self.lblInfo.numberOfLines = 0;
        self.lblInfo.font = [UIFont fontWithName:@"Helvetica" size:infoFontSize];
        self.lblInfo.frame = CGRectMake(IMAGE_WIDTH + X_MARGIN*2, 0, width - IMAGE_WIDTH - COUNT_WIDTH - (X_MARGIN+ X_MARGIN2)*2, NORMAL_HEIGHT);
        [self addSubview:self.lblInfo];

        self.btCount = [[UIButton alloc] initWithFrame:CGRectMake(width - COUNT_WIDTH - X_MARGIN2, (NORMAL_HEIGHT - COUNT_HEIGHT - COUNT_HEIGHT2)/2, COUNT_WIDTH, COUNT_HEIGHT+COUNT_HEIGHT2)];
        self.btCount.backgroundColor = [UIColor clearColor];
        [self.btCount addTarget:self action:@selector(OnCount:) forControlEvents:UIControlEventTouchDown];

        [self addSubview:self.btCount];
        
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COUNT_WIDTH, COUNT_HEIGHT)];
        bgView.backgroundColor = kLightGrayColor;
        bgView.userInteractionEnabled = NO;
        [self.btCount addSubview:bgView];

        UIView* bgView2 = [[UIView alloc] initWithFrame:CGRectInset(bgView.frame, 2, 2)];
        bgView2.backgroundColor = [UIColor whiteColor];
        bgView2.userInteractionEnabled = NO;
        [self.btCount addSubview:bgView2];
        
        self.lblCount = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCount.backgroundColor = [UIColor clearColor];
        self.lblCount.textAlignment = NSTextAlignmentCenter;
        self.lblCount.textColor = kForeColor;
        self.lblCount.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:40];
        self.lblCount.frame = CGRectMake(-1, 3, COUNT_WIDTH, COUNT_HEIGHT);
        self.lblCount.userInteractionEnabled = NO;
        [self.btCount addSubview:self.lblCount];
        
        UILabel* lblCount = [[UILabel alloc] initWithFrame:CGRectZero];
        lblCount.text = @"UNIT(S)";
        lblCount.textAlignment = NSTextAlignmentCenter;
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.textColor = color;
        lblCount.font = [UIFont fontWithName:@"Helvetica" size:10.0];
        lblCount.frame = CGRectMake(0, COUNT_HEIGHT, COUNT_WIDTH, COUNT_HEIGHT2);
        lblCount.userInteractionEnabled = NO;
        [self.btCount addSubview:lblCount];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)imageChanged:(NSNotification*)notification
{
    NSDictionary* dic = [notification userInfo];
    self.imgSize = CGSizeMake([[dic objectForKey:@"width"] floatValue], [[dic objectForKey:@"height"] floatValue]);
    
    self.imgView.frame = [self calculateBounds:CGRectMake(X_MARGIN, 0, IMAGE_WIDTH, NORMAL_HEIGHT)
                                      withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
}

- (UITableView *)parentTableView {
    
    if(self.parentView == nil)
    {
        UITableView *tableView = nil;
        UIView *view = self;
        while(view != nil) {
            if([view isKindOfClass:[UITableView class]]) {
                tableView = (UITableView *)view;
                break;
            }
            view = [view superview];
        }
        self.parentView = tableView;
    }
    
    return self.parentView;
}

- (CGRect)calculateBounds:(CGRect)frame withSize:(CGSize)size withMargin:(CGSize)margin
{
    frame = CGRectInset(frame, margin.width, margin.height);
    
    CGFloat W = CGRectGetWidth(frame);
    CGFloat H = CGRectGetHeight(frame);
    CGFloat width, height;
    
    double rate1 = (double)W/H;
    double rate2 = (double)size.width/size.height;
    
    if(rate1 > rate2)
    {
        height = H;
        width = size.width * ((double)H/size.height);
    }
    else
    {
        width = W;
        height = size.height * ((double)W/size.width);
    }
    
    return CGRectOffset(CGRectMake((W - width)/2, (H - height)/2, width, height), CGRectGetMinX(frame), CGRectGetMinY(frame));
}

#pragma mark - button action method
- (IBAction)OnCount:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"Choose Count" rows:@[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"] initialSelection:self.count target:self successAction:@selector(OnSelect:element:) cancelAction:@selector(OnCancel:) origin:self];
}

#pragma mark - Implementation

- (void)OnSelect:(NSNumber *)selectedIndex element:(id)element {
    
    NSInteger count = [selectedIndex integerValue];
    
    if(self.count > 0 && count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Do you want to remove this equipment?"
                                                           delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];
    }
    else
    {
        self.count = count;
        [[EquipmentData sharedData] changeCartWithIndex:[[self parentTableView] indexPathForCell:self].row withCount:_count];
    }
}

- (void)OnCancel:(id)sender {
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        self.count = 0;
        NSIndexPath* indexPath = [[self parentTableView] indexPathForCell:self];
        [[EquipmentData sharedData] changeCartWithIndex:indexPath.row withCount:_count];

        [[self parentTableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - properties

- (UIImage*)image
{
    return self.imgView.image;
}

- (void)setImageURL:(NSURL *)imageURL
{
    UIImage* image = [UIImage imageNamed:@"logo"];
    
    self.imgSize = image.size;
    
    [self.imgView setImageWithURL:imageURL placeholderImage:image];
}

- (NSString*)information
{
    return self.lblInfo.text;
}

- (void)setInformation:(NSString *)information
{
    self.lblInfo.text = information;
}

- (void)setCount:(NSInteger)count
{
    if(_count == count)
        return;
    
    _count = count;
    NSString* strCount = [NSString stringWithFormat:@"%lu", (long)_count];
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:strCount];
    [attrStr addAttribute:NSKernAttributeName value:@(-3.0) range:NSMakeRange(0, attrStr.length)];
    
    self.lblCount.attributedText = attrStr;
}

@end
