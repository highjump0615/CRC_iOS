/*
 * Copyright (c) 2014 Jinhui Lee
 */

#import <CoreGraphics/CoreGraphics.h>

#import "KalGridView.h"
#import "KalView.h"
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

#define SLIDE_NONE 0
#define SLIDE_UP 1
#define SLIDE_DOWN 2

const CGSize kTileSize = { 46.f, 32.f };

static NSString *kSlideAnimationId = @"KalSwitchMonths";

@interface KalGridView ()
{
    KalTileView*    _hitTile;
}

@property (nonatomic, strong) NSMutableArray *rangeTiles;
@property (nonatomic, strong) NSMutableArray *monthViews;

@end

@implementation KalGridView
{
    BOOL _needRemoveRanges;
}

- (KalTileView *)tileForDate:(NSDate *)date
{
    KalTileView* tile = nil;
    
    for(KalMonthView* monthView in self.monthViews)
    {
        tile = [monthView tileForDate:date];
        
        if(tile)    break;
    }
    return tile;
}

- (void)setMinAvailableDate:(NSDate *)minAvailableDate
{
    _minAvailableDate = minAvailableDate;
    
    for(KalMonthView* monthView in self.monthViews)
        [monthView updateStatesWithMinAvailableDate:_minAvailableDate maxAvailableDate:_maxAVailableDate];
}

- (void)setMaxAVailableDate:(NSDate *)maxAVailableDate
{
    _maxAVailableDate = maxAVailableDate;

    for(KalMonthView* monthView in self.monthViews)
        [monthView updateStatesWithMinAvailableDate:_minAvailableDate maxAvailableDate:_maxAVailableDate];
}

- (void)setBeginDate:(NSDate *)beginDate
{
    KalTileView *preTile = [self tileForDate:_beginDate];
    preTile.state = KalTileStateNone;
    _beginDate = beginDate;
    KalTileView *currentTile = [self tileForDate:_beginDate];
    currentTile.state = KalTileStateSelected;
    [self removeRanges];
}

- (void)setEndDate:(NSDate *)endDate
{
    KalTileView *beginTile = [self tileForDate:self.beginDate];
    
    KalTileView *preTile = [self tileForDate:_endDate];
    preTile.state = KalTileStateNone;
    _endDate = endDate;
    
    KalTileView *currentTile = [self tileForDate:_endDate];
    
    NSDate *realBeginDate;
    NSDate *realEndDate;
    
    [self removeRanges];
    
    if (!_endDate || [_endDate isEqualToDate:self.beginDate]) {
        return;
    } else if ([self.beginDate compare:self.endDate] == NSOrderedAscending) {
        realBeginDate = self.beginDate;
        realEndDate = self.endDate;
        beginTile.state = KalTileStateLeftEnd;
        currentTile.state = KalTileStateRightEnd;
    } else {
        realBeginDate = self.endDate;
        realEndDate = self.beginDate;
        beginTile.state = KalTileStateRightEnd;
        currentTile.state = KalTileStateLeftEnd;
    }
    
    NSInteger dayCount = [NSDate dayBetweenStartDate:realBeginDate endDate:realEndDate];
    for (int i=1; i<dayCount; i++) {
        NSDate *nextDay = [realBeginDate offsetDay:i];
        KalTileView *nextTile = [self tileForDate:nextDay];
        if (nextTile) {
            nextTile.state = KalTileStateInRange;
            [self.rangeTiles addObject:nextTile];
        }
    }
}

- (void)removeRanges
{
    if (_needRemoveRanges) {
        for (KalTileView *tile in self.rangeTiles) {
            tile.state = KalTileStateNone;
        }
        [self.rangeTiles removeAllObjects];
    }
}

- (id)initWithFrame:(CGRect)frame logic:(KalLogic *)theLogic delegate:(id<KalViewDelegate>)theDelegate
{
    if (self = [super initWithFrame:frame]) {
        _needRemoveRanges = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        logic = theLogic;
        delegate = theDelegate;
        
        CGRect monthRect = CGRectMake(0.f, 0.f, frame.size.width, frame.size.height);
        
        self.selectionMode = KalSelectionModeSingle;
        _rangeTiles = [[NSMutableArray alloc] init];
        
        self.visibleMonths = 12;
        _monthViews = [[NSMutableArray alloc] init];
        
        [self loadMonth:monthRect];
    }
    return self;
}

- (void)sizeToFit
{
    CGFloat height = 0;
    CGRect  frame = self.frame;
    
    for(KalMonthView* monthView in _monthViews)
        height += CGRectGetHeight(monthView.frame);

    NSLog(@"%@", NSStringFromCGRect(frame));
    self.contentSize = CGSizeMake( CGRectGetWidth(frame), height);
    self.height = CGRectGetHeight(self.frame);
}

#pragma mark -
#pragma mark Load Month Views

- (void)loadMonth:(CGRect)monthRect
{
    for(NSUInteger index = 0; index < self.visibleMonths; index++)
    {
        KalMonthView* monthView = [[KalMonthView alloc] initWithFrame:monthRect];

        [monthView showDates:logic.daysInSelectedMonth
            leadingAdjacentDates:logic.daysInFinalWeekOfPreviousMonth
           trailingAdjacentDates:logic.daysInFirstWeekOfFollowingMonth
                minAvailableDate:self.minAvailableDate
                maxAvailableDate:self.maxAVailableDate];
        
        [monthView sizeToFit];
        
        CGRect frame = monthView.frame;

        [self addSubview:monthView];
        
        [_monthViews addObject:monthView];
        
        monthRect = CGRectOffset(monthRect, 0, CGRectGetHeight(frame));
        [logic advanceToFollowingMonth];
    }
    self.beginDate = nil;

}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
   
    _hitTile = nil;
    
    if (!hitView)
        return;
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        if (tile.type & KalTileTypeDisable)
            return;
        
        _hitTile = tile;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if (!hitView)
        return;
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        if (tile.type & KalTileTypeDisable)
            return;
        
        if(_hitTile != tile)
            _hitTile = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        if (tile.type & KalTileTypeDisable)
            return;
        
        if(_hitTile != tile)
            return;
        
        NSDate *date = tile.date;

        if(self.beginDate  && self.endDate)
        {
            self.beginDate = nil;
            self.endDate = nil;
        }

        if(self.beginDate == nil) {
            self.beginDate = date;
        }
        else if(self.endDate == nil)
        {
            self.endDate = date;
        }
        
        NSDate *realBeginDate = self.beginDate;
        NSDate *realEndDate = self.endDate;
        if ([self.beginDate compare:self.endDate] == NSOrderedDescending) {
            realBeginDate = self.endDate;
            realEndDate = self.beginDate;
        }
        if ([(id)delegate respondsToSelector:@selector(didSelectBeginDate:endDate:)]) {
            [delegate didSelectBeginDate:realBeginDate endDate:realEndDate];
        }
    }
}

#pragma mark -

- (void)jumpToSelectedMonth
{
//    [self slide:SLIDE_NONE];
}

- (void)markTilesForDates:(NSArray *)dates
{
//    [frontMonthView markTilesForDates:dates];
}

#pragma mark -

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), self.contentSize.height);
}
@end
