//
//  SearchBar.m
//  CRC
//
//  Created by Jinhui Lee on 12/17/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "SearchBar.h"

#define CANCEL_BUTTON_WIDTH     60

#define X_MARGIN                8
#define DEFAULT_SIZE            16

@interface BackView : UIView
@end

@implementation BackView
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *aPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8.0];
    [[UIColor whiteColor] setFill];
    [aPath fill];
}
@end


@interface SearchBar () {
    BOOL _bInit;
}

@property (nonatomic, strong) BackView *backView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation SearchBar

@synthesize backView=_backView, textField=_textField, cancelButton=_cancelButton, closeButton=_closeButton, delegate, placeHolder=_placeHolder, text=_text;

+ (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initControl];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    self.backgroundColor = [UIColor clearColor];
    
    [self setPlaceHolder:@"Search Equipment"];
    [self setSearchIcon:@"search_icon"];
    [self setCancelButtonTitle:@"Cancel" forState:UIControlStateNormal];
    
    _bInit = YES;
}

-(UITextField *)textField
{
    if (!_textField)
    {
        _backView = [[BackView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backView];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectInset(_backView.frame, X_MARGIN, 0)];
        _textField.delegate = self;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.font = [UIFont systemFontOfSize:20.f];

        [self createCloseButton];
        
        [self addSubview:self.textField];
        [_textField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }
    
    return _textField;
}

- (void)layoutSubviews
{
    if(_bInit)
    {
        _bInit = NO;
        
        _backView.frame = self.bounds;
        
        _textField.frame = CGRectInset(_backView.frame, X_MARGIN, 0);
        
        if(_cancelButton)
        {
            _cancelButton.frame = CGRectMake(self.frame.size.width,
                                             0,
                                             CANCEL_BUTTON_WIDTH, self.frame.size.height);
        }

        if(_closeButton)
        {
            _closeButton.frame = CGRectMake(self.frame.size.width - DEFAULT_SIZE,
                                            (self.frame.size.height - DEFAULT_SIZE)/2,
                                            DEFAULT_SIZE,
                                            DEFAULT_SIZE);
        }
        
        // setup mask
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        CGPathRef   path = nil;
        
        path = CGPathCreateWithRect(self.bounds, NULL);
        maskLayer.path = path;
        
        CGPathRelease(path);
        
        self.layer.mask = maskLayer;
    }
}

- (UIButton *)cancelButton
{
    if (!_cancelButton)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(self.frame.size.width,
                                         0,
                                         CANCEL_BUTTON_WIDTH, self.frame.size.height);
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateHighlighted];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
        
        [self addSubview:_cancelButton];
        
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonHandler)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(void)createCloseButton
{
    if (!_closeButton)
    {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];

        _closeButton.frame = CGRectMake(self.frame.size.width - DEFAULT_SIZE,
                                        (self.frame.size.height - DEFAULT_SIZE)/2,
                                        DEFAULT_SIZE,
                                        DEFAULT_SIZE);
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        
        [_closeButton setImage:[UIImage imageNamed:@"close_normal"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"close_select"] forState:UIControlStateHighlighted];
        [_closeButton setImage:[SearchBar imageWithColor:[UIColor clearColor] andHeight:1.0] forState:UIControlStateDisabled];
        
        [_closeButton setEnabled:NO];
        
        [_closeButton addTarget:self
                          action:@selector(closeButtonHandler)
                forControlEvents:UIControlEventTouchUpInside];
        
        self.textField.rightView = _closeButton;
        
        self.textField.rightViewMode = UITextFieldViewModeAlways;
    }
}

-(BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}

-(void)setCancelButtonTitle:(NSString *)title forState:(UIControlState)state
{
    [self.cancelButton setTitle:title forState:state];
}

-(void)setCancelButtonTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [self.cancelButton setTitleColor:color forState:state];
}

-(void)setCancelButtonTintColor:(UIColor *)color
{
    [self.cancelButton setTintColor:color];
}

-(void)setCancelButtonBackgroundColor:(UIColor *)color
{
    [self.cancelButton setBackgroundColor:color];
}

-(void)setText:(NSString *)text
{
    self.textField.text = text;
}

-(NSString *)text
{
    return self.textField.text;
}

-(void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    self.textField.placeholder = placeHolder;
}

-(void)setPlaceHolderColor:(UIColor*)color
{
    NSAssert(!self.placeHolder, @"Please set placeholder before setting placeholdercolor");
    [self.textField setPlaceholderColor:color];
}

-(NSString *)placeHolder
{
    return _placeHolder;
}

-(void)setAutoCapitalizationMode:(UITextAutocapitalizationType)type
{
    self.textField.autocapitalizationType = type;
}

-(void)setSearchIcon:(NSString *)icon
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_SIZE, DEFAULT_SIZE)];
    [imageView setImage:[UIImage imageNamed:icon]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textField.leftView = imageView;
    
    self.textField.leftViewMode = UITextFieldViewModeAlways;
}

-(void)setShowsCancelButton:(BOOL)show animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self setShowsCancelButton:show];
        }];
    } else {
        [self setShowsCancelButton:show];
    }
}

-(void)setShowsCancelButton:(BOOL)show
{
    if (show)
    {
        _keepFocus = NO;
        
        CGRect frame = self.cancelButton.frame;
        frame.origin.x = self.frame.size.width - 60;
        self.cancelButton.frame = frame;
        
        frame = self.backView.frame;
        frame.size.width = self.bounds.size.width - 70;
        self.backView.frame = frame;
        self.textField.frame = CGRectInset(frame, X_MARGIN, 0);
    }
    else if(_keepFocus == NO)
    {
        CGRect frame = self.cancelButton.frame;
        frame.origin.x = self.frame.size.width;
        self.cancelButton.frame = frame;
        
        frame = self.backView.frame;
        frame.size.width = self.bounds.size.width;
        self.backView.frame = frame;
        self.textField.frame = CGRectInset(frame, X_MARGIN, 0);
    }
}

-(void)cancelButtonHandler
{
    _keepFocus = NO;
    
    self.textField.text = @"";
    [self setShowsCancelButton:NO animated:YES];
    [self.textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

-(void)closeButtonHandler
{
    if(self.textField.text.length == 0)
        return;
    
    self.textField.text = @"";
    [_closeButton setEnabled:NO];

    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:@""];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)])
    {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.text.length > 0)
        [_closeButton setEnabled:YES];
    else
        [_closeButton setEnabled:NO];

    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
    {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)])
    {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    
    [_closeButton setEnabled:NO];

    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)])
    {
        [self.delegate searchBarTextDidEndEditing:self];
    }
}
-(void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 0)
        [_closeButton setEnabled:YES];
    else
        [_closeButton setEnabled:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)])
    {
        return [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:@""];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    [self setShowsCancelButton:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
    {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}

@end
