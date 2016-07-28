//
//  InfoView.h
//  CRC
//
//  Created by Jinhui Lee on 12/1/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, InfoViewStyle) {
    InfoViewStyleLocation,
    InfoViewStyleURL,
    InfoViewStyleMail,
    InfoViewStylePhone,
    InfoViewStyleTime,
    InfoViewStyleInfo
};

@interface InfoView : UIButton

- (instancetype)initWithFrame:(CGRect)frame withStyle:(InfoViewStyle)style
                    withTitle:(NSString*)title withDescription:(NSString*)description;

- (void)setUserData:(id)userData;

@end
