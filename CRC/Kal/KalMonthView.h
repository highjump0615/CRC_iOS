/* 
 * Copyright (c) 2014 Jinhui Lee
 */

#import <UIKit/UIKit.h>

@class KalTileView;

@interface KalMonthView : UIView
{
  NSUInteger numWeeks;
  NSDateFormatter *tileAccessibilityFormatter;
}

@property (nonatomic) NSUInteger numWeeks;

- (id)initWithFrame:(CGRect)rect; // designated initializer
- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *) trailingAdjacentDates minAvailableDate:(NSDate *)minAvailableDate maxAvailableDate:(NSDate *)maxAvailableDate;
- (KalTileView *)firstTileOfMonth;
- (KalTileView *)tileForDate:(NSDate *)date;
- (void)markTilesForDates:(NSArray *)dates;
- (void)updateStatesWithMinAvailableDate:(NSDate *)minAvailableDate maxAvailableDate:(NSDate *)maxAvailableDate;

@end
