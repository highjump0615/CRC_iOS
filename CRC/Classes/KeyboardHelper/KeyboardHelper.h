//
//  KeyboardHelper.h
//  KeyboardHelperDemo
//
//  Created by Shaikh Sonny Aman on 7/23/12.
//  Copyright (c) 2012 XappLab!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^t_KeyboardHelperOnDone)(void);

@interface KeyboardHelper : NSObject{
	float statusBarHeight;
	BOOL enabled;
}

@property (nonatomic, assign) id<UITextViewDelegate> textViewDelegate;
@property (nonatomic, assign) id<UITextFieldDelegate> textFieldDelegate;


- (id) initWithViewController:(UIViewController*)viewController;
- (id) initWithViewController:(UIViewController*)viewController onDoneSelector:(SEL)done;
- (id) initWithViewController:(UIViewController*)viewController onDoneAction:(t_KeyboardHelperOnDone)onDone;
- (void) setInputView:(UIView*)view;
- (void) enable;
- (void) disable;
- (void) reload;
@end
