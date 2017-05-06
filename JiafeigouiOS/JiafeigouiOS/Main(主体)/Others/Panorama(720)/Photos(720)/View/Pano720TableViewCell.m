//
//  Pano720TableViewCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720TableViewCell.h"
#import "TimeLineView.h"
#import "DelButton.h"
#import "JfgGlobal.h"

@interface Pano720TableViewCell()

@property (nonatomic, strong) TimeLineView *lineView; // 竖线
@property (nonatomic, strong) Pano720PhotoModel *cellModel;

@property (nonatomic, assign) CGFloat offsetX;

@end

@implementation Pano720TableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initView];
        
        self.offsetX = 15.0f;
    }
    
    return self;
}

- (void)initView
{
    [self addSubview:self.lineView];
    [self addSubview:self.picImageView];
    
    [self.picImageView addSubview:self.phoneIconImgeView];
    [self.picImageView addSubview:self.deviceIconImgeView];
    [self.picImageView addSubview:self.durationLabel];
    [self.picImageView addSubview:self.progressLabel];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{   
    self.lineView.hidden = editing;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (editing)
        {
            CGFloat picWidth = Kwidth - 39 - 15.0f;
            self.picImageView.frame = CGRectMake(39 + self.offsetX, self.picImageView.top, picWidth, picWidth/3);
        }
        else
        {
            CGFloat picWidth = Kwidth - 39 - 15.0f;
            self.picImageView.frame = CGRectMake(39, self.picImageView.top, picWidth, picWidth/3);
        }
    } completion:^(BOOL finished) {
        
    }];
    
    [super setEditing:editing animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)updateIconImageViewLayout
{
    if (self.phoneIconImgeView.hidden == NO && self.deviceIconImgeView.hidden == YES)
    {
        CGFloat width = 13;
        CGFloat height = 23;
        CGFloat x = self.picImageView.width - width - 6;
        CGFloat y = self.picImageView.height - height - 5;
        
        self.phoneIconImgeView.frame = CGRectMake(x, y, width, height);
    }
    else
    {
        self.deviceIconImgeView.frame = CGRectMake(self.picImageView.width - 13 - 6, self.picImageView.height - 23 - 5, 13, 23);
        self.phoneIconImgeView.frame = CGRectMake(self.deviceIconImgeView.left - 13 - 12, self.picImageView.height - 23 - 5, 13, 23);
    }
}

#pragma mark
#pragma mark  imageView cell
- (UIImageView *)picImageView
{
    if (_picImageView == nil)
    {
        CGFloat x = 39;
        CGFloat y = 2.5;
        CGFloat width = Kwidth - x - 15.0f;
        CGFloat heigth = width/3;
        
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, heigth)];
        _picImageView.contentMode = UIViewContentModeScaleToFill;
        _picImageView.image = [UIImage imageNamed:@"album_pic_broken"];
        _picImageView.hidden = NO;
    }

    return _picImageView;
}


- (UIImageView *)phoneIconImgeView
{
    if (_phoneIconImgeView == nil)
    {
        CGFloat width = 13;
        CGFloat height = 23;
        CGFloat x = self.deviceIconImgeView.left - width - 12;
        CGFloat y = self.picImageView.height - height - 5;
        
        _phoneIconImgeView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _phoneIconImgeView.image = [UIImage imageNamed:@"album_icon_iphone"];
    }
    
    return _phoneIconImgeView;
}

- (UIImageView *)deviceIconImgeView
{
    if (_deviceIconImgeView == nil)
    {
        CGFloat width = 13;
        CGFloat height = 23;
        CGFloat x = self.picImageView.width - width - 6;
        CGFloat y = self.picImageView.height - height - 5;
        
        _deviceIconImgeView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _deviceIconImgeView.image = [UIImage imageNamed:@"album_icon_720camera"];
    }
    
    return _deviceIconImgeView;
}

- (UILabel *)durationLabel
{
    if (_durationLabel == nil)
    {
        CGFloat width = 100;
        CGFloat height = 11;
        CGFloat x = 5;
        CGFloat y = self.picImageView.height - 5 - height;
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _durationLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _durationLabel.font = [UIFont systemFontOfSize:height];
        _durationLabel.text = @"00:12";
    }
    return _durationLabel;
}

- (UILabel *)progressLabel
{
    if (_progressLabel == nil)
    {
        CGFloat width = 100;
        CGFloat height = 11;
        CGFloat x = self.picImageView.width - 5 - width;
        CGFloat y = 5;
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _progressLabel.font = [UIFont systemFontOfSize:height];
        _progressLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _progressLabel.textAlignment = NSTextAlignmentRight;
        _progressLabel.text = @"05%";
    }
    return _progressLabel;
}

#pragma mark
#pragma mark  common cell
- (TimeLineView *)lineView
{
    if (_lineView == nil)
    {
        CGFloat x = 22;
        CGFloat y = 0;
        CGFloat width = 1;
        CGFloat heigth = cellRowHeight;
        
        _lineView = [[TimeLineView alloc] initWithFrame:CGRectMake(x, y, width, heigth)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
    }
    
    return _lineView;
}

- (Pano720PhotoModel *)cellModel
{
    if (_cellModel == nil)
    {
        _cellModel = [[Pano720PhotoModel alloc] init];
    }
    
    return _cellModel;
}


@end
