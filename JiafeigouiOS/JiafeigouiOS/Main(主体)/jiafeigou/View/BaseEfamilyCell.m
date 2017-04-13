//
//  BaseEfamilyCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseEfamilyCell.h"
#import "JfgGlobal.h"

@implementation BaseEfamilyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initBaseView];
        [self initBaseViewLayout];
    }
    
    return self;
}

- (void)initBaseView
{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.timeLabel];
    [self addSubview:self.headImageView];
    [self addSubview:self.bgImageView];
}

- (void)initBaseViewLayout
{
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20.0f);
        make.centerX.equalTo(self);
    }];
}

#pragma mark getter
- (UILabel *)timeLabel
{
    if (_timeLabel == nil)
    {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#adadad"];
    }
    return _timeLabel;
}

- (UIImageView *)headImageView
{
    if (_headImageView == nil)
    {
        _headImageView = [[UIImageView alloc] init];
    }
    return _headImageView;
}

- (UIImageView *)bgImageView
{
    if (_bgImageView == nil)
    {
        _bgImageView = [[UIImageView alloc] init];
        
    }
    
    return _bgImageView;
}

@end
