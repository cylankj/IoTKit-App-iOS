//
//  NothingDevTipView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "NothingDevTipView.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"

@interface NothingDevTipView()
@property (nonatomic,strong)UIImageView *picImageView;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *subTitleLabel;
@end

@implementation NothingDevTipView



-(instancetype)initWithFrame:(CGRect)frame
{
    CGRect newFrame = frame;
    newFrame.size.width = 180;
    newFrame.size.height = 125+20+14+15+12;
    self = [super initWithFrame:newFrame];
    return self;
}


-(void)setTipImage:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle
{
    self.picImageView.image = image;
    self.titleLabel.text = title;
    self.subTitleLabel.text = subTitle;
}

-(void)didMoveToSuperview
{
    
    [self addSubview:self.picImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subTitleLabel];
    
}

#pragma mark- getter

-(UIImageView *)picImageView
{
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 314*0.5, 125)];
        _picImageView.x = self.width*0.5;
        _picImageView.image = [UIImage imageNamed:@"pic_tips _none"];
    }
    return _picImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.picImageView.bottom+20, self.width, 15)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    return _titleLabel;
}

-(UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.titleLabel.bottom+14, self.width, 12)];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    }
    return _subTitleLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
