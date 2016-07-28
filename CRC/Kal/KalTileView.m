/*
 * Copyright (c) 2014 Jinhui Lee
 */

#import "KalTileView.h"
#import "KalPrivate.h"
#import <CoreText/CoreText.h>

extern const CGSize kTileSize;

@implementation KalTileView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        origin = frame.origin;
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityTraits:UIAccessibilityTraitButton];
        [self resetState];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat fontSize = 17;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    UIColor *textColor = nil;
    CGSize tileSize = self.frame.size;
    CGRect bounds = self.bounds;

    if (self.isDisable) {
        [RGBCOLOR(230, 230, 230) setFill];
        CGContextFillRect(ctx, bounds);
        textColor = kGrayColor;
    }else {
        [[UIColor whiteColor] setFill];
        CGContextFillRect(ctx, bounds);
        textColor = kDarkGrayColor;
    }
    
    if (self.state == KalTileStateHighlighted || self.state == KalTileStateSelected) {
        [kForeColor setFill];
        CGContextFillRect(ctx, bounds);
        textColor = [UIColor whiteColor];
    } else if (self.state == KalTileStateLeftEnd || self.state == KalTileStateRightEnd) {
        [kForeColor setFill];
        CGContextFillRect(ctx, bounds);
        textColor = [UIColor whiteColor];
    } else if (self.state == KalTileStateInRange) {
        [kSelectColor setFill];
        CGContextFillRect(ctx, bounds);
        textColor = [UIColor whiteColor];
    }
    
    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    //    if (self.isToday)
    //        dayText = NSLocalizedString(@"Today", @"");
    CGSize textSize = [dayText sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat textX, textY;
    textX = roundf(0.5f * (tileSize.width - textSize.width));
    textY = roundf(0.5f * (tileSize.height - textSize.height));
    [dayText drawAtPoint:CGPointMake(textX, textY) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:textColor}];
    if (self.isToday) {
        [textColor setFill];
        CGContextFillEllipseInRect(ctx, CGRectMake((CGRectGetWidth(bounds)-6.f)/2, CGRectGetHeight(bounds)-6.f, 4.f, 4.f));
    }
}

- (void)resetState
{
    self.date = nil;
    _type = KalTileTypeRegular;
    self.state = KalTileStateNone;
}

- (void)setDate:(NSDate *)aDate
{
    if (_date == aDate)
        return;
    
    _date = aDate;
    
    [self setNeedsDisplay];
}

- (void)setState:(KalTileState)state
{
    if (_state != state) {
        _state = state;
        [self setNeedsDisplay];
    }
}

- (void)setType:(KalTileType)tileType
{
    if (_type != tileType) {
        _type = tileType;
        
        if(_type & KalTileTypeAdjacent ||
           _type & KalTileTypeFirst)
        {
            if(!(_type & KalTileTypeDisable))
                _type |= KalTileTypeDisable;
        }
        [self setNeedsDisplay];
    }
}

- (BOOL)isToday { return self.type & KalTileTypeToday; }
- (BOOL)isFirst { return self.type & KalTileTypeFirst; }
- (BOOL)isLast { return self.type & KalTileTypeLast; }
- (BOOL)isDisable { return self.type & KalTileTypeDisable; }
- (BOOL)isMarked { return self.type & KalTileTypeMarked; }

- (BOOL)belongsToAdjacentMonth { return self.type & KalTileTypeAdjacent; }

@end
