//
//  JFGDevOfflineFor720VC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/1.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGDevOfflineFor720VC.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "PilotLampStateVC.h"
#import "AddDeviceGuideViewController.h"
#import "Cf720WiFiAnimationVC.h"
#import "BaseNavgationViewController.h"
#import "JfgLanguage.h"
#import <Masonry.h>

@interface JFGDevOfflineFor720VC ()<AddDeviceGuideVCNextActionDelegate>
{
    BOOL isAPModel;
}
@end

@implementation JFGDevOfflineFor720VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavagationBar];
    [self initView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//指示灯说明页面跳转
-(void)smBtnAction
{
    PilotLampStateVC *lampVC = [PilotLampStateVC new];
    [self presentViewController:lampVC animated:YES completion:nil];
}

-(void)setBtnAction:(UIButton *)sender
{
    if (sender.tag == 1001) {
        //配置wifi
        isAPModel = NO;
    }else{
        //ap直连
        isAPModel = YES;
    }
    AddDeviceGuideViewController *deviGuide = [AddDeviceGuideViewController new];
    deviGuide.pType = productType_720;
    deviGuide.delegate = self;
    [self.navigationController pushViewController:deviGuide animated:YES];
}

//跳转代理方法
-(void)addDeviceGuideVCNectActionForVC:(UIViewController *)vc
{
    Cf720WiFiAnimationVC *wifiAn = [Cf720WiFiAnimationVC new];
    wifiAn.cidStr = self.cid;
    wifiAn.eventType = isAPModel?EventTypeOpenAPModel:EventTypeConfigWifi;
    [vc.navigationController pushViewController:wifiAn animated:YES];
}

-(void)initNavagationBar
{
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"OFFLINE_EXPLAIN"];
    [self.backBtn setImage:[UIImage imageNamed:@"album_btn_close"] forState:UIControlStateNormal];

    UIButton *smBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    smBtn.frame = CGRectMake(0, 0, 22, 22);
    smBtn.y = self.titleLabel.y;
    smBtn.right = self.view.width - 15;
    [smBtn setImage:[UIImage imageNamed:@"icon_explain_white"] forState:UIControlStateNormal];
    [smBtn addTarget:self action:@selector(smBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarBgView addSubview:smBtn];
    
    if (self.backBtn.superview == nil) {
        [self.topBarBgView addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@2);
            make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
            make.height.greaterThanOrEqualTo(@50);
            make.width.greaterThanOrEqualTo(@50);
        }];
    }
}

-(void)initView
{
    //set_con_wifi  install_icon_power  install_icon_ap
    
    NSArray *imageArr = @[@"install_icon_power",@"set_con_wifi",@"install_icon_ap"];
    NSArray *titleArr = @[[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE1"],[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE4"],[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE6"]];
    NSArray *detailArr = @[[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE2"],[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE5"],[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE7"]];
    
    NSMutableArray *detalLabelArr = [[NSMutableArray alloc]init];
    [imageArr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        UIImageView *iconImageView1 = [self iconImageWithTop:93 left:15 image:[UIImage imageNamed:obj]];
        UILabel *titleLabel1 = [self labelWithTop:98 left:58 font:[UIFont systemFontOfSize:18] color:[UIColor colorWithHexString:@"#333333"] text:[titleArr objectAtIndex:idx]];
        UILabel *detailLabel1 = [self labelWithTop:titleLabel1.bottom+8 left:58 font:[UIFont systemFontOfSize:15] color:[UIColor colorWithHexString:@"#666666"] text:detailArr[idx]];
        
        UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setBtn.frame = CGRectMake(0, 0, 100, 22);
        [setBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] forState:UIControlStateNormal];
        setBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        CGSize size = [setBtn.titleLabel sizeThatFits:CGSizeMake(150, 22)];
        setBtn.width = size.width;
        setBtn.left = 58;
        [setBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        setBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [setBtn addTarget:self action:@selector(setBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        setBtn.tag = 1000+idx;
        
        if (idx == 1) {
            
            UILabel *lb = detalLabelArr[idx-1];
            iconImageView1.top = lb.bottom + 93 - 5;
            titleLabel1.top = lb.bottom + 93;
            detailLabel1.top = titleLabel1.bottom + 8;
            setBtn.top = detailLabel1.bottom + 13;
            
            [self.view addSubview:setBtn];
            
        }else if (idx == 2){
            
            UILabel *lb = detalLabelArr[idx-1];
            iconImageView1.top = lb.bottom + 79 - 5;
            titleLabel1.top = lb.bottom + 79;
            detailLabel1.top = titleLabel1.bottom + 8;
            setBtn.top = detailLabel1.bottom + 13;
            [self.view addSubview:setBtn];
            
        }else if (idx == 0){
            
            UIView *lineLable = [[UIView alloc]initWithFrame:CGRectMake(60, detailLabel1.bottom+31, self.view.width-120, 0.5)];
            lineLable.backgroundColor = [UIColor colorWithHexString:@"#e7ebee"];
            [self.view addSubview:lineLable];
            
            UILabel *llb = [self labelWithTop:detailLabel1.bottom+34 left:58 font:[UIFont systemFontOfSize:15] color:[UIColor colorWithHexString:@"#999999"] text:[JfgLanguage getLanTextStrByKey:@"DEVICE_OFFLINE3"]];
            llb.x = self.view.x;
            [self.view addSubview:llb];
            
        }
        [detalLabelArr addObject:detailLabel1];
        
        [self.view addSubview:iconImageView1];
        [self.view addSubview:titleLabel1];
        [self.view addSubview:detailLabel1];
        
    }];
    
    
    
}


-(UIImageView *)iconImageWithTop:(CGFloat)top left:(CGFloat)left image:(UIImage *)image
{
    UIImageView *imageV = [[UIImageView alloc]initWithImage:image];
    imageV.left = left;
    imageV.top = top;
    return imageV;
}

-(UILabel *)labelWithTop:(CGFloat)top left:(CGFloat)left font:(UIFont *)font color:(UIColor *)color text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]init];
    label.font = font;
    label.textColor = color;
    label.text = text;
    label.numberOfLines = 0;
    label.left = left;
    label.top = top;
    CGSize size = [label sizeThatFits:CGSizeMake(self.view.width - 58- 15, CGFLOAT_MAX)];
    label.size = size;
    return label;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
