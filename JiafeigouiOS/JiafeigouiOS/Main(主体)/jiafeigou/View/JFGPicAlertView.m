//
//  LowPowerAlertView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGPicAlertView.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "FLGlobal.h"
#define CoverViewTag 777

void (^dismissBlock) (void) = nil;

@interface JFGPicAlertView(){
    
}
@property (strong, nonatomic) UIImageView * topImageView;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * msgLabel;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) UIView * contentView;
@end
@implementation JFGPicAlertView

-(instancetype)initWithFrame:(CGRect)frame WithImage:(UIImage *)image Title:(NSString *)title Message:(NSString *)msg cofirmButtonTitle:(NSString *)btnTitle{
    
    self = [super initWithFrame:frame];
    
    if (self) {

        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setCornerRadius:15];
        [self.layer setMasksToBounds:YES];
        [self addSubview:self.contentView];
        [_topImageView setImage:image];
        [_titleLabel setText:title];
        [_msgLabel setText:msg];
        [_confirmBtn setTitle:btnTitle forState:UIControlStateNormal];
        [self addSubview:self.closeBtn];
    }
    return self;
}

+(void)showAlertWithImage:(UIImage *)image Title:(NSString *)title Message:(NSString *)msg cofirmButtonTitle:(NSString *)btnTitle didDismissBlock:(void (^) (void))dissmissBlock{
    JFGPicAlertView * alert = [[JFGPicAlertView alloc]initWithFrame:CGRectMake((Kwidth-270*designHscale)*0.5, -414*designHscale, 270*designHscale, 414*designHscale) WithImage:image Title:title Message:msg cofirmButtonTitle:btnTitle];
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView * cover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0;
    cover.tag = CoverViewTag;
    
    [window addSubview:cover];
    [window addSubview:alert];
    
    [UIView animateWithDuration:0.2 animations:^{
        cover.alpha=0.6;
        [alert setFrame:CGRectMake((Kwidth-270*designHscale)*0.5, (kheight-414*designHscale)*0.22/0.47, 270*designHscale, 414*designHscale)];
    }];
    dismissBlock = [dissmissBlock copy];
}
-(void)dissMis{

    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView * cover = [window viewWithTag:CoverViewTag];
    [UIView animateWithDuration:0.2 animations:^{
        cover.alpha = 0;
        [self setFrame:CGRectMake((Kwidth-270*designHscale)*0.5, -414*designHscale, 270*designHscale, 414*designHscale)];
    }completion:^(BOOL finished) {
        [cover removeFromSuperview];
        [self removeFromSuperview];
    }];
    if (dismissBlock != nil) {
        dismissBlock();
    }
}
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 350*designHscale)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [_contentView.layer setCornerRadius:15];
        [_contentView.layer setMasksToBounds:YES];
        [_contentView addSubview:self.topImageView];
        [_contentView addSubview:self.titleLabel];
        [_contentView addSubview:self.msgLabel];
        [_contentView addSubview:self.confirmBtn];
    }
    return _contentView;
}
-(UIImageView *)topImageView{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 204*designHscale)];
    }
    return _topImageView;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14*designHscale, self.topImageView.bottom+22*designHscale, CGRectGetWidth(self.frame)-28*designHscale, 16*designHscale)];
        _titleLabel.font = [UIFont systemFontOfSize:16*designHscale];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    return _titleLabel;
}
-(UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(14*designHscale, self.titleLabel.bottom+14*designHscale, CGRectGetWidth(self.frame)-28*designHscale, 54*designHscale)];
        _msgLabel.font = [UIFont systemFontOfSize:14*designHscale];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.numberOfLines = 0;
        _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _msgLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    }
    return _msgLabel;
}
-(UIButton *)confirmBtn{
    if(!_confirmBtn){
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setFrame:CGRectMake(0, 310*designHscale, CGRectGetWidth(self.frame), 40*designHscale)];
        [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:16*designHscale]];
        [_confirmBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(dissMis) forControlEvents:UIControlEventTouchUpInside];
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.frame), 0.5)];
        line.backgroundColor = TableSeparatorColor;
        [_confirmBtn addSubview:line];
    }
    return _confirmBtn;
}
-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setFrame:CGRectMake((self.width-44*designHscale)*0.5, 370*designHscale, 44*designHscale, 44*designHscale)];
        [_closeBtn.layer setCornerRadius:22*designHscale];
        [_closeBtn.layer setMasksToBounds:YES];
        [_closeBtn setImage:[UIImage imageNamed:@"png_close"] forState:UIControlStateNormal];
        
        [_closeBtn setBackgroundColor:[UIColor blackColor]];
        _closeBtn.alpha = 0.5;
        [_closeBtn addTarget:self action:@selector(dissMis) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
@end
