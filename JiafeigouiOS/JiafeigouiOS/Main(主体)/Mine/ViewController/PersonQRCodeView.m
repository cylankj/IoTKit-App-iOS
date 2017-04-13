//
//  PersonQRCodeView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "PersonQRCodeView.h"
#import "UIColor+HexColor.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import <JFGSDK/JFGSDK.h>
#import "CommonMethod.h"
#import "UIImageView+JFGImageView.h"

@interface PersonQRCodeView()

@property (nonatomic,strong)UIView *qrBgView;
@property (nonatomic,strong)UIImageView *headImageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UIImageView *qrImageView;


@end

@implementation PersonQRCodeView


-(instancetype)initWithHeadImage:(UIImage *)headImage name:(NSString *)name qrImage:(UIImage *)qrImage
{
    self = [self init];
    
    self.headImageView.image = headImage;
    self.nameLabel.text = name;
    self.qrImageView.image = qrImage;
    
    [self.headImageView jfg_setImageWithAccount:nil placeholderImage:nil  refreshCached:NO completed:nil];
    
    return self;
}

-(instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:self.qrBgView];
        [self.qrBgView addSubview:self.headImageView];
        [self.qrBgView addSubview:self.nameLabel];
        [self.qrBgView addSubview:self.qrImageView];
    }
    return  self;
}

-(void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.alpha = 0;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view != self.qrBgView) {
        [self dismiss];
        
    }
}

-(UIView *)qrBgView
{
    if (_qrBgView == nil) {
        _qrBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 341)];
        _qrBgView.center = self.center;
        _qrBgView.layer.masksToBounds = YES;
        _qrBgView.layer.cornerRadius = 3;
        _qrBgView.backgroundColor = [UIColor whiteColor];
    }
    return _qrBgView;
}

-(UIImageView *)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.qrBgView.bounds.size.width-75)*0.5, 35, 75, 75)];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = 75*0.5;
    }
    return _headImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.headImageView.bounds.size.height+self.headImageView.frame.origin.y+7, self.qrBgView.bounds.size.width-20, 20)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _nameLabel.font = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}

-(UIImageView *)qrImageView
{
    if (!_qrImageView) {
        _qrImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.qrBgView.bounds.size.width-143)*0.5, self.nameLabel.bounds.size.height+self.nameLabel.frame.origin.y+26, 143, 143)];
    }
    return _qrImageView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
