//
//  EfamilyBotttomView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyBottomView.h"
#import "JfgGlobal.h"
#define leftSpace 45
@interface EfamilyBottomView()
{
    CGFloat selfHeight;
    CGFloat buttonWidth;
    CGFloat buttonHeight;
    CGFloat xSpace;
    CGFloat ySpace;
}
@end

@implementation EfamilyBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    selfHeight = 49.0;
    buttonWidth = 30.0;
    buttonHeight = 30.0;
    
    xSpace = (Kwidth - buttonWidth*3 - 2*leftSpace)/2.0;
    ySpace = (selfHeight - buttonHeight)/2.0;
    
    self = [super initWithFrame:CGRectMake(-1, kheight - selfHeight, Kwidth + 2, selfHeight)];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor colorWithHexString:@"#e1e1e1"].CGColor;
    
    if (self)
    {
        [self initView];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    
}

- (void)initView
{
    self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    
    [self addSubview:self.shareImgeButton];
    [self addSubview:self.videChatButton];
    [self addSubview:self.voiceButton];
    
}


#pragma mark getter

- (UIButton *)shareImgeButton
{
    if (_shareImgeButton == nil)
    {
        _shareImgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareImgeButton.frame = CGRectMake(leftSpace, ySpace, buttonWidth, buttonHeight);
        [_shareImgeButton setImage:[UIImage imageNamed:@"icon_efam_share"] forState:UIControlStateNormal];
    }
    return _shareImgeButton;
}

- (UIButton *)videChatButton
{
    if (_videChatButton == nil)
    {
        _videChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videChatButton.frame = CGRectMake(xSpace + self.shareImgeButton.right, ySpace, buttonWidth, buttonHeight);
        [_videChatButton setImage:[UIImage imageNamed:@"icon_efam_videochat"] forState:UIControlStateNormal];
    }
    
    return _videChatButton;
}


- (UIButton *)voiceButton
{
    if (_voiceButton == nil)
    {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.frame = CGRectMake(xSpace + self.videChatButton.right, ySpace, buttonWidth, buttonHeight);
        [_voiceButton setImage:[UIImage imageNamed:@"icon_efam_talk"] forState:UIControlStateNormal];
    }
    
    return _voiceButton;
}

@end
