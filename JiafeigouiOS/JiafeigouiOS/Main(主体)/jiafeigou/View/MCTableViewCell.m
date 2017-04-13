//
//  MCTableViewCell.m
//  JiafeigouIOS
//
//  Created by Michiko on 15/12/16.
//  Copyright © 2015年 liao tian. All rights reserved.
//

#import "MCTableViewCell.h"
#import "FLGlobal.h"
#import "Masonry.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
@implementation MCTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.dotImageView];
        [_dotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@-2);
            make.left.equalTo(@118);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_dotImageView.mas_centerX);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
            make.width.equalTo(@3);
        }];
        
        [self.contentView addSubview:self.dateLabel];
        
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
            make.right.mas_equalTo(_dotImageView.mas_left).offset(-11);
            make.width.mas_greaterThanOrEqualTo(@80);
            make.height.equalTo(@18);
        }];
        [self.contentView addSubview:self.timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_dotImageView.mas_right).offset(11);
            make.centerY.mas_equalTo(_dotImageView.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(@68);
            make.height.equalTo(@17);
        }];
        [self.contentView addSubview:self.stateLabel];
        [_stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_timeLabel.mas_right).offset(11);
            make.centerY.mas_equalTo(_timeLabel.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(@34);
            make.height.equalTo(@17);
        }];
    }
    return self;
}
-(void)setDateLabelText:(NSString *)string{
    //解决重用引起的划线不均匀问题
    [self.line setNeedsDisplay];
    
    if (string ==nil){
        self.dateLabel.attributedText =nil;
        return;
    }
    
    NSInteger length =[string length];
    
    if (length >2) {
        NSMutableAttributedString *attrString =[[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} range:NSMakeRange(0, 3)];

        [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} range:NSMakeRange(3, 2)];
        [attrString addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#333333"]} range:NSMakeRange(0, 3)];
        [attrString addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#666666"]} range:NSMakeRange(3, 2)];
        
        self.dateLabel.attributedText =attrString;
    }else if (length ==2){
        NSMutableAttributedString *attrString =[[NSMutableAttributedString alloc] initWithString:string];
    
        [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} range:NSMakeRange(0, length)];
        [attrString addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#333333"]} range:NSMakeRange(0, length)];
        
        self.dateLabel.attributedText =attrString;
    }
    
}
-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dateLabel;
}
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _timeLabel.font = [UIFont systemFontOfSize:17];
    }
    return _timeLabel;
}
-(lineView *)line{
    if (!_line) {
        _line = [[lineView alloc]init];
        _line.backgroundColor = [UIColor whiteColor];
        //_line.endPoint = CGPointMake(1, self.frame.size.height);
    }
    return _line;
}
-(UIImageView *)dotImageView{
    if (!_dotImageView) {
        _dotImageView = [[UIImageView alloc]init];
        [_dotImageView setImage:[UIImage imageNamed:@"magnetic_history"]];
    }
    return _dotImageView;
}
-(UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc]init];
        _stateLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _stateLabel.font = [UIFont systemFontOfSize:17];
    }
    return _stateLabel;
}
@end
