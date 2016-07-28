//
//  SwipeView.m
//  CRC
//
//  Created by Jinhui Lee on 12/20/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "SwipeView.h"
#import "EquipmentViewController.h"

#define SWIPE_BUTTON_HEIGHT     15
#define MINIMUM_HEIGHT          17

#define AUTO_SWIPE_HEIGHT       30

#define X_MARGIN                16
#define Y_MARGIN                6
#define BUTTON_MARGIN           3
#define BUTTON_HEGITH           20

#define BUTTON_RADIUS           10


//////////////////////////////////////////////////
//////////////////////////////////////////////////
#pragma mark -
#pragma mark - TouchView

@implementation TouchView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [self.parentView touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.parentView touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.parentView touchesEnded:touches withEvent:event];
}

@end

//////////////////////////////////////////////////
//////////////////////////////////////////////////

#pragma mark - 
#pragma mark - FilterButton

@interface FilterButton : UIButton

@property (nonatomic, assign) BOOL          selectedFilter;
@property (nonatomic, strong) NSString*     title;
@property (nonatomic, strong) NSString*     info;

@end

@implementation FilterButton

- (void)setSelectedFilter:(BOOL)selected
{
    _selectedFilter = selected;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIColor* textColor = nil;
    UIColor* fillColor = nil;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //for the shadow, save the state then draw the shadow
    CGContextSaveGState(context);

    if(self.selectedFilter)
    {
        textColor = [UIColor whiteColor];
        fillColor = kForeColor;
    }
    else{
        textColor = kForeColor;
        fillColor = [UIColor whiteColor];
    }
    
    //now draw the rounded rectangle
    CGContextSetStrokeColorWithColor(context, kForeColor.CGColor);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    //since I need room in my rect for the shadow, make the rounded rectangle a little smaller than frame
    CGRect rrect = CGRectInset(self.bounds, BUTTON_MARGIN, BUTTON_MARGIN);
    CGFloat radius = BUTTON_RADIUS;
    // the rest is pretty much copied from Apples example
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);

    // Close the path
    CGContextClosePath(context);
    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // draw title..
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *attributes = @{ NSFontAttributeName: self.titleLabel.font,
                                  NSForegroundColorAttributeName: textColor,
                                  NSParagraphStyleAttributeName: paragraphStyle };

    CGSize size = [self.title sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake(rrect.origin.x + floorf((rrect.size.width - size.width) / 2),
                                 rrect.origin.y + floorf((rrect.size.height - size.height) / 2),
                                 size.width,
                                 size.height);
    
    [self.title drawInRect:textRect withAttributes:attributes];
    
    CGContextRestoreGState(context);
}

@end

//////////////////////////////////////////////////
//////////////////////////////////////////////////

#pragma mark -
#pragma mark - SwipeView

@interface SwipeView()
{
    BOOL            _bDragging;
    BOOL            _bSwipeDown;
    CGFloat         _orgYPos;
    CGRect          _orgRect;
    
    BOOL            _bExpand;
    CGFloat         _baseYPos;
    NSDictionary*   _fontDic;
}

@property (nonatomic, strong)   UIButton* btSwipe;
@property (nonatomic, strong)   UILabel*  lblFilter;
@property (nonatomic, strong)   NSString* currentInfo;

@property (nonatomic, strong)   NSMutableArray* buttons;
@property (nonatomic, strong)   NSMutableArray* lines;

@end

//////////////////////////////////////////////////

@implementation SwipeView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = MINIMUM_HEIGHT;
    
    self = [super initWithFrame:frame];
    if(self)
    {
        _bExpand    = NO;
        _baseYPos   = CGRectGetMinY(frame);
        
        [self initControls];
        
        _fontDic = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12]};
    }
    return self;
}

- (void)initControls
{
    CGRect bounds = self.bounds;
    UIImage* image = [UIImage imageNamed:@"down"];
    
    bounds.size.height = SWIPE_BUTTON_HEIGHT;
    UIButton* btSwipe = [[UIButton alloc] initWithFrame:CGRectOffset(bounds, 0, 1)];
    btSwipe.backgroundColor = [UIColor colorWithRed:250.f/255 green:190.f/255 blue:120.f/255 alpha:1.0];
    [btSwipe setImage:image forState:UIControlStateNormal];
    [btSwipe setImage:image forState:UIControlStateHighlighted];
    [btSwipe setImage:image forState:UIControlStateDisabled];
    [btSwipe addTarget:self action:@selector(OnSwipe:) forControlEvents:UIControlEventTouchUpInside];
    btSwipe.enabled = NO;
    
    [self addSubview:btSwipe];
    self.btSwipe = btSwipe;
}

