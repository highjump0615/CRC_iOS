/* 
 * Copyright (c) 2014 Jinhui Lee
 */

#import <UIKit/UIKit.h>

typedef enum {
    KalSelectionModeSingle = 0,
    KalSelectionModeRange,
} KalSelectionMode;

@class KalTileView, KalMonthView, KalLogic;
@protocol KalViewDelegate;

/*
 *    KalGridView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalView).
 *
 */
@interface KalGridView : UIScrollView
{
  id<KalViewDelegate> __weak delegate;  // Assigned.
  KalLogic *logic;
}

@property (nonatomic, assign) BOOL transitioning;

@property (nonatomic, assign) NSUInteger visibleMonths;

@property (nonatomic, assign) KalSelectionMode selectionMode;
@property (nonatomic, strong) NSDate *minAvailableDate;
@property (nonatomic, strong) NSDate *maxAVailableDate;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;

- (id)initWithFrame:(CGRect)frame logic:(KalLogic *)logic delegate:(id<KalViewDelegate>)delegate;
- (void)markTilesForDates:(NSArray *)dates;

// These 3 methods should be called *after* the KalLogic
// has moved to the previous or following month.
- (void)jumpToSelectedMonth;    // see comment on KalView

@end
