//
//  PilotLampStateVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "PilotLampStateVC.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "UIView+FLExtensionForFrame.h"

@interface PilotLampStateVC ()
@property (nonatomic,strong)UIScrollView *bgScrollerView;
@property (nonatomic,strong)UIButton *closeBtn;
@end

@implementation PilotLampStateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)initView
{
    [self.view addSubview:self.bgScrollerView];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:27];
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    titleLabel.text = [JfgLanguage getLanTextStrByKey:@"WIFI_HINT"];
    [self.bgScrollerView addSubview:titleLabel];

    NSArray *imageNameArr = @[@"image_panoramic_light",@"image_panoramic_power",@"image_panoramic_wifi"];
    [imageNameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = obj;
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:name]];
        imageView.frame = CGRectMake(35, titleLabel.bottom + 62+idx*(56+ 198*0.5), 84*0.5, 198*0.5);
        [self.bgScrollerView addSubview:imageView];
    }];
    //

    NSArray *subImageNameArr = @[@"icon_wifi",@"icon_power",@"icon_charging_lamp"];
    [subImageNameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView *subImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:obj]];
        subImageView.left = 113;
        
        UILabel *titleLabel1 = [[UILabel alloc]init];
        titleLabel1.font = [UIFont systemFontOfSize:14];
        titleLabel1.textColor = [UIColor colorWithHexString:@"#4b9fd5"];
        titleLabel1.width = 100;
        titleLabel1.height = 16;
        titleLabel1.left = subImageView.right+10;
        
        if (idx == 0) {
            subImageView.top = 354*0.5;
            titleLabel1.text = [JfgLanguage getLanTextStrByKey:@"WIFI_HINT_LAGEL_0"];
            NSArray *subTitleArr = @[@"WiFiLight_BlueFlashing",@"WiFiLight_SteadyBlue",@"WiFiLight_RedFlashing",@"WiFiLight_RedNBlueFlashing"];
            [subTitleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(112, subImageView.bottom+10+idx*25, self.view.width-112, 16)];
                lab.textColor = [UIColor colorWithHexString:@"#333333"];
                lab.font = [UIFont systemFontOfSize:15];
                lab.text = [JfgLanguage getLanTextStrByKey:obj];
                [self.bgScrollerView addSubview:lab];
                
            }];
            
        }else if (idx == 1){
            subImageView.top = 698*0.5;
            titleLabel1.text = [JfgLanguage getLanTextStrByKey:@"WIFI_HINT_LAGEL_2"];
            NSArray *subTitleArr = @[@"PowerLight_SteadyBlue",@"PowerLight_BlueFlashing",@"PowerLight_BlueOut"];
            [subTitleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(112, subImageView.bottom+10+idx*25, self.view.width-112, 16)];
                lab.textColor = [UIColor colorWithHexString:@"#333333"];
                lab.font = [UIFont systemFontOfSize:15];
                lab.text = [JfgLanguage getLanTextStrByKey:obj];
                [self.bgScrollerView addSubview:lab];
                
            }];
            
        }else if (idx == 2){
            subImageView.top = 1030*0.5;
            titleLabel1.text = [JfgLanguage getLanTextStrByKey:@"ChargingLight"];
            NSArray *subTitleArr = @[@"ChargingLight_BlueFlashing",@"ChargingLight_SteadyBlue"];
            [subTitleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(112, subImageView.bottom+10+idx*25, self.view.width-112, 16)];
                lab.textColor = [UIColor colorWithHexString:@"#333333"];
                lab.font = [UIFont systemFontOfSize:15];
                lab.text = [JfgLanguage getLanTextStrByKey:obj];
                [self.bgScrollerView addSubview:lab];
                
            }];
        }
        titleLabel1.top = subImageView.top+1;
        [self.bgScrollerView addSubview:subImageView];
        [self.bgScrollerView addSubview:titleLabel1];
        
    }];
    [self.view addSubview:self.closeBtn];
}

-(void)close:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIScrollView *)bgScrollerView
{
    if (!_bgScrollerView)
    {
        _bgScrollerView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _bgScrollerView.contentSize = CGSizeMake(0, 667);
        _bgScrollerView.backgroundColor = [UIColor whiteColor];
        _bgScrollerView.showsVerticalScrollIndicator = NO;
    }
    return _bgScrollerView;
}

-(UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(0, 43, 25, 25);
        _closeBtn.right = self.view.width-15;
        [_closeBtn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
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
