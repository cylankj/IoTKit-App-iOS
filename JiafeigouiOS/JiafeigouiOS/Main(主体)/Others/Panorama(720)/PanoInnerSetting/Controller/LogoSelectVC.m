//
//  LogoSelectVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "LogoSelectVC.h"
#import "JfgGlobal.h"

#define logoIconNum 4.0  //每行 显示logo 个数

typedef NS_ENUM(NSInteger, ViewTag) {
    Btn_Logo_tag = 1000, //
    
    
};

@interface LogoSelectVC ()

@property (nonatomic, strong) Panoramic720IosView *pano720View;
@property (nonatomic, strong) UIScrollView *bottomScrolView;
@property (nonatomic, strong) NSArray *logoIconImages;
@property (nonatomic, strong) NSArray *logoSelectIconImages;
@end

@implementation LogoSelectVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    
    [self initNavigation];
    
}

- (void)initView
{
    [self.view addSubview:self.bottomScrolView];
    [self initButtons];
    [self.view addSubview:self.pano720View];
    [self.pano720View loadUIImage:[UIImage imageNamed:@"bgimage_top_default"]];
}

- (void)initButtons
{
    CGFloat btnWidth = 66.0f;
    CGFloat spaceX = (self.bottomScrolView.contentSize.width - btnWidth*self.logoIconImages.count)/(self.logoIconImages.count+1);
    
    for (NSInteger i = 0; i < self.logoIconImages.count; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = Btn_Logo_tag + i;
        [btn setBackgroundImage:[UIImage imageNamed:[self.logoIconImages objectAtIndex:i]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",[self.logoIconImages objectAtIndex:i]]] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(logoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.width = btn.height = btnWidth;
        btn.left = spaceX * (i + 1) + btnWidth * i;
        btn.top = (self.bottomScrolView.height - btnWidth)*0.5;
        
        switch (i)
        {
            case 0: // 这个 需要 特殊处理
            {
                [btn setTitle:[JfgLanguage getLanTextStrByKey:@"无"] forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
        
        [self.bottomScrolView addSubview:btn];
    }
}

- (void)initNavigation
{
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LOGO 选择"];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark action
- (void)logoButtonAction:(UIButton *)sender
{
    for (NSInteger i = Btn_Logo_tag; i < Btn_Logo_tag+self.logoIconImages.count; i ++)
    {   
        if (i == sender.tag)
        {
            sender.selected = YES;
        }
        else
        {
            sender.selected = NO;
        }
    }
    
}

#pragma mark
#pragma mark getter

- (UIScrollView *)bottomScrolView
{
    if (_bottomScrolView == nil)
    {
        CGFloat width = Kwidth;
        CGFloat height = 144;
        CGFloat x = 0;
        CGFloat y = kheight - height;
        
        _bottomScrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [_bottomScrolView setContentSize:CGSizeMake(width*ceil(self.logoIconImages.count/logoIconNum), height)];
        
        _bottomScrolView.backgroundColor = [UIColor colorWithHexString:@"#333333"];
        _bottomScrolView.alpha = 0.95;
    }
    
    return _bottomScrolView;
}

- (NSArray *)logoIconImages
{
    if (_logoIconImages == nil)
    {
        _logoIconImages = [[NSArray alloc] initWithObjects:
                           @"logo_no_watermark",
                           @"logo_white",
                           @"logo_black",
                           @"logo_clever_dog",
                           nil];
    }
    
    return _logoIconImages;
}


- (Panoramic720IosView *)pano720View
{
    if (_pano720View == nil)
    {
        _pano720View = [[Panoramic720IosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 64.0, Kwidth, kheight - 64.0 - self.bottomScrolView.height)];
        [_pano720View configV720];
        _pano720View.backgroundColor = [UIColor blackColor];
        _pano720View.layer.edgeAntialiasingMask = YES;
    }
    
    
    
    return _pano720View;
}

@end
