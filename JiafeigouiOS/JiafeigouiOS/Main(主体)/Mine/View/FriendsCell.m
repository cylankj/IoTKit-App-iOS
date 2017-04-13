//
//  FriendsCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsCell.h"
#import "JfgGlobal.h"
@interface FriendsCell()

@end
@implementation FriendsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

-(void)initView{
    [self addSubview:self.selectButton];
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [self addSubview:self.headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectButton.mas_right).offset(15);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [self addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(15);
        make.top.equalTo(@17);
        make.width.greaterThanOrEqualTo(@8);
        make.height.equalTo(@16);
    }];
    [self addSubview:self.phoneNumLabel];
    [_phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(15);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(7);
        make.width.greaterThanOrEqualTo(@77);
        make.height.equalTo(@16);
    }];
}
-(void)selectButtonAction:(UIButton *)sender{
    //sender.selected = !sender.selected;
    [self setSelected:sender.selected animated:YES];
}
-(UIImageView *)selectButton{
    if (!_selectButton) {
        _selectButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"camera_icon_Select"]];
    }
    return _selectButton;
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
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
