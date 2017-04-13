//
//  EfamilyVoiceCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyVoiceCell.h"
#import "JfgGlobal.h"

@implementation EfamilyVoiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initView];
        [self initViewLayout];
    }
    
    return self;
}

- (void)initView
{
    self.bgImageView.image = [UIImage imageNamed:@"efamily_voice_bg"];
    self.headImageView.image = [UIImage imageNamed:@"image_ihome"];
    [self.bgImageView addSubview:self.voiceImageView];
    [self.bgImageView addSubview:self.voiceDuraLabel];
    [self addSubview:self.loadingImageView];
}

- (void)initViewLayout
{
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headImageView.mas_left).with.offset(-5.0f);
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(15.0f);
        make.width.mas_lessThanOrEqualTo(@(Kwidth - 70.0f));
    }];
    
    [self.voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgImageView).with.offset(-20.0f);
        make.centerY.equalTo(self.bgImageView);
    }];
    
    [ self.voiceDuraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView).with.offset(15.0f);
        make.centerY.equalTo(self.voiceImageView);
    }];

    [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgImageView);
        make.right.equalTo(self.bgImageView.mas_left).with.offset(-10);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10.0f);
        make.top.equalTo(self).offset(53.0f);
        make.size.mas_equalTo(CGSizeMake(40.0f, 40.0f));
    }];
}


- (UILabel *)voiceDuraLabel
{
    if (_voiceDuraLabel == nil)
    {
        _voiceDuraLabel = [[UILabel alloc] init];
        _voiceDuraLabel.font = [UIFont systemFontOfSize:15.0f];
        _voiceDuraLabel.textColor = [UIColor whiteColor];
    }
    
    return _voiceDuraLabel;
}

- (UIImageView *)voiceImageView
{
    if (_voiceImageView == nil)
    {
        _voiceImageView = [[UIImageView alloc] init];
        _voiceImageView.image = [UIImage imageNamed:@"efamily_voicewaver_2"];
        _voiceImageView.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"efamily_voicewaver_0.png"],
                                               [UIImage imageNamed:@"efamily_voicewaver_1.png"],
                                               [UIImage imageNamed:@"efamily_voicewaver_2.png"], nil];
        _voiceImageView.animationDuration = 1.5f;
        _voiceImageView.animationRepeatCount = 0;
    }
    return _voiceImageView;
}

- (UIImageView *)loadingImageView
{
    if (_loadingImageView == nil)
    {
        _loadingImageView = [[UIImageView alloc] init];
    }
    
    return _loadingImageView;
}
@end
