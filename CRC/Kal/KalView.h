/* 
 * Copyright (c) 2014 Jinhui Lee
 */

#import <UIKit/UIKit.h>
#import "KalGridView.h"

@class KalLogic;
@protocol KalViewDelegate, KalDataSourceCallbacks;

/*
 *    KalView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalViewController).
 *
 *  KalViewController uses KalView as its view.
 *  KalView defines a view hierarchy that looks like the following:
 *
 *       +-----------------------------------------+
 *       |                header view              |
 *       +-----------------------------------------+
 *       |                                         |
 *       |                                         |
 *       |                 grid view               |
 *       |           (the calendar scroll)         |
 *       |                                         |
 *       |                                         |
 *       +-----------------------------------------+
 *
 */
@interface KalView : UIView
{
  UILabel *headerTitleLabel;
  KalLogic *logic;
}

@property (nonatomic, weak) id<KalViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KalGridView *gridView;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)delegate logic:(KalLogic *)logic;
- (BOOL)isSliding;
- (void)markTilesForDates:(NSArray *)dates;
- (void)redrawEntireMonth;

- (void)jumpToSelectedMonth;    // change months without animation (i.e. when directly switching to "Today")

@end

#pragma mark -

@protocol KalViewDelegate

@optional

- (void)didSelectDate:(NSDate *)date;
- (void)didSelectBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;

@end
