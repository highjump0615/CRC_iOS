/*
 * Copyright (c) 2014 Jinhui Lee
 */

#import <UIKit/UIKit.h>

typedef enum {
    KalTileTypeRegular   = 0,
    KalTileTypeAdjacent  = 1 << 0,
    KalTileTypeToday     = 1 << 1,
    KalTileTypeFirst     = 1 << 2,
    KalTileTypeLast      = 1 << 3,
    KalTileTypeDisable   = 1 << 4,
    KalTileTypeMarked    = 1 << 5,
} KalTileType;

typedef enum {
    KalTileStateNone = 0,
    KalTileStateSelected,
    KalTileStateHighlighted,
    KalTileStateInRange,
    KalTileStateLeftEnd,
    KalTileStateRightEnd,
} KalTileState;

@interface KalTileView : UIView
{
    CGPoint origin;
}

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) KalTileState state;
@property (nonatomic, assign) KalTileType type;
@property (nonatomic, getter = isMarked) BOOL marked;
@property (nonatomic, getter = isToday) BOOL today;
@property (nonatomic, getter = isFirst) BOOL first;
@property (nonatomic, getter = isLast) BOOL last;

- (void)resetState;
- (BOOL)isToday;
- (BOOL)isFirst;
- (BOOL)isLast;
- (BOOL)isDisable;
- (BOOL)belongsToAdjacentMonth;

@end
