//
//  ShareView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ShareView.h"
#import "JfgGlobal.h"
#import "ShareButton.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "NetworkMonitor.h"
#import "LSAlertView.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>

#define shareButtonImageKey @"_shareButtonImage"
#define shareButtonTitleKey @"_shareButtonTitle"

typedef NS_ENUM(NSInteger, ControlTag) {
    Btn_ControlTag = 1000,
};

void (^svClickedBlock) (SSDKPlatformType sType) = nil;
void (^svCancelBlock) (void) = nil;

@interface ShareView()

@property (nonatomic, strong) UIWindow *svWindow;

@property (nonatomic, strong) UILabel *shareLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSArray *imageTiltles;

@end


@implementation ShareView

- (instancetype)init
{
    if (self = [super init])
    {
        self.top = kheight;     // Default in view bottom
        self.width = Kwidth;
        self.height = kheight;
        [self initView];
    }
    return self;
}


- (void)initView
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.shareLabel];
    [self.bgView addSubview:self.cancelButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGesture];
    
    [self initButtons];
    
    [self updateControlFrame];
}

- (void)initButtons
{
    [self.buttons removeAllObjects];
    
    NSInteger cloumn = 2;     // 行
    NSInteger row = 4;
    // 列
    CGFloat btnWidth = 50.0f;
    CGFloat btnHeight = 50.0f;
    CGFloat spaceX = (Kwidth - 28.0*2 - row*btnWidth)/(row - 1);
    CGFloat spaceY = 45.0f;
    
    NSInteger index = 0;
    
    
    for (NSInteger i = 0; i < cloumn; i ++)
    {
        for (NSInteger j = 0 ; j < row; j ++)
        {
            if (index < self.imageTiltles.count)
            {
                NSDictionary *imageDict = [self.imageTiltles objectAtIndex:index];
                
                ShareButton *shareBtn = [[ShareButton alloc] init];
                shareBtn.tag = Btn_ControlTag + index;
//                shareBtn.enabled = [ShareSDK isClientInstalled:[self conertToSDKPlatType:(shareType)index]];
                [shareBtn setImage:[UIImage imageNamed:[imageDict objectForKey:shareButtonImageKey]] forState:UIControlStateNormal];
                [shareBtn setTitle:[imageDict objectForKey:shareButtonTitleKey] forState:UIControlStateNormal];
                shareBtn.frame = CGRectMake(28.0 + j*(spaceX + btnWidth), 60.0 + (spaceY + btnHeight)*i, btnWidth, btnHeight);
                [shareBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
                [shareBtn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
                shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                [shareBtn addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.bgView addSubview:shareBtn];
                [self.buttons addObject:shareBtn];
            }
            
            index ++;
        }
    }
}


- (void)updateControlFrame
{
    if (self.isLandScape) // landScape
    {
//        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.left = 0;
        self.top = 0;
        self.width = Kwidth;
        self.height = kheight;
        
        self.bgView.width = Kwidth;
        self.bgView.height = 225;
        self.bgView.top =  kheight - self.bgView.height;
        self.bgView.left = 0;
        
        self.cancelButton.width = Kwidth;
        self.cancelButton.top = self.bgView.height - self.cancelButton.height;
        self.cancelButton.left = 0;
        
        CGFloat leftSpace = 35.0f;
        CGFloat spaceX = (Kwidth - 2*leftSpace - self.buttons.count * 50)/(self.buttons.count - 1);
        
        
        for (NSInteger i = 0; i < self.buttons.count; i ++)
        {
            UIButton *aButton = (UIButton *)[self.buttons objectAtIndex:i];
            aButton.left = leftSpace + i * (aButton.width + spaceX);
            aButton.top = 60.0f;
        }
    }
    else
    {
        self.transform = CGAffineTransformIdentity;
        self.left = 0;
        self.top = 0;
        self.width = Kwidth;
        self.height = kheight;
        
        CGFloat bgViewH = 328.0f;
        self.bgView.frame = CGRectMake(0, kheight - bgViewH, Kwidth, bgViewH);
        
        CGFloat canBtnH = 50.0f;
        self.cancelButton.frame = CGRectMake(0, self.bgView.height - canBtnH, Kwidth, canBtnH);
        
        NSInteger cloumn = 2;     // 行
        NSInteger row = 4;
        // 列
        CGFloat btnWidth = 50.0f;
        CGFloat btnHeight = 50.0f;
        CGFloat spaceX = (Kwidth - 28.0*2 - row*btnWidth)/(row - 1);
        CGFloat spaceY = 45.0f;
        NSInteger index = 0;
        
        for (NSInteger i = 0; i < cloumn; i ++)
        {
            for (NSInteger j = 0 ; j < row; j ++)
            {
                if (index < self.buttons.count)
                {
                    UIButton *aShareButton = [self.buttons objectAtIndex:index];
                    aShareButton.frame = CGRectMake(28.0 + j*(spaceX + btnWidth), 60.0 + (spaceY + btnHeight)*i, btnWidth, btnHeight);
                }
                
                index ++;
            }
        }
        
    }
}


#pragma mark show action

- (instancetype)initWithLandScape:(BOOL)isLandScape
{
    self.isLandScape = isLandScape;
    return [self init];
}

- (void)showShareView:(void (^)(SSDKPlatformType))clickedBlock cancel:(void (^)())cancelBlock
{
    self.bgView.top = self.height;
    self.alpha = 0;
    [self.svWindow addSubview:self];
    
    JFG_WS(weakSelf);
    
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            if (weakSelf.isLandScape)
            {
                weakSelf.bgView.top =  kheight - weakSelf.bgView.height;
            }
            else
            {
                CGFloat bgViewH = 328.0f;
                weakSelf.bgView.top =  kheight - bgViewH;
            }
            
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    if (clickedBlock)
    {
        svClickedBlock = [clickedBlock copy];
    }
    
    if (cancelBlock)
    {
        svCancelBlock = [cancelBlock copy];
    }
    
}

- (void)dismissShareView
{
    JFG_WS(weakSelf);
    
    [UIView animateWithDuration:.2 animations:^{
        weakSelf.bgView.top = kheight;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark actions
- (void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    
    if (CGRectContainsPoint(self.bgView.frame, [gesture locationInView:self]) == NO)
    {
        [self dismissShareView];
    }
    
}

- (void)shareButtonAction:(UIButton *)sender
{
    // without network
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess)
    {
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    // mobileData using
    JFG_WS(weakSelf);
    if ([[NetworkMonitor sharedManager] currentNetworkStatu] == ReachableViaWWAN && ([CommonMethod currentConnecttedWifi] == nil || [[CommonMethod currentConnecttedWifi] isEqualToString:@""]))
    {
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Firmware_DataTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:^{
            
        } OKBlock:^{
            if (svClickedBlock)
            {
                svClickedBlock([weakSelf conertToSDKPlatType:(shareType)(sender.tag - Btn_ControlTag)]);
            }
            
            [weakSelf removeFromSuperview];
        }];
        
        return;
    }
    
    if (svClickedBlock)
    {
        svClickedBlock([self conertToSDKPlatType:(shareType)(sender.tag - Btn_ControlTag)]);
    }
    
    [self removeFromSuperview];
}

- (void)cancelButtonAction:(UIButton *)sender
{
    if (svCancelBlock)
    {
        svCancelBlock();
    }
    
    [self dismissShareView];
}

- (SSDKPlatformType)conertToSDKPlatType:(shareType)sType
{
    SSDKPlatformType sdkStype = SSDKPlatformTypeUnknown;
    
    switch (sType)
    {
        case shareTypeQQ:
        {
            sdkStype = SSDKPlatformSubTypeQQFriend;
        }
            break;
        case shareTypeQQZone:
        {
            sdkStype = SSDKPlatformSubTypeQZone;
        }
            break;
        case shareTypeTwitter:
        {
            sdkStype = SSDKPlatformTypeTwitter;
        }
            break;
        case shareTypeWebChat:
        {
            sdkStype = SSDKPlatformSubTypeWechatSession;
        }
            break;
        case shareTypeFaceBook:
        {
            sdkStype = SSDKPlatformTypeFacebook;
        }
            break;
        case shareTypeInFriends:
        {
            sdkStype = SSDKPlatformSubTypeWechatTimeline;
        }
            break;
        case shareTypeSinaWeibo:
        {
            sdkStype = SSDKPlatformTypeSinaWeibo;
        }
            break;
        default:
            break;
    }
    
    
    return sdkStype;
}

#pragma mark getter

- (NSMutableArray *)buttons
{
    if (_buttons == nil)
    {
        _buttons = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _buttons;
}

- (NSArray *)imageTiltles
{
    if (_imageTiltles == nil)
    {
        _imageTiltles = [NSArray arrayWithObjects:
                         @{shareButtonImageKey:@"btn_share_wechat",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"WeChat"]},
                         @{shareButtonImageKey:@"btn_share_TimeLine",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"Tap2_Share_Moments"]},
                         @{shareButtonImageKey:@"share_icon_qq",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"QQ"]},
                         @{shareButtonImageKey:@"share_icon_qqspace",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"Qzone_QQ"]},
                         @{shareButtonImageKey:@"share_icon_weibo",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"Weibo"]},
                         @{shareButtonImageKey:@"icon_facebook-1",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"faceBook"]},
                         @{shareButtonImageKey:@"icon_twitter_1",shareButtonTitleKey:[JfgLanguage getLanTextStrByKey:@"twitter"]}, nil];
    }
    return _imageTiltles;
}

- (UIView *)bgView
{
    if (_bgView == nil)
    {
        CGFloat height = 328.0f;
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kheight, Kwidth, height)];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    
    return _bgView;
}

- (UILabel *)shareLabel
{
    if (_shareLabel == nil)
    {
        CGFloat fontSize = 16.0f;
        _shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 22, Kwidth, fontSize)];
        _shareLabel.font = [UIFont systemFontOfSize:fontSize];
        _shareLabel.text = [JfgLanguage getLanTextStrByKey:@"SharedTo"];
        _shareLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    return _shareLabel;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil)
    {
        CGFloat height = 50.0f;
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.bgView.height - height, Kwidth, height)];
        [_cancelButton setBackgroundColor:[UIColor colorWithHexString:@"#fafafa"]];
        [_cancelButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self  action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}

- (UIWindow *)svWindow
{
    if (_svWindow == nil)
    {
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)])
        {
            _svWindow = [[UIApplication sharedApplication].delegate performSelector:@selector(window)];
        }
        else
        {
            _svWindow = [[UIApplication sharedApplication] keyWindow];
        }
        
    }
    return _svWindow;
}

@end
