//
//  SwipeView.h
//  CRC
//
//  Created by Jinhui Lee on 12/20/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TouchView : UIView
@property (nonatomic, strong) UIView* parentView;
@end


@interface SwipeView : UIView

@property (nonatomic, strong) UIView            *contentView;
@property (nonatomic, strong) NSMutableArray    *filters;

@property (nonatomic, strong) UIView            *touchView;

- (NSArray*)searchFilter;
- (void)swipe:(BOOL)expand;

- (BOOL)isExpanded;

@end
