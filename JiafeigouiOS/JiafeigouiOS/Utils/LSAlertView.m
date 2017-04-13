//
//  LSAlertView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "LSAlertView.h"

#define ALERT_ALERT_COLOR  [UIColor whiteColor]
#define ALERT_WINDOW_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]
#define ALERT_TITLE_COLOR  [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]
#define ALERT_TITLE_FONT   [UIFont boldSystemFontOfSize:15]
#define ALERT_MSG_COLOR    [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]
#define ALERT_MSG_FONT     [UIFont systemFontOfSize:13]

#define ALERT_CANCELBTN_FONT       [UIFont boldSystemFontOfSize:15]
#define ALERT_CANCELBTN_FONT_COLOR [UIColor colorWithRed:75.0/255.0 green:159.0/255.0 blue:213.0/255.0 alpha:1.0]
#define ALERT_OTHERBTN_FONT        [UIFont systemFontOfSize:15]
#define ALERT_OTHERBTN_FONT_COLOR  [UIColor colorWithRed:75.0/255.0 green:159.0/255.0 blue:213.0/255.0 alpha:1.0]
#define ALERT_LINE_COLOR           [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]
#define CANCEL_BTN_TAG 678
#define OTHER_BTN_TAG  679
void (^CancelBlock) (void) = nil;
void (^OKBlock) (void) = nil;
@interface LSAlertView()
{
    
}
@property (nonatomic, strong) UIView   * background;
@property (nonatomic, strong) UIWindow * window;
@property (nonatomic, strong) UIView   * alertView;
@property (nonatomic, strong) UILabel  * titleLabel;
@property (nonatomic, strong) UILabel  * messageLabel;
@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UIButton * otherButton;
@property (nonatomic, strong) UIView   * hLine;
@property (nonatomic, strong) UIView   * vLine;
@property (nonatomic, assign) BOOL transformRotate;
@end
@implementation LSAlertView
-(instancetype)init{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)])
            self.window = [[UIApplication sharedApplication].delegate performSelector:@selector(window)];
        else self.window = [[UIApplication sharedApplication] keyWindow];
        _background = nil;
        _alertView = nil;
        _titleLabel = nil;
        _messageLabel = nil;
        _cancelButton = nil;
        _otherButton = nil;
        _hLine = nil;
        _vLine = nil;
        self.alpha = 0;
    }
    return self;
}

+ (LSAlertView *)shared{
    static dispatch_once_t once = 0;
    static LSAlertView * lsAlertView;
    dispatch_once(&once, ^{
        lsAlertView = [[LSAlertView alloc] init];
    });

    return lsAlertView;
}
- (void)alertShow
{
    if (self.alpha == 0)
    {
        self.alpha = 1.0;
        
        _alertView.alpha = 0;
        _alertView.transform = CGAffineTransformScale(_alertView.transform, 1.4, 1.4);
        
        if (self.transformRotate) {
            _alertView.transform = CGAffineTransformRotate(_alertView.transform, 90 * (M_PI / 180.0f));
        }
        
        
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            _alertView.transform = CGAffineTransformScale(_alertView.transform, 1/1.4, 1/1.4);
            _alertView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}
+ (void)disMiss {
    [[self shared] alertHide:nil];
}


- (void)alertHide:(UIButton *)sender {
    if (self.alpha == 1.0) {
        
        self.transformRotate = NO;
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            
            _alertView.transform = CGAffineTransformScale(_alertView.transform, 0.7, 0.7);
            _alertView.alpha = 0;
        } completion:^(BOOL finished)
         {
            if (sender.tag == CANCEL_BTN_TAG)
            {
                if (CancelBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (sender != nil)  //按钮 触发，不是按钮触发的 不执行Block块
                        {
                            CancelBlock();
                        }
                    });
                }
            }
            else
            {
                if (OKBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (sender != nil) //按钮 触发，不是按钮触发的 不执行Block块
                        {
                            OKBlock();
                        }
                    });
                    
                }
            }
             
             
             
            [self alertDestroy];
            self.alpha = 0;
        }];
    }
}
- (void)alertDestroy {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_titleLabel != nil) {
        
        [_titleLabel removeFromSuperview];		_titleLabel = nil;
    }
    if (_messageLabel != nil) {
        
        [_messageLabel removeFromSuperview];	_messageLabel = nil;
    }
    if (_alertView != nil) {
        
        [_alertView removeFromSuperview];	    _alertView = nil;
    }
    if (_cancelButton != nil) {
        
        [_cancelButton removeFromSuperview];	_cancelButton = nil;
    }
    if (_otherButton != nil) {
        
        [_otherButton removeFromSuperview];     _otherButton = nil;
    }
    if (_hLine !=nil) {
        
        [_hLine removeFromSuperview];           _hLine = nil;
    }
    if (_vLine !=nil) {
        
        [_vLine removeFromSuperview];           _vLine = nil;
    }
    [_background removeFromSuperview];	        _background = nil;
}

