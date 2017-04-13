//
//  FriendsCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsMainCell.h"
#import "JfgGlobal.h"

@interface FriendsMainCell()
/**
 *  text 和 detailText 的背景view
 */
@property (nonatomic, strong) UIView *textBgView;

@end

@implementation FriendsMainCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self initView];
        [self initLayoutView];
    }
    
    return self;
}

- (void)initView
{
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.agreeButton];
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.textBgView];
    [self.textBgView addSubview:self.cusTextLabel];
    [self.textBgView addSubview:self.cusDetailTextLabel];
}

- (void)initLayoutView
{
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15.0);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(@50);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15.0f);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    [self.textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@38);
        make.right.equalTo(self.contentView).offset(0.0f);
        make.left.equalTo(self.headImageView.mas_right).offset(15.0f);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];

    [self.cusDetailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textBgView);
        make.bottom.equalTo(self.textBgView);
        make.right.equalTo(self.agreeButton.mas_left).offset(-15);
    }];
    
    [self.cusTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textBgView);
        make.top.equalTo(self.textBgView).offset(0.0f);
        make.right.equalTo(self.agreeButton.mas_left).offset(-15);
    }];
}


#pragma mark property
- (UIButton *)agreeButton
{
    if (_agreeButton == nil)
    {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Agree"] forState:UIControlStateNormal];
        [_agreeButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_agreeButton setBackgroundImage:[UIImage imageNamed:@"friends_agree"] forState:UIControlStateNormal];
        [_agreeButton setBackgroundImage:[UIImage imageNamed:@"friends_agree_press"] forState:UIControlStateHighlighted];
        [_agreeButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        _agreeButton.hidden = YES; // default YES
    }
    return _agreeButton;
}

- (UIImageView *)headImageView
{
    if(_headImageView == nil)
    {
        _headImageView = [[UIImageView alloc] init];
    }
    return _headImageView;
}

- (UILabel *)cusTextLabel
{
    if (_cusTextLabel == nil)
    {
        _cusTextLabel = [[UILabel alloc] init];
        _cusTextLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _cusTextLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _cusTextLabel;
}

- (UILabel *)cusDetailTextLabel
{
    if (_cusDetailTextLabel == nil)
    {
        _cusDetailTextLabel = [[UILabel alloc] init];
        _cusDetailTextLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _cusDetailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _cusDetailTextLabel;
}

- (UIView *)textBgView
{
    if (_textBgView == nil)
    {
        _textBgView = [[UIView alloc] init];
        _textBgView.backgroundColor = [UIColor clearColor];
        _textBgView.clipsToBounds = YES;
    }
    return _textBgView;
}

@end
