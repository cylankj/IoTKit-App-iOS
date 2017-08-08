//
//  AdView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AdView.h"
#import "JfgGlobal.h"
#import "ZZCircleProgress.h"
#import "JFGWebViewController.h"
#import "FileManager.h"
#import "JfgUserDefaultKey.h"
#import "DownloadUtils.h"
#import "JfgConstKey.h"
#import "CommonMethod.h"
#import "AdWebViewController.h"

#define showTime 3      // 显示n次

@interface AdView()

@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) NSDictionary *adDict;
@property (nonatomic, strong) ZZCircleProgress *circle;
@end

@implementation AdView

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self addSubview:self.adImageView];
        [self addSubview:self.skipButton];
        [self addSubview:self.circle];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.adImageView];
        [self addSubview:self.circle];
        [self addSubview:self.skipButton];
    }
    return self;
}


- (void)didMoveToSuperview
{
    [self performSelector:@selector(skipButtonAction:) withObject:nil afterDelay:4.0f];
    
    UIImage *adImage = [UIImage imageWithContentsOfFile:[[FileManager jfgAdvertisementDirPath] stringByAppendingPathComponent:[[NSURL URLWithString:[self.adDict objectForKey:adPicURLKey]] lastPathComponent]]];
    
//    if (adImage == nil) {
//        adImage = [UIImage imageNamed:@"test1"];
//    }
    
    if (adImage == nil )
    {
        [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:adShowTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self removeFromSuperview];
    }
    else
    {
        int adShowCount = [[[NSUserDefaults standardUserDefaults] valueForKey:adShowTimeKey] intValue];
        
        if (adShowCount < showTime)
        {
            self.adImageView.image = adImage;
            adShowCount ++;
            [[NSUserDefaults standardUserDefaults] setValue:@(adShowCount) forKey:adShowTimeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [self removeFromSuperview];
        }
        
        /*
        switch ([JfgLanguage languageType])
        {
            case LANGUAGE_TYPE_CHINESE:
            case LANGUAGE_TYPE_ENGLISH:
            {
                int adShowCount = [[[NSUserDefaults standardUserDefaults] valueForKey:adShowTimeKey] intValue];

                if (adShowCount < showTime)
                {
                    self.adImageView.image = adImage;
                    adShowCount ++;
                    [[NSUserDefaults standardUserDefaults] setValue:@(adShowCount) forKey:adShowTimeKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    [self removeFromSuperview];
                }
                
            }
                break;
                
            default:
            {
                [self removeFromSuperview];
            }
                break;
        }
        */
    }
}

#pragma mark delegate

- (void)skipButtonAction:(UIButton*)skipButton
{
    [self removeFromSuperview];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(skipAction)])
    {
        [self.delegate skipAction];
    }
}

- (void)watchAdAction:(UITapGestureRecognizer *)gesture
{
    //[self removeFromSuperview];
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(watchAd:)])
//    {
//        [self.delegate watchAd:[self.adDict objectForKey:adTagURLKey]];
//    }
    UIViewController *vc = [CommonMethod viewControllerForView:self];
    if (vc) {
        NSString *url = [self.adDict objectForKey:adTagURLKey];
        if (url) {
            AdWebViewController *adwb = [AdWebViewController new];
            adwb.url = url;
            [vc presentViewController:adwb animated:YES completion:nil];
        }
        
    }
}


#pragma mark getter

- (ZZCircleProgress *)circle
{
    if (_circle == nil)
    {
        _circle = [[ZZCircleProgress alloc] initWithFrame:self.skipButton.frame pathBackColor:nil pathFillColor:[UIColor whiteColor] startAngle:0 strokeWidth:2];
        _circle.showPoint = NO;
        _circle.startAngle = -90.0f;
        _circle.pathBackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _circle.animationModel = CircleIncreaseByProgress;
        _circle.showProgressText = NO;
        _circle.progress = 1;
    }
    
    return _circle;
}

- (UIImageView *)adImageView
{
    if (_adImageView == nil)
    {
        _adImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _adImageView.userInteractionEnabled = YES;
        [_adImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(watchAdAction:)]];
    }
    return _adImageView;
}

- (UIButton *)skipButton
{
    if (_skipButton == nil)
    {
        _skipButton = [[UIButton alloc] initWithFrame:CGRectMake(Kwidth - 15 - 40, 15, 40, 40)];
        [_skipButton setTitle:[JfgLanguage getLanTextStrByKey:@"跳过"] forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_skipButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _skipButton;
}

- (NSDictionary *)adDict
{
    if (_adDict == nil)
    {
        _adDict = [NSDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:adDictKey]];
    }
    return _adDict;
}


@end
