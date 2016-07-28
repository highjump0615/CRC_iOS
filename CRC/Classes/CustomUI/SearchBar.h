//
//  SearchBar.h
//  CRC
//
//  Created by Jinhui Lee on 12/17/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+PlaceholderColor.h"

@protocol SearchBarDelegate;


@interface SearchBar : UIView <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet id<SearchBarDelegate> delegate;

@property (nonatomic, assign) BOOL  keepFocus;

@property (nonatomic, strong) NSString *placeHolder;

@property (nonatomic, strong) NSString *text;

// user can set his own search icon
-(void)setSearchIcon:(NSString *)icon;
// show cancel button animated
-(void)setShowsCancelButton:(BOOL)show;
-(void)setShowsCancelButton:(BOOL)show animated:(BOOL)animated;
// chance cancel button title color
-(void)setCancelButtonTitleColor:(UIColor *)color forState:(UIControlState)state;
// change cancel button color
-(void)setCancelButtonTintColor:(UIColor *)color;
-(void)setCancelButtonBackgroundColor:(UIColor *)color;
// change captilization mode
-(void)setAutoCapitalizationMode:(UITextAutocapitalizationType)type;
// can change placeholder color
-(void)setPlaceHolderColor:(UIColor*)color;
// change cancel button title
-(void)setCancelButtonTitle:(NSString *)title forState:(UIControlState)state;

@end



@protocol SearchBarDelegate <NSObject>


@optional

- (BOOL)searchBarShouldBeginEditing:(SearchBar *)searchBar;                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar;                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(SearchBar *)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar;                       // called when text ends editing
- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)searchBar:(SearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; // called before text changes

- (void)searchBarSearchButtonClicked:(SearchBar *)searchBar;                     // called when keyboard search button pressed
- (void)searchBarBookmarkButtonClicked:(SearchBar *)searchBar;                   // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(SearchBar *) searchBar;                    // called when cancel button pressed

@end
