//
//  CartCell.h
//  CRC
//
//  Created by Jinhui Lee on 12/18/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)height;

@property(nonatomic, weak)      NSURL*             imageURL;
@property(nonatomic, weak)      NSString*          information;
@property(nonatomic, assign)    NSInteger          count;

@end
