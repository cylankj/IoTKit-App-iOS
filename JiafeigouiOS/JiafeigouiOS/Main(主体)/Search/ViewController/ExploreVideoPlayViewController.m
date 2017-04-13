//
//  ExploreVideoPlayViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/1/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ExploreVideoPlayViewController.h"
#import "KRVideoPlayerController.h"

@interface ExploreVideoPlayViewController ()

@property (nonatomic,strong)KRVideoPlayerController *videoController;

@end

@implementation ExploreVideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoController.view];
    NSString *netPath = @"https://jiafeigou-yf.oss-cn-hangzhou.aliyuncs.com/long/demo.mp4";
    NSURL *URL = [[NSURL alloc] initWithString:netPath];
    self.videoController.contentURL = URL;
    // Do any additional setup after loading the view.
}

-(KRVideoPlayerController *)videoController
{
    if (!_videoController) {
        _videoController = [[KRVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
            [weakSelf.navigationController popViewControllerAnimated:NO];
        }];
    }
    return _videoController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
