//
//  WebChatBindViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/13.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "WebChatBindViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "JFGAlbumManager.h"
#import "JfgConfig.h"

@interface WebChatBindViewController ()

@property (nonatomic,strong)UIScrollView *bgScrollerView;

@end

@implementation WebChatBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Start_instructions"];
    [self initView];
        // Do any additional setup after loading the view.
}

//创建坑爹的界面
-(void)initView
{
    UILabel *label1 = [self factoryLabelForFrame:CGRectMake(15, 20, self.view.width-30, 50) font:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexString:@"#333333"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_A"]];
    [self.bgScrollerView addSubview:label1];
    
    UILabel *label2 = [self factoryLabelForFrame:CGRectMake(15, label1.bottom+20, self.view.width-30, 50) font:[UIFont systemFontOfSize:15] textColor:[UIColor colorWithHexString:@"#666666"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_B"]];
    [self.bgScrollerView addSubview:label2];
    
    UILabel *label3 = [self factoryLabelForFrame:CGRectMake(15, label2.bottom+16, self.view.width-30, 50) font:[UIFont systemFontOfSize:16] textColor:[UIColor colorWithHexString:@"#333333"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_C"]];
    [self.bgScrollerView addSubview:label3];
    
    UILabel *label4 = [self factoryLabelForFrame:CGRectMake(15, label3.bottom+13, self.view.width-30, 50) font:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexString:@"#333333"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_D"]];
    [self.bgScrollerView addSubview:label4];
    
    UILabel *label5 = [self factoryLabelForFrame:CGRectMake(15, label4.bottom+13, self.view.width-30, 50) font:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexString:@"#333333"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_E"]];
    [self.bgScrollerView addSubview:label5];
    
    UIImageView *QRImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, label5.bottom+33, 370*0.5, 370*0.5)];
    QRImageView.x = self.view.width*0.5;
    QRImageView.image = [UIImage imageNamed:@"pic_erweima"];
    [self.bgScrollerView addSubview:QRImageView];
//    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longAction)];
//    longGesture.minimumPressDuration = 1;
//    QRImageView.userInteractionEnabled = YES;
//    [QRImageView addGestureRecognizer:longGesture];
    
    UILabel *label6 = [self factoryLabelForFrame:CGRectMake(15, QRImageView.bottom+33, self.view.width-30, 50) font:[UIFont systemFontOfSize:16] textColor:[UIColor colorWithHexString:@"#333333"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_F"]];
    [self.bgScrollerView addSubview:label6];
    
    UILabel *label7 = [self factoryLabelForFrame:CGRectMake(15, label6.bottom+13, self.view.width-30, 50) font:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexString:@"#333333"] text:[JfgLanguage getLanTextStrByKey:@"Start_instructions_G"]];
    [self.bgScrollerView addSubview:label7];
    
    self.bgScrollerView.contentSize = CGSizeMake(self.view.width, label7.bottom + 64+20);
    
}

-(void)longAction
{
//    [JFGAlbumManager jfgWriteImage:[UIImage imageNamed:@"pic_erweima"] toPhotosAlbum:nil completionHandler:^(UIImage *image, NSError *error) {
//        NSLog(@"保存成功");
//    }];
}

-(UILabel *)factoryLabelForFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = font;
    label.textColor = textColor;
    label.text = text;
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

-(UIScrollView *)bgScrollerView
{
    if (!_bgScrollerView) {
        _bgScrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height)];
        _bgScrollerView.backgroundColor = [UIColor whiteColor];
        _bgScrollerView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_bgScrollerView];
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
