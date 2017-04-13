//
//  TextFieldView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TextFieldView.h"
#import "JfgGlobal.h"

@implementation TextFieldView

-(void)didMoveToSuperview
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor colorWithHexString:@"#e1e1e1"].CGColor;
    self.layer.borderWidth = 0.5f;
    
    [self initView];
}

- (void)initView
{
    [self addSubview:self.textField];
}

#pragma mark property
- (UITextField *)textField
{
    if (_textField == nil)
    {
        CGFloat widgetWidth = Kwidth - 15.0f;
        CGFloat widgetHeight = 16;
        CGFloat widgetX = 15.0f;
        CGFloat widgetY = (self.height - widgetHeight)*0.5;
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _textField.font = [UIFont systemFontOfSize:widgetHeight];
        _textField.textColor = [UIColor colorWithHexString:@"#cecece"];
        
    }
    return _textField;
}

@end
