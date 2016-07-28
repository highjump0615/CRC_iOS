//
//  EquipmentCell.h
//  CRC
//
//  Created by Jinhui Lee on 12/2/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, EquipmentCellState) {
    EquipmentCellStateReload = -1,
    EquipmentCellStateNone,
    EquipmentCellStateNormal,
    EquipmentCellStateHighlighted,
    EquipmentCellStateSelected,
    EquipmentCellStateCollapsed
};

@interface EquipmentCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)height;
+ (CGFloat)expandHeight;

@property(nonatomic, assign) EquipmentCellState state;

@property(nonatomic, weak)   NSURL*             imageURL;
@property(nonatomic, weak)   NSString*          information;
@property(nonatomic, weak)   NSString*          cost;

@end
