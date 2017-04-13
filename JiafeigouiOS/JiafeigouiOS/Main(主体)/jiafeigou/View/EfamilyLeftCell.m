//
//  EfamilyLeftCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyLeftCell.h"
#import "JfgGlobal.h"

@implementation EfamilyLeftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
    self.bgImageView.image = [[UIImage imageNamed:@"efamily_cellbg"] stretchableImageWithLeftCapWidth:50 topCapHeight:0];
    self.headImageView.image = [UIImage imageNamed:@"efamily_cell_lefthead"];
    self.headImageView.bounds = CGRectMake(0, 0, 40, 40);
    
    [self.bgImageView addSubview:self.iconImageView];
    [self.bgImageView addSubview:self.contentsLabel];
    [self addSubview:self.nickNameLabel];
}

- (void)initViewLayout
{
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView).with.offset(20.0f);
        make.centerY.equalTo(self.bgImageView);
    }];
    
    [self.contentsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(8);
        make.right.equalTo(self.bgImageView.mas_right).with.offset(-8);
        make.centerY.equalTo(self.bgImageView);
    }];
    
    [self.nickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(15.0f);
        make.left.equalTo(self.headImageView.mas_right).with.offset(19.0f);
    }];
    
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10.0f);
        make.top.equalTo(self).offset(60.0f);
    }];
    
    
    [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).with.offset(5.0f);
        make.top.equalTo(self.nickNameLabel.mas_bottom).with.offset(7.0f);
        make.width.mas_lessThanOrEqualTo(@(Kwidth - 65.0f));
    }];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView).with.offset(20.0f);
        make.centerY.equalTo(self.bgImageView);
    }];
    
}


#pragma mark  getter
- (UIImageView *)iconImageView
{
    if (_iconImageView == nil)
    {
        _iconImageView = [[UIImageView alloc] init];
        
    }
    return _iconImageView;
}

- (UILabel *)contentsLabel
{
    if (_contentsLabel == nil)
    {
        _contentsLabel = [[UILabel alloc] init];
        _contentsLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _contentsLabel;
}

- (UILabel *)nickNameLabel
{
    if (_nickNameLabel == nil)
    {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _nickNameLabel;
}

@end
