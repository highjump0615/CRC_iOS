/*
 * Copyright (c) 2014 Jinhui Lee
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

@interface KalView ()

- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;

@end

static const CGFloat kHeaderHeight = 68.f;

@implementation KalView

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
    if ((self = [super initWithFrame:frame])) {
        self.delegate = theDelegate;
        logic = theLogic;
        [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = RGBCOLOR(246, 246, 246);
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, kHeaderHeight)];
        [self addSubviewsToHeaderView:headerView];
        [self addSubview:headerView];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, frame.size.width, frame.size.height - kHeaderHeight)];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubviewsToContentView:contentView];
        [self addSubview:contentView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
    return nil;
}

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
    CGRect frame = CGRectOffset(self.bounds, 0, 38);
    const CGFloat tileWidth = CGRectGetWidth(self.bounds) / 7.f;

    frame.size.height = 30;
    UIView* weekView = [[UIView alloc] initWithFrame:frame];
    weekView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:weekView];
    
    // Draw the selected month name centered and at the top of the view
    headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 200, 30)];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    headerTitleLabel.textAlignment = NSTextAlignmentLeft;
    headerTitleLabel.textColor = kGrayColor;
    [self setHeaderTitleText:@"Dates required"];
    [headerView addSubview:headerTitleLabel];
    
    // Add column labels for each weekday (adjusting based on the current locale's first weekday)
    NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    NSArray *fullWeekdayNames = [[[NSDateFormatter alloc] init] standaloneWeekdaySymbols];
    NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
    NSUInteger i = firstWeekday - 1;
    for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += tileWidth, i = (i+1)%7) {
        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, tileWidth, kHeaderHeight - 15.f);
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
        weekdayLabel.backgroundColor = [UIColor clearColor];
        weekdayLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.textColor = kForeColor;
        weekdayLabel.text = [weekdayNames objectAtIndex:i];
        [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
        [headerView addSubview:weekdayLabel];
    }
}

- (void)addSubviewsToContentView:(UIView *)contentView
{
    // Both the tile grid and the list of events will automatically lay themselves
    // out to fit the # of weeks in the currently displayed month.
    // So the only part of the frame that we need to specify is the width.
    CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, self.height-kHeaderHeight);
    
    // The tile grid (the calendar body)
    self.gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:self.delegate];
    [self.gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [contentView addSubview:self.gridView];
    
    // Trigger the initial KVO update to finish the contentView layout
    [self.gridView sizeToFit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.gridView && [keyPath isEqualToString:@"frame"]) {
        
        /* Animate tableView filling the remaining space after the
         * gridView expanded or contracted to fit the # of weeks
         * for the month that is being displayed.
         *
         * This observer method will be called when gridView's height
         * changes, which we know to occur inside a Core Animation
         * transaction. Hence, when I set the "frame" property on
         * tableView here, I do not need to wrap it in a
         * [UIView beginAnimations:context:].
         */
        CGFloat gridBottom = self.gridView.top + self.gridView.height;
        CGRect frame = self.tableView.frame;
        frame.origin.y = gridBottom;
        frame.size.height = self.tableView.superview.height - gridBottom;
        self.tableView.frame = frame;
        
    } else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"]) {
//        [self setHeaderTitleText:[change objectForKey:NSKeyValueChangeNewKey]];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setHeaderTitleText:(NSString *)text
{
    [headerTitleLabel setText:text];
}

- (void)jumpToSelectedMonth { [self.gridView jumpToSelectedMonth]; }

- (BOOL)isSliding { return self.gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates { [self.gridView markTilesForDates:dates]; }

- (void)dealloc
{
    [logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
    
    [self.gridView removeObserver:self forKeyPath:@"frame"];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) - kHeaderHeight);
    [self.gridView setFrame:frame];
}
@end
