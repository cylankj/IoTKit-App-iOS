//
//  ShareManagerCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareManagerCell.h"
#import "JfgGlobal.h"
@implementation ShareManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

-(void)initView{
    [self addSubview:self.cancelShareBtn];
    [_cancelShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(70, 28));
    }];
    [self addSubview:self.headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [self addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(15);
        make.top.equalTo(@17);
        make.right.mas_equalTo(self.cancelShareBtn.mas_left).offset(-15);
        make.height.equalTo(@16);
    }];
    [self addSubview:self.phoneNumLabel];
    [_phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(15);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(7);
        make.right.mas_equalTo(self.cancelShareBtn.mas_left).offset(-15);
        make.height.equalTo(@16);
    }];
}
-(UIImageView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc]init];
        _headerImageView.layer.cornerRadius = 45/2.0;
        _headerImageView.layer.masksToBounds = YES;
    }
    return _headerImageView;
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        [_nameLabel setFont:[UIFont systemFontOfSize:16]];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"#333333"]];
    }
    return _nameLabel;
}
-(UILabel *)phoneNumLabel{
    if (!_phoneNumLabel) {
        _phoneNumLabel = [[UILabel alloc]init];
        [_phoneNumLabel setFont:[UIFont systemFontOfSize:14]];
        [_phoneNumLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
    }
    return _phoneNumLabel;
}
-(UIButton *)cancelShareBtn{
    if (!_cancelShareBtn) {
        _cancelShareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelShareBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Delete"] forState:UIControlStateNormal];
        [_cancelShareBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _cancelShareBtn.layer.cornerRadius = 4;
        _cancelShareBtn.layer.borderWidth = 0.5;
        _cancelShareBtn.layer.borderColor = [UIColor colorWithHexString:@"#4b9fd5"].CGColor;
        [_cancelShareBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"]forState:UIControlStateNormal];
    }
    return _cancelShareBtn;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