- (BOOL)isExpanded
{
    return _bExpand;
}


#pragma mark - dragging

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.superview];
    
//    if (CGRectContainsPoint(self.frame, touchLocation))
    {
        
        _bDragging = YES;
        _orgYPos = touchLocation.y;
        _orgRect = self.frame;
        
        if(CGRectContainsPoint(self.btSwipe.frame, [touch locationInView:self]))
        {
            _bSwipeDown = YES;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.superview];
    
    if (_bDragging) {
        CGFloat curPos = touchLocation.y;
        CGFloat offset = curPos - _orgYPos;
        
        if(fabsf(offset) > AUTO_SWIPE_HEIGHT)
        {
            _bDragging = NO;
            
            [self swipe:(offset > 0)];
        }
        else
        {
//            [self move:offset];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];

    _bDragging = NO;
    
    if(_bSwipeDown && CGRectContainsPoint(self.btSwipe.frame, [touch locationInView:self]))
    {
        _bSwipeDown = NO;
        [self OnSwipe:nil];
    }
}

#pragma mark - calculate rect


- (FilterButton*)createButton:(NSString*)title withInfo:(NSString*)info
{
    title = [title uppercaseString];
    
    CGSize strSize = [title sizeWithAttributes:_fontDic];

    FilterButton* button = [[FilterButton alloc] initWithFrame:CGRectMake(0, 0, strSize.width + (BUTTON_RADIUS + BUTTON_MARGIN - 1) * 2, BUTTON_HEGITH + BUTTON_MARGIN*2)];
    button.title = title;
    button.info = info;
    button.titleLabel.font = [_fontDic objectForKey:NSFontAttributeName];

    if([self.currentInfo hasPrefix:info])
        button.selectedFilter = YES;

    [button addTarget:self action:@selector(OnFilterChanged:) forControlEvents:UIControlEventTouchDown];
    
    
    return button;
}

#pragma mark - SearchFilter

- (NSArray*)_searchFilter:(NSArray*)filtersArray withDepth:(NSUInteger)depth
{
    NSMutableArray* filter = [[NSMutableArray alloc] init];
    
    if (filtersArray.count == 0)
    {
        return filter;
    }
    
    NSArray* arry = [self.currentInfo componentsSeparatedByString:@"."];
    
    if(arry.count > depth)
    {
        NSInteger index = [arry[depth] integerValue];
        
        if(index > 0)
        {
            NSDictionary* dic = filtersArray[index-1];
            [filter addObject:[[dic objectForKey:kFilterNameKey] lowercaseString]];
            
            
            NSArray* subFilter = [self _searchFilter:[dic objectForKey:kFilterSubFilterKey] withDepth:depth+1];

            if(subFilter.count > 0)
                [filter addObjectsFromArray:subFilter];
        }
    }
    
    return filter;
}

- (NSArray*)searchFilter
{
    return [self _searchFilter:self.filters withDepth:0];
}

#pragma mark - Build Filter

- (NSMutableArray*)_buildFilter:(NSArray*)filtersArray withDepth:(NSUInteger)depth withHeight:(CGFloat*)pHeight;
{
    BOOL        bSelected = NO;
    CGFloat     width = X_MARGIN;
    CGFloat     WIDTH = CGRectGetWidth(self.bounds);
    NSString    *info = self.currentInfo ? self.currentInfo : @"";
    NSMutableArray  *subButtons        = [[NSMutableArray alloc] init];
    UILabel*    label = nil;
    
    // create Filter Label..
    if(self.lblFilter == nil)
    {
        NSString* strLabel = @"FILTER:";
        CGSize strSize = [strLabel sizeWithAttributes:_fontDic];
        CGRect frame = CGRectMake(width, *pHeight, strSize.width, BUTTON_HEGITH + BUTTON_MARGIN*2);
        CGRect bounds;
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = strLabel;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [_fontDic objectForKey:NSFontAttributeName];
        [label sizeToFit];
        bounds = label.bounds;
        label.frame = CGRectMake(CGRectGetMinX(frame) + (CGRectGetWidth(frame) - CGRectGetWidth(bounds))/2,
                                 CGRectGetMinY(frame) + 3 + (CGRectGetHeight(frame) - CGRectGetHeight(bounds))/2,
                                 CGRectGetWidth(bounds), CGRectGetHeight(bounds));
        self.lblFilter = label;
    }
    
    if( depth == 0)
        width += CGRectGetWidth(self.lblFilter.frame) + BUTTON_MARGIN;

    // create buttons..
    
    for(NSDictionary* dic in filtersArray)
    {
        NSString* title = [dic objectForKey:kFilterDisplayNameKey];
        NSString* info =  [dic objectForKey:kFilterIDKey];
        
        FilterButton* button = [self createButton:title withInfo:info];
        [subButtons addObject:button];
        
        bSelected |= button.selectedFilter;
    }
    
    if( subButtons.count == 0)  return nil;
    
    NSString* allInfo = ((FilterButton*)subButtons[0]).info;
    NSString* lastPath = [[allInfo componentsSeparatedByString:@"."] lastObject];
    allInfo = [allInfo stringByReplacingCharactersInRange:NSMakeRange(allInfo.length - lastPath.length, lastPath.length)
                                               withString:@"0"];
    FilterButton* allButton = [self createButton:@"ALL" withInfo:allInfo];
    if(!bSelected)
        allButton.selectedFilter = YES;
    
    [subButtons insertObject:allButton atIndex:0];
    
    // layout buttons..
    *pHeight += BUTTON_MARGIN;
    
    for(FilterButton* button in subButtons)
    {
        CGRect frame = button.frame;
        
        if((CGRectGetWidth(frame) + width + X_MARGIN) > WIDTH)
        {
            width = X_MARGIN;
            *pHeight += BUTTON_HEGITH + BUTTON_MARGIN*2 + BUTTON_MARGIN;
        }

        frame = CGRectOffset(frame, width, *pHeight);
        width += CGRectGetWidth(frame);

        button.frame = frame;
    }
    *pHeight += BUTTON_HEGITH + BUTTON_MARGIN*2 + BUTTON_MARGIN;
    
    // sub buttons..
    NSArray* infos = [info componentsSeparatedByString:@"."];
    
    if(info.length > 0 && infos.count > depth)
    {
        NSInteger index = [infos[depth] integerValue]-1;
        
        if( index >= 0 && index < filtersArray.count)
        {
            // seperate line
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, *pHeight, WIDTH, kLineHeight)];
            line.backgroundColor = kLineColor;
            
            NSMutableArray* subArray = [self _buildFilter:[filtersArray[index] objectForKey:kFilterSubFilterKey] withDepth:depth+1 withHeight:pHeight];
            
            // sub buttons..
            [subButtons addObjectsFromArray:subArray];
            
            if(subArray.count > 0)
            {
                [subButtons addObject:line];
            }
            else
                line = nil;
        }
    }
    
    if(depth == 0 && self.lblFilter)
    {
        [subButtons addObject:self.lblFilter];
    }
    
    return subButtons;
}

