//
//  EfamilyRightCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyRightCell.h"
#import "JfgGlobal.h"

@implementation EfamilyRightCell

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
    self.bgImageView.image = [[UIImage imageNamed:@"efamily_cellbg_bule"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    self.headImageView.image = [UIImage imageNamed:@"efamily_cell_righthead"];
    
    [self.bgImageView addSubview:self.iconImageView];
    [self.bgImageView addSubview:self.contentsLabel];
}

- (void)initViewLayout
{
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView).with.offset(15.0f);
        make.centerY.equalTo(self.bgImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(15.0f, 15.0f));
    }];
    
    [self.contentsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(5.0f);
        make.right.equalTo(self.bgImageView).with.offset(-20.0f);
        make.centerY.equalTo(self.iconImageView);
    }];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10.0f);
        make.top.equalTo(self.contentView).offset(53.0f);
        make.size.mas_equalTo(CGSizeMake(40.0f, 40.0f));
    }];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headImageView.mas_left).with.offset(-5.0f);
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(15.0f);
        make.width.mas_lessThanOrEqualTo(@(Kwidth - 70.0f));
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
        _contentsLabel.textColor = [UIColor whiteColor];
    }
    return _contentsLabel;
}

@end
