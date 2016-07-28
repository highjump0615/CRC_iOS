//
//  EquipmentCell.m
//  CRC
//
//  Created by Jinhui Lee on 12/2/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "EquipmentCell.h"
#import "UIImageView+WebCache.h"


#define X_MARGIN        5
#define Y_MARGIN        10

#define IMAGE_MARGIN    10

#define BUTTON_X_MARGIN 60
#define BUTTON_Y_MARGIN 15
#define BUTTON_HEIGHT   40

#define IMAGE_WIDTH     80
#define COST_WIDTH      80
#define COST_HEIGHT     48
#define COST_HEIGHT2    10
#define NORMAL_HEIGHT   80
#define EXPAND_HEIGHT   350


@interface EquipmentCell ()

@property (nonatomic, assign) CGSize        imgSize;

@property (strong, nonatomic) UITableView   *parentView;

@property (strong, nonatomic) UIImageView   *imgView;
@property (strong, nonatomic) UILabel       *lblInfo;
@property (strong, nonatomic) UILabel       *lblCost;
@property (strong, nonatomic) UILabel       *lblCost2;

@property (strong, nonatomic) UIButton      *btAction;
@property (strong, nonatomic) UIView        *highlightView;
@property (strong, nonatomic) UIView        *seperator;
@end

@implementation EquipmentCell

+ (CGFloat)height
{
    return NORMAL_HEIGHT;
}
+ (CGFloat)expandHeight
{
    return EXPAND_HEIGHT;
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
        UIColor* bkColor        = kForeColor;
        
        if(width >= 414)
            infoFontSize = 17;
        else if(width >= 375)
            infoFontSize = 16;
        
        self.seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kLineHeight)];
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
        [self addSubview:self.lblInfo];
        
        self.lblCost = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCost.textAlignment = NSTextAlignmentCenter;
        self.lblCost.backgroundColor = [UIColor clearColor];
        self.lblCost.textColor = color;
        self.lblCost.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:46];
