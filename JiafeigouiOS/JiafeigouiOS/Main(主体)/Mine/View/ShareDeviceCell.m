//
//  ShareDeviceCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareDeviceCell.h"
#import <Masonry.h>
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
@interface ShareDeviceCell()

@end
@implementation ShareDeviceCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        
    }
    return self;
}

-(void)initView
{
    
    [self addSubview:self.shareButton];
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(50, 28));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.iconImageView];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@19);
        make.size.mas_equalTo(CGSizeMake(34, 40));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    [self addSubview:self.deviceNameLabel];
    [_deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(19);
        make.top.mas_equalTo(self.iconImageView.mas_top);
        make.right.mas_equalTo(self.shareButton.mas_left).offset(-15);
        make.height.equalTo(@19);
    }];
    
    [self addSubview:self.deviceNumLabel];
    [_deviceNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deviceNameLabel.mas_bottom).offset(8);
        make.left.mas_equalTo(self.deviceNameLabel.mas_left);
        make.width.greaterThanOrEqualTo(@21);
        make.height.equalTo(@14);
    }];
    
   
}
-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
    }
    return _iconImageView;
}

-(UILabel *)deviceNameLabel{
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc]init];
        [_deviceNameLabel setFont:[UIFont systemFontOfSize:17]];
        [_deviceNameLabel setTextColor:[UIColor colorWithHexString:@"#333333"]];
    }
    return _deviceNameLabel;
}
-(UILabel *)deviceNumLabel{
    if (!_deviceNumLabel) {
        _deviceNumLabel = [[UILabel alloc]init];
        [_deviceNumLabel setFont:[UIFont systemFontOfSize:14]];
        [_deviceNumLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
    }
    return _deviceNumLabel;
}
-(UIButton *)shareButton{
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"] forState:UIControlStateNormal];
        _shareButton.showsTouchWhenHighlighted = NO;
        [_shareButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _shareButton.layer.cornerRadius = 4;
        _shareButton.layer.borderWidth = 0.5;
        [_shareButton setBackgroundColor:[UIColor clearColor]];
    }
    return _shareButton;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