- (void)buildFilter
{
    CGFloat height = Y_MARGIN;
    NSMutableArray* newButtons = [self _buildFilter:self.filters  withDepth:0 withHeight:&height];
    
    height += Y_MARGIN;
    
    CGRect  frame = self.frame;
    CGFloat offset = height + MINIMUM_HEIGHT - CGRectGetHeight(frame);
    CGRect  contentFrame = self.contentView.frame;

    frame.size.height = height + MINIMUM_HEIGHT;
    
    if(_bExpand)
    {
        contentFrame = CGRectOffset(contentFrame, 0, offset);
        contentFrame.size.height -= offset;

        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             self.contentView.frame = contentFrame;
                             self.frame = frame;
                             
                             self.btSwipe.frame = CGRectMake(0, CGRectGetHeight(self.frame) - SWIPE_BUTTON_HEIGHT - 1,
                                                             CGRectGetWidth(self.frame), SWIPE_BUTTON_HEIGHT);
                             [self addSubview:self.btSwipe];
                         }
                         completion:^(BOOL finished){
                             for(UIView* subView in self.buttons)
                             {
                                 [subView removeFromSuperview];
                             }
                             [self.buttons removeAllObjects];
                             
                             self.buttons = newButtons;
                             for(UIView* subView in self.buttons)
                             {
                                 [self addSubview:subView];
                             }
                         }];
        [UIView commitAnimations];
    }
    else{

        for(UIView* subView in self.buttons)
        {
            [subView removeFromSuperview];
        }
        [self.buttons removeAllObjects];
        
        self.buttons = newButtons;
        for(UIView* subView in self.buttons)
        {
            [self addSubview:subView];
        }

        frame = CGRectOffset(frame, 0, -offset);
        
        self.frame = frame;
        
        self.btSwipe.frame = CGRectMake(0, CGRectGetHeight(self.frame) - SWIPE_BUTTON_HEIGHT - 1,
                                        CGRectGetWidth(self.frame), SWIPE_BUTTON_HEIGHT);

    }
}

