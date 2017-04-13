//
//  ShareForFriendsCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareForFriendsCell.h"
#import "JfgGlobal.h"
@implementation ShareForFriendsCell
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
    [self addSubview:self.iconImageView];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectButton.mas_right).offset(12);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(34, 40));
    }];
    [self addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(20);
        make.top.equalTo(@17);
        make.width.greaterThanOrEqualTo(@8);
        make.height.equalTo(@17);
    }];
    [self addSubview:self.shareNumLabel];
    [_shareNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(20);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
        make.width.greaterThanOrEqualTo(@21);
        make.height.equalTo(@14);
    }];
}
-(void)selectButtonAction:(UIButton *)sender{
    //sender.selected = !sender.selected;
    [self setSelected:sender.selected animated:YES];
    
}
-(BtnImageView *)selectButton{
    if (!_selectButton) {
        
        _selectButton = [[BtnImageView alloc]initWithImage:[UIImage imageNamed:@"camera_icon_Select"]];
//        [_selectButton setImage:[UIImage imageNamed:@"camera_icon_Select"] forState:UIControlStateNormal];
//        [_selectButton setImage:[UIImage imageNamed:@"camera_icon_Selected"] forState:UIControlStateSelected];
        //[_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //_selectButton.selected = NO;
    }
    return _selectButton;
}
-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        [_iconImageView setImage:[UIImage imageNamed:@"add_icon_camera"]];
    }
    return _iconImageView;
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        [_nameLabel setFont:[UIFont systemFontOfSize:17]];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"#333333"]];
    }
    return _nameLabel;
}
-(UILabel *)shareNumLabel{
    if (!_shareNumLabel) {
        _shareNumLabel = [[UILabel alloc]init];
        [_shareNumLabel setFont:[UIFont systemFontOfSize:14]];
        [_shareNumLabel setText:@"3/5"];
        [_shareNumLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
    }
    return _shareNumLabel;
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

@implementation BtnImageView

@end
