//
//  TimeDelayVideoPlayer.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TimeDelayVideoPlayer.h"
#import "JfgGlobal.h"
#import "KRVideoPlayerController.h"

@interface TimeDelayVideoPlayer ()
/**
 *  video 控件
 */
@property (nonatomic, strong) KRVideoPlayerController *videoController;

@end

@implementation TimeDelayVideoPlayer

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark view
- (void)initView
{
    
    UIButton *ben = [UIButton buttonWithType:UIButtonTypeInfoDark];
    ben.frame = CGRectMake(50, 100, 60, 40);
    [ben addTarget:self action:@selector(abd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ben];
}

- (void)initNavigationView
{
    // 顶部 导航设置
//    self.navigationView.hidden = YES;
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark action
- (void)abd
{
//    @"http://jiafeigou-yf.oss-cn-hangzhou.aliyuncs.com/out.mp4?OSSAccessKeyId=u5gVlQwDkbUABMWe&Expires=1468306517&Signature=fI2QhXUbx0U1G3wQe7nAclF7IMM%3D"
//    [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"]
//    [NSURL URLWithString:@"http://jiafeigou-yf.oss-cn-hangzhou.aliyuncs.com/out.mp4?OSSAccessKeyId=u5gVlQwDkbUABMWe&Expires=1468306517&Signature=fI2QhXUbx0U1G3wQe7nAclF7IMM%3D"]
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    
    if (!self.videoController)
    {
        self.videoController = [[KRVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController showInWindow];
    }
    self.videoController.contentURL = videoURL;
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

#pragma mark property

@end
