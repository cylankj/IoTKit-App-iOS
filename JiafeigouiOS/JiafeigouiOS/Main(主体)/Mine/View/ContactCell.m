//
//  ContactCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ContactCell.h"
#import "JfgGlobal.h"
@implementation ContactCell

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
    [self addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@17);
        make.width.greaterThanOrEqualTo(@8);
        make.height.equalTo(@17);
    }];
    [self addSubview:self.phoneLabel];
    [_phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
        make.width.greaterThanOrEqualTo(@77);
        make.height.equalTo(@15);
    }];
    [self addSubview:self.shareButton];
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(50, 28));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        [_nameLabel setFont:[UIFont systemFontOfSize:16]];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"#333333"]];
    }
    return _nameLabel;
}
-(UILabel *)phoneLabel{
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc]init];
        [_phoneLabel setFont:[UIFont systemFontOfSize:14]];
        [_phoneLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
    }
    return _phoneLabel;
}
-(ContactBtn *)shareButton{
    if (!_shareButton) {
        _shareButton = [ContactBtn buttonWithType:UIButtonTypeCustom];
        [_shareButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_shareButton setBackgroundColor:[UIColor clearColor]];
    }
    return _shareButton;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation ContactBtn

@end