+ (void)showAlertForTransformRotateWithTitle:(NSString *)title Message:(NSString *)msg CancelButtonTitle:(NSString *)cancelTitle OtherButtonTitle:(NSString *)otherTitle CancelBlock:(void(^)(void))cancel OKBlock:(void(^)(void))ok
{
    [self shared].transformRotate = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shared]AlertWithTitle:title Message:msg Cancel:cancelTitle Other:otherTitle];
        
        CancelBlock = [cancel copy];
        OKBlock = [ok copy];
    });

}

+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)msg CancelButtonTitle:(NSString *)cancelTitle OtherButtonTitle:(NSString *)otherTitle CancelBlock:(void(^)(void))cancel OKBlock:(void(^)(void))ok {
    
    [self shared].transformRotate = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shared] AlertWithTitle:title Message:msg Cancel:cancelTitle Other:otherTitle];
        
        CancelBlock = [cancel copy];
        OKBlock = [ok copy];
    });
    
}
- (void)AlertWithTitle:(NSString *)title Message:(NSString *)msg Cancel:(NSString *)cancel Other:(NSString *)other {
    
    [self createAlertTitle:title==nil?NO:YES Message:msg==nil?NO:YES Cancel:cancel==nil?NO:YES Other:other==nil?NO:YES];
   
    _titleLabel.text = title;
    _messageLabel.text = msg;
    [_cancelButton setTitle:cancel forState:UIControlStateNormal];
    [_otherButton setTitle:other forState:UIControlStateNormal];
    
    [self alertSize];
    [self alertPosition:nil];
    [self alertShow];
}
- (void)createAlertTitle:(BOOL)title Message:(BOOL)msg Cancel:(BOOL)cancel Other:(BOOL)Other{
    
    if (_alertView == nil) {
        
        _alertView = [[UIView alloc]initWithFrame:CGRectZero];
        _alertView.backgroundColor =ALERT_ALERT_COLOR;
        _alertView.layer.cornerRadius = 10.0;
        _alertView.layer.masksToBounds = YES;
        [self registerNotifications];
    }
    if (_alertView.superview == nil) {
        
        _background = [[UIView alloc] initWithFrame:self.window.frame];
        _background.backgroundColor = ALERT_WINDOW_COLOR;
        [self.window addSubview:_background];
        [_background addSubview:_alertView];
    }
    if (title) {
        
        if (_titleLabel == nil) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _titleLabel.font = ALERT_TITLE_FONT;
            _titleLabel.textColor = ALERT_TITLE_COLOR;
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            _titleLabel.numberOfLines = 0;
        }
    }
    if (_titleLabel.superview == nil) [_alertView addSubview:_titleLabel];

    if (msg) {
        
        if (_messageLabel == nil) {
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _messageLabel.font = ALERT_MSG_FONT;
            _messageLabel.textColor = ALERT_MSG_COLOR;
            _messageLabel.backgroundColor = [UIColor clearColor];
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            _messageLabel.numberOfLines = 0;
        }
    }
    if (_messageLabel.superview == nil) [_alertView addSubview:_messageLabel];

    if (_hLine == nil) {
        _hLine = [[UIView alloc]init];
        _hLine.backgroundColor = ALERT_LINE_COLOR;
    }
    if (_hLine.superview == nil) [_alertView addSubview:_hLine];
    
    if (cancel && Other) {
        if (_vLine == nil) {
            _vLine = [[UIView alloc]init];
            _vLine.backgroundColor = ALERT_LINE_COLOR;
        }
        if (_vLine.superview == nil) [_alertView addSubview:_vLine];
    }
    if (cancel)
    {
        
        if (_cancelButton == nil) {
            
            _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_cancelButton.titleLabel setFont:ALERT_CANCELBTN_FONT];
            [_cancelButton setTitleColor:ALERT_CANCELBTN_FONT_COLOR forState:UIControlStateNormal];
            [_cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            _cancelButton.tag = CANCEL_BTN_TAG;
            [_cancelButton addTarget:self action:@selector(alertHide:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if (_cancelButton.superview == nil) [_alertView addSubview:_cancelButton];

    if (Other)
    {
        
        if (_otherButton == nil) {
            
            _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_otherButton.titleLabel setFont:ALERT_OTHERBTN_FONT];
            [_otherButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            _otherButton.tag = OTHER_BTN_TAG;
            [_otherButton setTitleColor:ALERT_OTHERBTN_FONT_COLOR forState:UIControlStateNormal];
            [_otherButton addTarget:self action:@selector(alertHide:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        if (_otherButton.superview != nil)
        {
            [_otherButton removeFromSuperview];
        }
        _otherButton = nil;
    }
    if (_otherButton.superview == nil && Other) [_alertView addSubview:_otherButton];
}
- (void)alertSize {
    //只需要调高不用调宽度
    CGRect titleLabelRect= CGRectZero;
    CGRect msgLabelRect = CGRectZero;
    CGRect cancelBtnRect = CGRectZero;
    CGRect otherBtnRect = CGRectZero;
    CGRect hLineRect = CGRectZero;
    CGRect vLineRect = CGRectZero;
    CGFloat alertWidth = 270, alertHeight = 105;
    CGFloat btnHeight = 44;
    CGFloat left = 30, right = 30,top = 25, bottom = 25;
    CGFloat lineHeight = 0.5;
    if (_titleLabel.text != nil) {
        
        NSDictionary *attributes = @{NSFontAttributeName:_titleLabel.font};
        NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        titleLabelRect = [_titleLabel.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
        
        titleLabelRect.origin.x = left;
        titleLabelRect.origin.y = top;
        titleLabelRect.size.width = alertWidth-left-right;
        alertHeight = titleLabelRect.size.height + top +bottom +btnHeight +0.5;
    }
    if (_messageLabel.text != nil) {
        
        NSDictionary *attributes = @{NSFontAttributeName:_messageLabel.font};
        NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        msgLabelRect = [_messageLabel.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
        msgLabelRect.size.width = alertWidth-left-right;
        
        if (_titleLabel.text != nil) {
      
            msgLabelRect.origin.x = left;
            msgLabelRect.origin.y = top+titleLabelRect.size.height+8;
            alertHeight = alertHeight + msgLabelRect.size.height;
        }else{
            
            msgLabelRect.origin.x = left;
            msgLabelRect.origin.y = top;
            alertHeight = msgLabelRect.size.height + top +bottom +btnHeight +0.5;
        }
    }
    hLineRect = CGRectMake(0, alertHeight-btnHeight-lineHeight, alertWidth, lineHeight);
    cancelBtnRect.origin.y = otherBtnRect.origin.y = alertHeight-btnHeight;
    cancelBtnRect.size.height = otherBtnRect.size.height = btnHeight;
    if (_cancelButton != nil && _otherButton != nil) {
        
        cancelBtnRect.origin.x = 0;
        cancelBtnRect.size.width = otherBtnRect.size.width = (alertWidth-lineHeight)*0.5;
        otherBtnRect.origin.x = (alertWidth-lineHeight)*0.5+lineHeight;
        vLineRect = CGRectMake((alertWidth-lineHeight)*0.5, alertHeight-btnHeight, lineHeight, btnHeight);
    }else if(_otherButton == nil){
        
        cancelBtnRect.origin.x = 0;
        cancelBtnRect.size.width = alertWidth;
    }else{
        
        otherBtnRect.origin.x = 0;
        otherBtnRect.size.width = alertWidth;
    }

    _alertView.bounds = CGRectMake(0, 0, alertWidth, alertHeight);
    _titleLabel.frame = titleLabelRect;
    _messageLabel.frame = msgLabelRect;
    _cancelButton.frame = cancelBtnRect;
    _otherButton.frame = otherBtnRect;
    _hLine.frame = hLineRect;
    _vLine.frame = vLineRect;
}
- (void)alertPosition:(NSNotification *)notification {
    
    CGFloat heightKeyboard = 0;
    NSTimeInterval duration = 0;
    if (notification != nil) {
        
        NSDictionary *info = [notification userInfo];
        CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if ((notification.name == UIKeyboardWillShowNotification) || (notification.name == UIKeyboardDidShowNotification)) {
            
            heightKeyboard = keyboard.size.height;
        }
    }else heightKeyboard = [self keyboardHeight];

    CGRect screen = [UIScreen mainScreen].bounds;
    CGPoint center = CGPointMake(screen.size.width/2, (screen.size.height-heightKeyboard)/2);

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _alertView.center = CGPointMake(center.x, center.y);
    } completion:nil];

    if (_background != nil) _background.frame = _window.frame;
}
- (CGFloat)keyboardHeight{
    
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]){
        
        if ([[testWindow class] isEqual:[UIWindow class]] == NO){
            
            for (UIView *possibleKeyboard in [testWindow subviews]){
                
                if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]){
                    
                    return possibleKeyboard.bounds.size.height;
                    
                } else if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"]){
                    
                    for (UIView *hostKeyboard in [possibleKeyboard subviews]){
                        
                        if ([[hostKeyboard description] hasPrefix:@"<UIInputSetHost"]){
                            
                            return hostKeyboard.frame.size.height;
                        }
                    }
                }
            }
        }
    }
    return 0;
}
- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertPosition:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertPosition:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertPosition:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertPosition:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertPosition:) name:UIKeyboardDidShowNotification object:nil];
}
@end
