//
//  DeviceWifiCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceWifiCell.h"
#import "JfgGlobal.h"

@implementation DeviceWifiCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initView];
        [self initViewLayout];
    }
    
    return self;
}

- (void)initView
{
    [self.contentView addSubview:self.signalImageView];
    [self.contentView addSubview:self.lockImageView];
    [self.contentView addSubview:self.cusTextLabel];
    [self.contentView addSubview:self.cusImageView];
}

- (void)initViewLayout
{
    [self.signalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right);
        make.size.mas_equalTo(CGSizeMake(16.f, 12.f));
    }];
    
    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.signalImageView.mas_left).offset(-10.f);
        make.size.mas_equalTo(CGSizeMake(8.f, 12.f));
    }];
    
    [self.cusTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(44.0f);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.cusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15.0f);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}
- (void)setIsHiddenImage:(BOOL)isHiddenImage {
    _isHiddenImage = isHiddenImage;
    if (_isHiddenImage) {
        [self.cusImageView setHidden: YES];
    } else {
        [self.cusImageView setHidden: NO];
    }
}
#pragma mark getter
- (UIImageView *)signalImageView
{
    if (_signalImageView == nil)
    {
        _signalImageView = [[UIImageView alloc] init];
        _signalImageView.image = [UIImage imageNamed:@"wifi_signal_1"];
    }
    
    return _signalImageView;
}

- (UIImageView *)lockImageView
{
    if (_lockImageView == nil)
    {
        _lockImageView = [[UIImageView alloc] init];
        _lockImageView.image = [UIImage imageNamed:@"wifi_lock"];
    }
    return _lockImageView;
}

- (UILabel *)cusTextLabel
{
    if (_cusTextLabel == nil)
    {
        _cusTextLabel = [[UILabel alloc] init];
    }
    return _cusTextLabel;
}

- (UIImageView *)cusImageView
{
    if (_cusImageView == nil)
    {
        _cusImageView = [[UIImageView alloc] init];
    }
    return _cusImageView;
}

@end
