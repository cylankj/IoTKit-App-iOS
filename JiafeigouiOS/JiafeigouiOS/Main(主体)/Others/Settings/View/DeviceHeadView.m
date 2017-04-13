//
//  DeviceHeadView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceHeadView.h"
#import "JfgGlobal.h"

@implementation DeviceHeadView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}


- (void)initView
{
    [self addSubview:self.headLabel];
    [self initViewLayout];
}

- (void)initViewLayout
{
    [self.headLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-8.0);
        make.left.equalTo(self).with.offset(15);
        make.width.equalTo(@(headLabelWidth));
    }];
}

#pragma mark getter
- (UILabel *)headLabel
{
    if (_headLabel == nil)
    {
        _headLabel = [[UILabel alloc] init];
        _headLabel.numberOfLines = 0;
        _headLabel.font = [UIFont systemFontOfSize:13.0f];
        _headLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    }
    
    return _headLabel;
}

@end
