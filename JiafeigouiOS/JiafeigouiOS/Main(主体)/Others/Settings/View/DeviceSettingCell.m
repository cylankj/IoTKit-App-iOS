//
//  DeviceSettingCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceSettingCell.h"
#import "FLGlobal.h"
@implementation DeviceSettingCell

- (void)dealloc
{
    NSLog(@"DeviceSettingCell dealloc");
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
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
        [self addSubview:self.cusImageVIew];
        [self addSubview:self.cusLabel];
        [self addSubview:self.settingSwitch];
        [self addSubview:self.cusDetailLabel];
        [self initViewLayout];
    }
    
    return self;
}
- (UIImageView *)cusImageVIew {
    if (!_cusImageVIew) {
        _cusImageVIew = [[UIImageView alloc]init];
        
    }
    return _cusImageVIew;
}
- (UILabel *)cusLabel {
    if (!_cusLabel) {
        _cusLabel = [[UILabel alloc]init];
        _cusLabel.textColor = MainTextColor;
        _cusLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _cusLabel;
}
- (JFGSettingSwitch *)settingSwitch
{
    if (_settingSwitch == nil)
    {
        _settingSwitch = [[JFGSettingSwitch alloc] init];
        _settingSwitch.hidden = YES; //默认隐藏
    }
    return _settingSwitch;
}

- (UILabel *)cusDetailLabel
{
    if (_cusDetailLabel == nil)
    {
        _cusDetailLabel = [[UILabel alloc] init];
        _cusDetailLabel.textColor = self.detailTextLabel.textColor;
        _cusDetailLabel.textAlignment = NSTextAlignmentRight;
        _cusDetailLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    return _cusDetailLabel;
}

- (void)initViewLayout
{
    JFG_WS(weakSelf);
    
    [self.cusImageVIew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    [self.cusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.cusImageVIew.mas_right).offset(10);
        make.centerY.equalTo(weakSelf.mas_centerY);
//        make.width.lessThanOrEqualTo(@(135*designWscale));
        make.right.equalTo(weakSelf.cusDetailLabel.mas_left).with.offset(-15.0);
    }];
    
    [self.settingSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_right).offset(-15.0f);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    
    [self.cusDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_right).with.offset(-30.0f);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.width.lessThanOrEqualTo(@(138*designWscale));
    }];
    
    
}

- (void)layoutAgain
{
    JFG_WS(weakSelf);
    
    if (self.cusImageVIew.image == nil)
    {
        self.cusImageVIew.hidden = YES;
        [self.cusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.mas_left).offset(10);
//            make.width.lessThanOrEqualTo(@(180*designWscale));
            make.right.equalTo(weakSelf.cusDetailLabel.mas_left).with.offset(-30.0);
        }];
    }
    else
    {
        self.cusImageVIew.hidden =NO;
        [self.cusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.cusImageVIew.mas_right).offset(10);
//            make.width.lessThanOrEqualTo(@(135*designWscale));
            make.right.equalTo(weakSelf.cusDetailLabel.mas_left).with.offset(-30.0);
        }];
    }
    
    if(self.redDot.hidden == NO)
    {
        [self.cusDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.mas_right).with.offset(-44.0);
            
        }];
        
        [self.redDot mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.mas_right).with.offset(-20.0f);
        }];
    }
    else
    {
        [self.cusDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.mas_right).with.offset(-30.0f);
            make.centerY.equalTo(weakSelf.mas_centerY);
            make.width.lessThanOrEqualTo(@(138*designWscale));
        }];
    }
    
    if (self.settingSwitch.hidden == NO)
    {
        [self.redDot mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.cusLabel.mas_right).with.offset(5);
            make.centerY.equalTo(weakSelf.mas_centerY);
        }];
    }
}

- (void)setCanClickCell:(BOOL)canClickCell
{
    self.settingSwitch.enabled = canClickCell;
    self.cusLabel.alpha = canClickCell?1.0:0.6;
    self.cusDetailLabel.alpha = canClickCell?1.0:0.6;
    self.userInteractionEnabled = canClickCell;
}


@end

@implementation JFGSettingSwitch

@end
