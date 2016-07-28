/* 
 * Copyright (c) 2014 Jinhui Lee
 */

#import <UIKit/UIKit.h>
#import "KalView.h"       // for the KalViewDelegate protocol
#import "KalDataSource.h" // for the KalDataSourceCallbacks protocol

@class KalLogic;

/*
 *    KalViewController
 *    ------------------------
 *
 *  KalViewController automatically creates both the calendar view
 *  and the events table view for you. The only thing you need to provide
 *  is a KalDataSource so that the calendar system knows which days to
 *  mark with a dot and which events to list under the calendar when a certain
 *  date is selected (just like in Apple's calendar app).
 *
 */
@interface KalViewController : UIViewController <KalViewDelegate, KalDataSourceCallbacks>
{
  KalLogic *logic;
  id <UITableViewDelegate> __unsafe_unretained delegate;
  id <KalDataSource> __unsafe_unretained dataSource;
}

@property (nonatomic, unsafe_unretained) id<UITableViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<KalDataSource> dataSource;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) KalSelectionMode* selectionMode;
@property (nonatomic, strong) NSDate *minAvailableDate;
@property (nonatomic, strong) NSDate *maxAVailableDate;

- (id)initWithFrame:(CGRect)frame withSelectionMode:(KalSelectionMode)selectionMode;
- (void)reloadData;                                 // If you change the KalDataSource after the KalViewController has already been displayed to the user, you must call this method in order for the view to reflect the new data.
- (void)showAndSelectDate:(NSDate *)date;           // Updates the state of the calendar to display the specified date's month and selects the tile for that date.

@end
