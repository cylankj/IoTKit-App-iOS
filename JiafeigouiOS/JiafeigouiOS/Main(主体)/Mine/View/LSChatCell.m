//
//  LSChatCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "LSChatCell.h"
#import "JfgGlobal.h"
#import "LSChatModel.h"



@implementation LSChatCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
        self.bubbleSelf.titleLabel.numberOfLines = 0;
        self.bubbleOther.titleLabel.numberOfLines = 0;
    }
    return self;
}

-(void)initView{
    [self.contentView addSubview:self.timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@12);
    }];
    [self.contentView addSubview:self.headerImageSelf];
    [_headerImageSelf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.contentView addSubview:self.bubbleSelf];
    [_bubbleSelf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.headerImageSelf.mas_left).offset(-4);
        make.top.mas_equalTo(self.headerImageSelf.mas_top).offset(10);
        make.width.greaterThanOrEqualTo(@41.5);
        make.width.lessThanOrEqualTo(@(250*designHscale));
        make.height.greaterThanOrEqualTo(@41.5);
    }];
    [self.contentView addSubview:self.headerImageOther];
    [_headerImageOther mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.contentView addSubview:self.bubbleOther];
    [_bubbleOther mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageOther.mas_right).offset(4);
        make.top.mas_equalTo(self.headerImageOther.mas_top).offset(10);
        make.width.greaterThanOrEqualTo(@41.5);
        make.width.lessThanOrEqualTo(@(250*designWscale));
        make.height.greaterThanOrEqualTo(@41.5);
    }];
        
}
- (void)setModel:(LSChatModel *)model{
    _model = model;
    if (!model.enableDateLabel) {
        self.timeLabel.hidden = YES;
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@0);
        }];
    }else{
        self.timeLabel.text = model.msgDate;
        self.timeLabel.hidden = NO;
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@12);
        }];
    }
    
    switch (model.modelType) {
        case LSModelTypeMe:
            [self setShowBtn:self.bubbleSelf WithShowImage:self.headerImageSelf WithHideBtn:self.bubbleOther WithHideImage:self.headerImageOther];
            break;
        case LSModelTypeOther:
            [self setShowBtn:self.bubbleOther WithShowImage:self.headerImageOther WithHideBtn:self.bubbleSelf WithHideImage:self.headerImageSelf];
            break;
    }
}
- (void)setShowBtn:(UIButton *)showBtn WithShowImage:(UIImageView *)showImage WithHideBtn:(UIButton *)hideBtn WithHideImage:(UIImageView *)hideImage
{
    [showBtn setTitle:self.model.msg forState:UIControlStateNormal];
    // 隐藏其他
    hideBtn.hidden = YES;
    hideImage.hidden = YES;
    // 显示自己
    showBtn.hidden = NO;
    showImage.hidden = NO;
    
    // 强制更新
    [self layoutIfNeeded];
    // 更新约束，设置按钮的高度就是titleLable的高度
    [showBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat buttonH = showBtn.titleLabel.frame.size.height;//
        make.height.mas_equalTo(buttonH+20);
    }];
    // 强制更新
    [self layoutIfNeeded];
    CGFloat btnMaxY = CGRectGetMaxY(showBtn.frame);
    CGFloat imageMaxY = CGRectGetMaxY(showImage.frame);
    // 设置cell高度
    self.model.cellHeight = MAX(btnMaxY, imageMaxY) + 10;
}
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, self.model.cellHeight);
}
#pragma mark 构造方法
+ (instancetype)tableCellWithTableView :(UITableView *)tableView
{
    LSChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"talk"];
    if(!cell){
        cell = [[LSChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"talk"];
    }
    return cell;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#adadad"];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}
-(UIImageView *)headerImageSelf{
    if (!_headerImageSelf) {
        _headerImageSelf = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"image_defaultHead"]];
        _headerImageSelf.layer.cornerRadius = 20;
        _headerImageSelf.layer.masksToBounds = YES;
    }
    return _headerImageSelf;
}
-(UIImageView *)headerImageOther{
    if (!_headerImageOther) {
        _headerImageOther = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"help_jfg80"]];
        _headerImageOther.layer.cornerRadius = 20;
        _headerImageOther.layer.masksToBounds = YES;
    }
    return _headerImageOther;
}
-(UIButton *)bubbleSelf{
    if (!_bubbleSelf) {
        _bubbleSelf = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bubbleSelf setBackgroundImage:[UIImage imageNamed:@"efamily_cellbg_bule"] forState:UIControlStateNormal];
        [_bubbleSelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bubbleSelf.titleLabel.font = [UIFont systemFontOfSize:15];
        _bubbleSelf.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_bubbleSelf setContentEdgeInsets:UIEdgeInsetsMake(15, 10, 15, 15)];
    }
    return _bubbleSelf;
}
-(UIButton *)bubbleOther{
    if (!_bubbleOther) {
        _bubbleOther = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bubbleOther setBackgroundImage:[UIImage imageNamed:@"efamily_cellbg"] forState:UIControlStateNormal];
        [_bubbleOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _bubbleOther.titleLabel.font = [UIFont systemFontOfSize:15];
        _bubbleOther.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_bubbleOther setContentEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 10)];
    }
    return _bubbleOther;
}
@end
