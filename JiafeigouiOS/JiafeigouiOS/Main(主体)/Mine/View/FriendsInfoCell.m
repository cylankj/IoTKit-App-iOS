//
//  FriendsInfoCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsInfoCell.h"
#import "JfgGlobal.h"

@implementation FriendsInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    [self addSubview:self.cusTextLabel];
    [self.cusTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15.0f);
        make.centerY.equalTo(self);
    }];
    
    [self addSubview:self.cusDetailLabel];
    [self.cusDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cusTextLabel.mas_right).with.offset(20.0f);
        make.right.equalTo(self).with.offset(-15.0f);
        make.centerY.equalTo(self);
    }];
    
//    [self addSubview:self.arrowImageView];
//    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self).with.offset(-15.0);
//        make.centerY.equalTo(self);
//    }];
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

- (UILabel *)cusDetailLabel
{
    if (_cusDetailLabel == nil)
    {
        _cusDetailLabel = [[UILabel alloc] init];
        _cusDetailLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _cusDetailLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _cusDetailLabel;
}

//- (UIImageView *)arrowImageView
//{
//    if (_arrowImageView == nil)
//    {
//        _arrowImageView = [[UIImageView alloc] init];
//        _arrowImageView.image = [UIImage imageNamed:@""];
//    }
//    return _arrowImageView;
//}

@end
