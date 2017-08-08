//
//  jiafeigouTableViewCell.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "jiafeigouTableViewCell.h"
#import "UIView+FLExtensionForFrame.h"
#import "NSObject+FBKVOController.h"
#import "UIColor+FLExtension.h"
#import "FLGlobal.h"
#import "JfgLanguage.h"
@interface jiafeigouTableViewCell()

@property (nonatomic,strong)UILabel *lineLabel;

@end


@implementation jiafeigouTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.unreadRedPoint.layer.cornerRadius = 5;
    self.unreadRedPoint.layer.masksToBounds = YES;
    [self.contentView addSubview:self.shareImageView];
    //[self.contentView addSubview:self.lineLabel];
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.deviceNickLabel keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        //根据昵称文字设置分享图标位置
        CGSize size = [weakSelf.deviceNickLabel sizeThatFits:CGSizeMake(weakSelf.width-22-85, 20)];
        weakSelf.shareImageView.left = weakSelf.deviceNickLabel.left+size.width+7;
    }];
    
    // Initialization code
}

-(UIImageView *)shareImageView
{
    if (!_shareImageView) {
        _shareImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 16)];
        _shareImageView.image = [UIImage imageNamed:@"icon_share_bg"];
        UILabel *tit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, 16)];
        tit.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"];
        tit.textAlignment = NSTextAlignmentCenter;
        tit.font = [UIFont systemFontOfSize:10];
        tit.textColor = [UIColor colorWithRed:87/255.0 green:199/255.0 blue:166/255.0 alpha:1];
        [_shareImageView addSubview:tit];
        _shareImageView.hidden = YES;
        _shareImageView.y = self.deviceNickLabel.y;
    }
    return _shareImageView;
}

-(UILabel *)lineLabel
{
    if (!_lineLabel) {
        _lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.deviceNickLabel.left, 79, Kwidth-self.deviceNickLabel.left, 1)];
        _lineLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _lineLabel.text = @"";
        _lineLabel.textColor = [UIColor clearColor];
    }
    return _lineLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
