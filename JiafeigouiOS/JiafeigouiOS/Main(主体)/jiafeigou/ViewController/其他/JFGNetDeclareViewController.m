//
//  JFGNetDeclareViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/9.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGNetDeclareViewController.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"
#import "FLGlobal.h"

@interface JFGNetDeclareViewController ()

@property (nonatomic,strong)UIScrollView *bgScrollerView;

@end

@implementation JFGNetDeclareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)initView
{
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Network_Description"];
    [self.view addSubview:self.bgScrollerView];
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, self.view.width-30, 16)];
    tLabel.font = [UIFont systemFontOfSize:14];
    tLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    tLabel.text = [JfgLanguage getLanTextStrByKey:@"Unconnect_Network"];
    tLabel.textAlignment = NSTextAlignmentLeft;
    [self.bgScrollerView addSubview:tLabel];
    
    NSArray *contArr = @[@[@"set_con_wifi",@"Wifi_Method",@"Wifi_Hotspot"],@[@"set_icon_3g",@"Cellular_Data_Method",@"Cellular_Data_Set_Up"]];
    int i =0;
    for (NSArray *tArr in contArr) {
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 45+i*127, self.view.width, 107)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.bgScrollerView addSubview:bgView];
        
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, 30, 30)];
        headImageView.image = [UIImage imageNamed:tArr[0]];
        [bgView addSubview:headImageView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(headImageView.right+10, 7, self.view.width-60, 30)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        titleLabel.text = [JfgLanguage getLanTextStrByKey:tArr[1]];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:titleLabel];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 52, self.view.width-30, 74*0.5+8)];
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        contentLabel.text = [JfgLanguage getLanTextStrByKey:tArr[2]];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.numberOfLines = 2;
        
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paraStyle.alignment = NSTextAlignmentLeft;
        paraStyle.lineSpacing = 5; //设置行间距
       
        //设置字间距 NSKernAttributeName:@1.5f
        NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:[JfgLanguage getLanTextStrByKey:tArr[2]] attributes:dic];
        contentLabel.attributedText = attributeStr;
        [bgView addSubview:contentLabel];
        
        for (int i=0; i<3; i++) {
            
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
            lineView.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
            if (i==0) {
                lineView.top = 0;
            }else if (i==1){
                lineView.top = 44;
                lineView.left = 18;
                lineView.width = self.view.width - 18;
            }else{
                lineView.top = bgView.height-0.5;
            }
            [bgView addSubview:lineView];
            
        }
        
        i++;
    }
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    setBtn.frame = CGRectMake(0, 682/2-44, self.view.width, 44);
    setBtn.backgroundColor = [UIColor whiteColor];
    [setBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Wifi_Set_Up"] forState:UIControlStateNormal];
    [setBtn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    setBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [setBtn addTarget:self action:@selector(setBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollerView addSubview:setBtn];
    
}

-(void)setBtnAction
{
    //prefs:root=WIFI
    if (IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(10.0)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=root"] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=root"]];
    }
}

-(UIScrollView *)bgScrollerView
{
    if (!_bgScrollerView) {
        _bgScrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _bgScrollerView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        if (self.view.height-64<682/2) {
            _bgScrollerView.contentSize = CGSizeMake(self.view.width, 682/2);
        }
    }
    return _bgScrollerView;
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
