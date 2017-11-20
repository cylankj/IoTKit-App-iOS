//
//  FLTextView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/31.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FLTextView.h"

@implementation FLTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultParamsAndAddObserver];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultParamsAndAddObserver];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultParamsAndAddObserver];
    }
    return self;
}


-(void)defaultParamsAndAddObserver
{
    _placeholderFont = self.font?self.font:[UIFont systemFontOfSize:13];
    _placeholderColor = [UIColor grayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textChange:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.text.length > 0) { } else {
        NSDictionary *dictionary = @{NSFontAttributeName: _placeholderFont, NSForegroundColorAttributeName: _placeholderColor};
        
        CGPoint point = CGPointMake(4, 7);
        if (self.placeholderPoint) {
            point = [self.placeholderPoint CGPointValue];
        }
        
        [self.placeholder drawInRect:CGRectMake(point.x, point.y, self.bounds.size.width, self.bounds.size.height) withAttributes:dictionary];
        
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self setNeedsDisplay];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont;
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
