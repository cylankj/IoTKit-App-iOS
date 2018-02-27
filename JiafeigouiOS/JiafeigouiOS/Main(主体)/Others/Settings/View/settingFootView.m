//
//  settingFootView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "settingFootView.h"
#import "JfgGlobal.h"
#import "UIColor+FLExtension.h"

@implementation settingFootView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self initView];
}

- (UIButton *)deleteButton
{
    if (_deleteButton == nil)
    {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE_CID"] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"#ff3d32"] forState:UIControlStateNormal];
        
        [_deleteButton setTitleColor:[UIColor colorWithHex:0x9a9a9a alpha:0.5] forState:UIControlStateDisabled];
        [_deleteButton setBackgroundColor:[UIColor whiteColor]];
        // 射🐔 描边癖
        _deleteButton.layer.borderWidth = 0.5f;
        _deleteButton.layer.borderColor = [UIColor colorWithHexString:@"#e1e1e1"].CGColor;
    }
    
    return _deleteButton;
}

- (void)initView
{
    self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    [self addSubview:self.deleteButton];
    [self initViewLayout];
}


- (void)initViewLayout
{
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(@(0));
        make.top.equalTo(@(0));
        make.width.equalTo(@(Kwidth));
        make.height.equalTo(@44);
    }];
}


@end