#pragma mark - action method

- (void)setFilters:(NSMutableArray *)filters
{
    _filters = filters;
    
    [self OnFilterChanged:nil];
}

- (void)move:(CGFloat)offset
{
    CGRect      frame   = self.frame;
    CGRect      contentFrame = self.contentView.frame;
    
    frame = CGRectOffset(frame, 0, offset);
    
    contentFrame = CGRectOffset(contentFrame, 0, offset);
    contentFrame.size.height -= offset;
    
    self.contentView.frame = contentFrame;
    self.frame = frame;
    
    self.btSwipe.frame = CGRectMake(0, CGRectGetHeight(frame) - SWIPE_BUTTON_HEIGHT - 1,
                                    CGRectGetWidth(frame), SWIPE_BUTTON_HEIGHT);
}

- (void)swipe:(BOOL)expand
{
    if(_bExpand == expand || self.filters.count == 0)
        return;
    
    _bExpand = expand;
    
    CGRect      frame   = self.frame;
    CGRect      contentFrame = self.contentView.frame;
    CGFloat     height  = CGRectGetHeight(frame) - MINIMUM_HEIGHT;
    CGFloat     offset  = _bExpand ? height : -height;
    UIImage*    image   = _bExpand ? [UIImage imageNamed:@"up"] : [UIImage imageNamed:@"down"];
    
    frame = CGRectOffset(frame, 0, offset);
    
    contentFrame = CGRectOffset(contentFrame, 0, offset);
    contentFrame.size.height -= offset;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.contentView.frame = contentFrame;
                         self.frame = frame;
                         
                         self.btSwipe.frame = CGRectMake(0, CGRectGetHeight(frame) - SWIPE_BUTTON_HEIGHT - 1,
                                                         CGRectGetWidth(frame), SWIPE_BUTTON_HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                         [_btSwipe setImage:image forState:UIControlStateNormal];
                         [_btSwipe setImage:image forState:UIControlStateHighlighted];
                         [_btSwipe setImage:image forState:UIControlStateDisabled];
                     }];
    [UIView commitAnimations];
}

- (IBAction)OnSwipe:(id)sender
{
    if(self.filters.count == 0)
        return;
    
    _bExpand = !_bExpand;
    
    CGRect      frame   = self.frame;
    CGRect      contentFrame = self.contentView.frame;
    CGFloat     height  = CGRectGetHeight(frame) - MINIMUM_HEIGHT;
    CGFloat     offset  = _bExpand ? height : -height;
    UIImage*    image   = _bExpand ? [UIImage imageNamed:@"up"] : [UIImage imageNamed:@"down"];

    frame = CGRectOffset(frame, 0, offset);
    
    contentFrame = CGRectOffset(contentFrame, 0, offset);
    contentFrame.size.height -= offset;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.contentView.frame = contentFrame;
                         self.frame = frame;
                         
                         self.btSwipe.frame = CGRectMake(0, CGRectGetHeight(frame) - SWIPE_BUTTON_HEIGHT - 1,
                                                         CGRectGetWidth(frame), SWIPE_BUTTON_HEIGHT);

                     }
                     completion:^(BOOL finished){
                         [_btSwipe setImage:image forState:UIControlStateNormal];
                         [_btSwipe setImage:image forState:UIControlStateHighlighted];
                         [_btSwipe setImage:image forState:UIControlStateDisabled];
                     }];
    [UIView commitAnimations];
}

#pragma mark - FilterChanged

- (IBAction)OnFilterChanged:(id)sender
{
    FilterButton* filter = (FilterButton*)sender;
    
    if(filter)
        self.currentInfo = filter.info;
    
    [self buildFilter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEquipmentFilterChangedNotification object:[self searchFilter]];
}

@end
