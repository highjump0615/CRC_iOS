//
//  UITableView+PlaceholderColor.m
//  Cove
//
//  Created by Umair Aamir on 4/7/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "UITextField+PlaceholderColor.h"

@implementation UITextField (PlaceholderColor)

-(void)setPlaceholderColor:(UIColor*)color
{
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 6)
    {
        [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
    }
    else
    {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
}

-(void)setLeftPadding:(CGFloat)leftPadding
{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftPadding, leftPadding)];
    self.leftViewMode = UITextFieldViewModeAlways;
    [self setLeftView:leftView];
}

@end
