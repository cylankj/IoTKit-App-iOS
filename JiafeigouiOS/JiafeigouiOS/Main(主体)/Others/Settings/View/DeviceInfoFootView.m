//
//  DeviceInfoFootView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceInfoFootView.h"
#import "JfgGlobal.h"


@implementation DeviceInfoFootView


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
    [self addSubview:self.footLabel];
    [self initViewLayout];
}

- (void)initViewLayout
{
    [self.footLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(8.0);
        make.left.equalTo(self).with.offset(15);
        make.width.equalTo(@(footLabelWidth));
    }];
}

#pragma mark getter
- (UILabel *)footLabel
{
    if (_footLabel == nil)
    {
        _footLabel = [[UILabel alloc] init];
        _footLabel.numberOfLines = 0;
        _footLabel.font = [UIFont systemFontOfSize:14.0f];
        _footLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    }
    
    return _footLabel;
}

@end
