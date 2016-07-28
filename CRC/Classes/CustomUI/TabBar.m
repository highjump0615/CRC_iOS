//
//  Toolbar.m
//  CRC
//
//  Created by Jinhui Lee on 11/30/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "Tabbar.h"
#import "EquipmentCell.h"

#define TABBAR_HEIGHT   56

#define BADGE_ITEM_SIZE 8
////////////////////////////////////////////////////////
// UIToolBar Category
////////////////////////////////////////////////////////
@interface UITabBar (NewSize)
- (CGSize)sizeThatFits:(CGSize)size;
@end

@implementation UITabBar (NewSize)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(size.width, TABBAR_HEIGHT);
    return newSize;
}
@end


////////////////////////////////////////////////////////
// CircleLabel
////////////////////////////////////////////////////////
@interface CircleLabel : UILabel

@property (nonatomic, assign) NSInteger     cartCount;
@property (nonatomic, assign) CGPoint       ptCenter;
@end

@implementation CircleLabel
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = RGBCOLOR(190, 30, 45);
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        self.cartCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UpdateCart:)
                                                     name:kEquipmentUpdateCartNotification object:nil];
        
        self.hidden = YES;
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)UpdateCart:(NSNotification*)notification
{
    NSNumber* count = (NSNumber*)[notification object];
    
    self.cartCount = [count integerValue];
}

-  (void)setCartCount:(NSInteger)cartCount
{
    _cartCount = cartCount;
    
    if(_cartCount == 0)
        self.hidden = YES;
    else
    {
        NSString* strCount = [NSString stringWithFormat:@"%ld", (long)self.cartCount];

        CGFloat width = BADGE_ITEM_SIZE*(2 + strCount.length -1);
        
        self.frame = CGRectMake(self.ptCenter.x - width/2, self.ptCenter.y - BADGE_ITEM_SIZE, width, BADGE_ITEM_SIZE*2);
        self.text = strCount;
        
        self.hidden = NO;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // setup mask
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGPathRef   path = nil;
    
    CGRect  bounds  = self.bounds;

    if(CGSizeEqualToSize(bounds.size, CGSizeZero))
        return;
    
    path = CGPathCreateWithRoundedRect(bounds, BADGE_ITEM_SIZE, BADGE_ITEM_SIZE, NULL);
    maskLayer.path = path;
    CGPathRelease(path);
    
    self.layer.mask = maskLayer;
}

@end

////////////////////////////////////////////////////////
// TabBar
////////////////////////////////////////////////////////
@interface TabBar () <UITabBarControllerDelegate>
{
    CircleLabel* _circleText;
}

@end

@implementation TabBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self sizeThatFits:CGSizeMake(0, 144)];
        
        [[UITabBar appearance] setTintColor:kForeColor];
        [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
        
        _circleText = [[CircleLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_circleText];
        [self sendSubviewToBack:_circleText];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(_circleText )
    {
        _circleText.ptCenter = CGPointMake(CGRectGetWidth(self.frame)*3/8+20, 12);
    }
}

+ (CGFloat)height
{
    return TABBAR_HEIGHT;
}

#pragma mark - UITabBar delegate

//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    
//    NSArray *tabViewControllers = tabBarController.viewControllers;
//    UIView * fromView = tabBarController.selectedViewController.view;
//    UIView * toView = viewController.view;
//    if (fromView == toView)
//        return NO;
//    NSUInteger fromIndex = [tabViewControllers indexOfObject:tabBarController.selectedViewController];
//    NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];
//    
//    [UIView transitionFromView:fromView
//                        toView:toView
//                      duration:0.6
//                       options: toIndex > fromIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
//                    completion:^(BOOL finished) {
//                        if (finished) {
//                            tabBarController.selectedIndex = toIndex;
//                        }
//                    }];
//    [UIView commitAnimations];
//    
//    return YES;
//}

@end
