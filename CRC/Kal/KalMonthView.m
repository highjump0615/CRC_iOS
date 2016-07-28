/*
 * Copyright (c) 2014 Jinhui Lee
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalPrivate.h"

extern const CGSize kTileSize;

#define kMonthHeight    28

@interface KalMonthView ()
{
    BOOL        _bDrawTop;
    BOOL        _bDrawBottom;
    
    NSUInteger  _year;
    NSUInteger  _month;
    
    NSString* _strMonth;
}
@end

@implementation KalMonthView

@synthesize numWeeks;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        CGSize fTileSize = kTileSize;
        fTileSize.width = CGRectGetWidth(frame)/7;
        
        tileAccessibilityFormatter = [[NSDateFormatter alloc] init];
        [tileAccessibilityFormatter setDateFormat:@"EEEE, MMMM d"];
        self.opaque = NO;
        self.clipsToBounds = YES;
        
        for (int i=0; i<6; i++) {
            for (int j=0; j<7; j++) {
                CGRect r = CGRectMake(j*fTileSize.width, kMonthHeight + i*fTileSize.height, fTileSize.width, fTileSize.height);
                [self addSubview:[[KalTileView alloc] initWithFrame:r]];
            }
        }
    }
    return self;
}

- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *) trailingAdjacentDates minAvailableDate:(NSDate *)minAvailableDate maxAvailableDate:(NSDate *)maxAvailableDate
{
    int tileNum = 0;
    NSArray *dates[] = { leadingAdjacentDates, mainDates, trailingAdjacentDates };
    NSMutableArray* removeArray = [[NSMutableArray alloc] initWithArray:self.subviews];
    
    for (int i=0; i<3; i++) {
        for (int j=0; j<dates[i].count; j++) {
            NSDate *d = dates[i][j];
            KalTileView *tile = [self.subviews objectAtIndex:tileNum];
            [tile resetState];
            tile.date = d;
            if ((minAvailableDate && [d compare:minAvailableDate] == NSOrderedAscending) || (maxAvailableDate && [d compare:maxAvailableDate] == NSOrderedDescending)) {
                tile.type = KalTileTypeDisable;
            }
            if (i == 0 && j == 0) {
                tile.type |= KalTileTypeFirst;
            }
            if (i == 2 && j == dates[i].count-1) {
                tile.type |= KalTileTypeLast;
            }
            if (dates[i] != mainDates) {
                tile.type |= KalTileTypeAdjacent;
            }
            if ([d isToday]) {
                tile.type |= KalTileTypeToday;
            }
            tileNum++;
            
            if(!(tile.type & KalTileTypeFirst ||
               tile.type & KalTileTypeAdjacent))
                [removeArray removeObject:tile];
        }
    }

    tileNum -= removeArray.count;
    for(KalTileView* tile in removeArray)
    {
        [tile removeFromSuperview];
    }
    
    
    [self updateStatesWithMinAvailableDate:minAvailableDate maxAvailableDate:maxAvailableDate];
    
    _year       = [mainDates[0] year];
    _month      = [mainDates[0] month];
    
    _strMonth = [mainDates[0] monthString];
    
    if([self firstTileOfMonth].top > kMonthHeight)
    {
        for(KalTileView* tile in self.subviews)
            tile.frame = CGRectOffset(tile.frame, 0, -CGRectGetHeight(tile.frame));
    }

    [self sizeToFit];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    bounds.size.height = kMonthHeight;

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [RGBCOLOR(246, 246, 246) setFill];
    CGContextFillRect(ctx, bounds);
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    CGSize textSize = [_strMonth sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat textX, textY;
    textX = roundf(10);
    textY = roundf(0.5f * (bounds.size.height - textSize.height));
    [_strMonth drawAtPoint:CGPointMake(textX, textY) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:kForeColor}];

    // draw tile
    [RGBCOLOR(230, 230, 230) setFill];
    if(_bDrawTop)
        CGContextFillRect(ctx, CGRectMake(0, kMonthHeight, CGRectGetWidth(bounds), kTileSize.height));
    if(_bDrawBottom)
        CGContextFillRect(ctx, CGRectMake(0, CGRectGetHeight(self.bounds) - kTileSize.height, CGRectGetWidth(bounds), kTileSize.height));
}

- (KalTileView *)firstTileOfMonth
{
    KalTileView *tile = nil;
    for (KalTileView *t in self.subviews) {
        if (!t.belongsToAdjacentMonth) {
            tile = t;
            break;
        }
    }
    
    return tile;
}

- (KalTileView *)tileForDate:(NSDate *)date
{
    if(date.year != _year || date.month != _month)
        return nil;
    
    KalTileView *tile = nil;
    for (KalTileView *t in self.subviews) {
        if ([t.date isEqualToDate:date]) {
            tile = t;
            break;
        }
    }
    return tile;
}

- (void)sizeToFit
{
    self.height = kMonthHeight + kTileSize.height * numWeeks;
}

- (void)markTilesForDates:(NSArray *)dates
{
    for (KalTileView *tile in self.subviews)
    {
        if ([dates containsObject:tile.date]) { tile.type |= KalTileTypeMarked; }
        NSString *dayString = [tileAccessibilityFormatter stringFromDate:tile.date];
        if (dayString) {
            NSMutableString *helperText = [[NSMutableString alloc] initWithCapacity:128];
            if ([tile.date isToday])
                [helperText appendFormat:@"%@ ", NSLocalizedString(@"Today", @"Accessibility text for a day tile that represents today")];
            [helperText appendString:dayString];
            if (tile.marked)
                [helperText appendFormat:@". %@", NSLocalizedString(@"Marked", @"Accessibility text for a day tile which is marked with a small dot")];
            [tile setAccessibilityLabel:helperText];
        }
    }
}

- (void)updateStatesWithMinAvailableDate:(NSDate *)minAvailableDate maxAvailableDate:(NSDate *)maxAvailableDate
{
    KalTileView* firstTile = nil;
    KalTileView* lastTile = nil;
    
    for(KalTileView* tile in self.subviews)
    {
        if(firstTile == nil)
            firstTile = tile;
        lastTile = tile;
        if ((minAvailableDate && [tile.date compare:minAvailableDate] == NSOrderedAscending) || (maxAvailableDate && [tile.date compare:maxAvailableDate] == NSOrderedDescending))
            tile.type = KalTileTypeDisable;
    }
    
    if(firstTile.type == KalTileTypeDisable)
        _bDrawTop = YES;
    if(lastTile.type == KalTileTypeDisable)
        _bDrawBottom = YES;
    
    numWeeks = ceilf((lastTile.top - firstTile.top) / kTileSize.height) + 1;
}

#pragma mark -


@end