//        self.lblCost.font = [UIFont fontWithName:@"Helvetica Bold" size:46];
        self.lblCost.frame = CGRectMake(width - COST_WIDTH - X_MARGIN, (NORMAL_HEIGHT - COST_HEIGHT - COST_HEIGHT2)/2, COST_WIDTH, COST_HEIGHT);
        [self addSubview:self.lblCost];
        
        self.lblCost2 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCost2.text = @"$ PER DAY";
        self.lblCost2.textAlignment = NSTextAlignmentCenter;
        self.lblCost2.backgroundColor = [UIColor clearColor];
        self.lblCost2.textColor = color;
        self.lblCost2.font = [UIFont fontWithName:@"Helvetica" size:10.0];
        self.lblCost2.frame = CGRectMake(width - COST_WIDTH - X_MARGIN, (NORMAL_HEIGHT - COST_HEIGHT - COST_HEIGHT2)/2 + COST_HEIGHT, COST_WIDTH, COST_HEIGHT2);
        [self addSubview:self.lblCost2];
        
        self.btAction = [[UIButton alloc] initWithFrame:CGRectZero];
        self.btAction.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.btAction.titleLabel.textColor = [UIColor whiteColor];
        self.btAction.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
        self.btAction.backgroundColor = bkColor;
        [self.btAction setTitle:@"ADD TO CART" forState:UIControlStateNormal];
        [self.btAction addTarget:self action:@selector(OnAction:) forControlEvents:UIControlEventTouchDown];
        self.btAction.frame = CGRectMake(BUTTON_X_MARGIN, EXPAND_HEIGHT - BUTTON_HEIGHT - BUTTON_Y_MARGIN, width - BUTTON_X_MARGIN*2, BUTTON_HEIGHT);
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, NORMAL_HEIGHT)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.99];
        label.text = @"CHOPED";
        label.font = [UIFont fontWithName:@"Helvetica Bold" size:50];
        
        self.highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, NORMAL_HEIGHT)];
        self.highlightView.backgroundColor = [bkColor colorWithAlphaComponent:0.6];
        
        [self.highlightView addSubview:label];
        [self addSubview:self.highlightView];
        
        self.state = EquipmentCellStateNormal;
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

    if(_state == EquipmentCellStateHighlighted)
    {
        CGFloat  width  = [[UIScreen mainScreen] bounds].size.width;

        self.imgView.frame = [self calculateBounds:CGRectMake(0, NORMAL_HEIGHT, width, EXPAND_HEIGHT - NORMAL_HEIGHT - BUTTON_Y_MARGIN - BUTTON_HEIGHT)
                                          withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
    }
    else
    {
        self.imgView.frame = [self calculateBounds:CGRectMake(X_MARGIN, 0, IMAGE_WIDTH, NORMAL_HEIGHT)
                                          withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
    }
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

- (void)updateControls:(EquipmentCellState)state
{
    CGFloat  width  = [[UIScreen mainScreen] bounds].size.width;
    BOOL     bImageMovable = !CGSizeEqualToSize(self.imgSize, CGSizeZero);
    BOOL     bCollapsed = (_state == EquipmentCellStateHighlighted && state == EquipmentCellStateNormal) ? YES : NO;
   
    if(state == EquipmentCellStateHighlighted)
    {
        if(self.highlightView)
            self.highlightView.hidden = YES;
        
        if(_state == EquipmentCellStateReload)
        {
            self.lblInfo.frame = CGRectMake(X_MARGIN*2, 0, width - IMAGE_WIDTH - COST_WIDTH - X_MARGIN*4, NORMAL_HEIGHT);
            
            if(bImageMovable)
            {
                self.imgView.frame = [self calculateBounds:CGRectMake(0, NORMAL_HEIGHT, width, EXPAND_HEIGHT - NORMAL_HEIGHT - BUTTON_Y_MARGIN - BUTTON_HEIGHT)
                                                  withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
            }
            [self addSubview:self.btAction];
        }
        else
        {
            // init
            self.lblInfo.frame = CGRectMake(IMAGE_WIDTH + X_MARGIN*2, 0, width - IMAGE_WIDTH - COST_WIDTH - X_MARGIN*4, NORMAL_HEIGHT);
            
            if(bImageMovable)
            {
                self.imgView.frame = [self calculateBounds:CGRectMake(X_MARGIN, 0, IMAGE_WIDTH, NORMAL_HEIGHT)
                                                  withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
            }
            
            // animation
            [UIView animateWithDuration:0.5
                             animations:^{
                                 
                                 self.lblInfo.frame = CGRectMake(X_MARGIN*2, 0, width - IMAGE_WIDTH - COST_WIDTH - X_MARGIN*4, NORMAL_HEIGHT);
                                 
                                 if(bImageMovable)
                                 {
                                     self.imgView.frame = [self calculateBounds:CGRectMake(0, NORMAL_HEIGHT, width, EXPAND_HEIGHT - NORMAL_HEIGHT - BUTTON_Y_MARGIN - BUTTON_HEIGHT)
                                                                       withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
                                 }
                             }
                             completion:^(BOOL finished){
                                 [self addSubview:self.btAction];
                             }];
            [UIView commitAnimations];
        }
    }
    else
    {
        [self.btAction removeFromSuperview];
        
        if(state == EquipmentCellStateSelected || bCollapsed)
        {
            if(_state == EquipmentCellStateReload)
            {
                self.lblInfo.frame = CGRectMake(IMAGE_WIDTH + X_MARGIN*2, 0, width - IMAGE_WIDTH - COST_WIDTH - X_MARGIN*4, NORMAL_HEIGHT);
                
                if(bImageMovable)
                {
                    self.imgView.frame = [self calculateBounds:CGRectMake(X_MARGIN, 0, IMAGE_WIDTH, NORMAL_HEIGHT)
                                                      withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
                }
                if(!bCollapsed && self.highlightView)
                    self.highlightView.hidden = NO;
           }
            else
            {
                // animation
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     
                                     self.lblInfo.frame = CGRectMake(IMAGE_WIDTH + X_MARGIN*2, 0, width - IMAGE_WIDTH - COST_WIDTH - X_MARGIN*4, NORMAL_HEIGHT);
                                     
                                     if(bImageMovable)
                                     {
                                         self.imgView.frame = [self calculateBounds:CGRectMake(X_MARGIN, 0, IMAGE_WIDTH, NORMAL_HEIGHT)
                                                                           withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
                                     }
                                 }
                                 completion:^(BOOL finished){
                                     if(!bCollapsed && self.highlightView)
                                         self.highlightView.hidden = NO;
                                 }];
                [UIView commitAnimations];
            }
        }
        else
        {
            if(self.highlightView)
                self.highlightView.hidden = YES;
            
            self.lblInfo.frame = CGRectMake(IMAGE_WIDTH + X_MARGIN*2, 0, width - IMAGE_WIDTH - COST_WIDTH - X_MARGIN*4, NORMAL_HEIGHT);
            
            if(bImageMovable)
            {
                self.imgView.frame = [self calculateBounds:CGRectMake(X_MARGIN, 0, IMAGE_WIDTH, NORMAL_HEIGHT)
                                                  withSize:self.imgSize withMargin:CGSizeMake(IMAGE_MARGIN, IMAGE_MARGIN)];
            }
        }
    }
    _state = state;
}

#pragma mark - button action method
- (IBAction)OnAction:(id)sender
{
        if(_state == EquipmentCellStateHighlighted)
            self.state = EquipmentCellStateSelected;
}

#pragma mark - properties

- (void)setState:(EquipmentCellState)state
{
    if(state <= EquipmentCellStateNone)
    {
        _state = state;
        
        return;
    }
    
    NSString* notification = nil;
    
    if(_state == EquipmentCellStateHighlighted && state == EquipmentCellStateSelected)
        notification = kEquipmentAddToCartNotification;
    else if(_state == EquipmentCellStateSelected && state == EquipmentCellStateNormal)
        notification = kEquipmentRemoveFromCartNotification;
    
    if(notification)
    {
        UITableView* tableView = [self parentTableView];
        
        NSIndexPath* indexPath = [tableView indexPathForCell:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:indexPath];
    }
    else
    {
        [self updateControls:(state)];
    }
}

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

- (NSString*)cost
{
    return self.lblCost.attributedText.string;
}

- (void)setCost:(NSString *)cost
{
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:cost];
    [attrStr addAttribute:NSKernAttributeName value:@(-3.0) range:NSMakeRange(0, attrStr.length)];
    
    self.lblCost.attributedText = attrStr;
}

@end
