//
//  TimeLapseGuideViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TimeLapseGuideViewController.h"
#import "FLGlobal.h"
#import "UILabel+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIButton+FLExtentsion.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "TimeLapsePGViewController.h"
#import "JfgUserDefaultKey.h"

@interface TimeLapseGuideViewController ()
@property(nonatomic,strong)UIImageView * _imageView;
@property(nonatomic,strong)UILabel * _label;
@property(nonatomic,strong)UIButton * _button;
@end

@implementation TimeLapseGuideViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self._imageView];
    [self.view addSubview:self._label];
    [self.view addSubview:self._button];
    [self.leftButton addTarget:self action:@selector(backItem) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isShowDelayPhotoRedDot(self.cid)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)backItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIImageView *)_imageView{
    if (!__imageView) {
        __imageView = [[UIImageView alloc]initWithFrame:CGRectMake((Kwidth-250)/2.0, 108*designHscale+64, 250, 123)];
        __imageView.image = [UIImage imageNamed:@"delay_pic"];
        
    }
    return __imageView;
}
-(UILabel *)_label{
    if (!__label) {
        __label = [UILabel initWithFrame:CGRectMake((Kwidth-230)/2.0, self._imageView.bottom+27, 230.0, 65.0) text:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Greetings"] font:FontNameHelvetica size:15 color:[UIColor colorWithHexString:@"#aaaaaa"] alignment:NSTextAlignmentCenter lines:0];
        __label.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return __label;
}
-(UIButton *)_button{
    if (!__button) {
        __button = [UIButton initWithFrame:CGRectMake((Kwidth-180)/2.0, self._label.bottom+90*designHscale, 180, 44) image:nil highlightedImage:nil cornerRadius:22 handerForTouchUpInside:^(UIButton *button) {
            TimeLapsePGViewController * timeLapseVC = [[TimeLapsePGViewController alloc]init];
            [self.navigationController pushViewController:timeLapseVC animated:YES];
            timeLapseVC.cid = self.cid;
        }];
        [__button setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Start"] forState:UIControlStateNormal];
        [__button setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"]];
        [__button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        __button.layer.borderWidth = 0.5;
        __button.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
    }
    return __button;
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
