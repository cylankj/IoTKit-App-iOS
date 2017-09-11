//
//  DeepSleepHelpVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "DeepSleepHelpVC.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "OLImageView.h"
#import "OLImage.h"

@interface DeepSleepHelpVC ()

@property (nonatomic,strong)UIScrollView *bgScroller;

@end

@implementation DeepSleepHelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_HELP"];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)initView
{
    NSArray *titleArr = @[[JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE_ON_OFF"],[JfgLanguage getLanTextStrByKey:@"CALL_SUCCESS_OPEN_SAVE"]];
    CGFloat bottom = 53-15;
    
    for (NSString *title in titleArr) {
        
        UIView *point1 = [[UIView alloc]initWithFrame:CGRectMake(40, bottom+15, 8, 8)];
        point1.layer.masksToBounds = YES;
        point1.layer.cornerRadius = 4;
        point1.backgroundColor = [UIColor colorWithHexString:@"#4B9FD5"];
        [self.bgScroller addSubview:point1];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(63, bottom+15-6, self.view.width-64-40, 20)];
        label1.font = [UIFont systemFontOfSize:15];
        label1.textColor = [UIColor colorWithHexString:@"#333333"];
        label1.text = title;
        [label1 sizeToFit];
        [self.bgScroller addSubview:label1];
        
        bottom = label1.bottom;
    }
    //750 × 660
    OLImageView *_olImageView = [[OLImageView alloc]initWithFrame:CGRectMake(0, bottom+50, self.view.width, self.view.width*66.0/75.0)];
    _olImageView.backgroundColor = [UIColor orangeColor];
    UIImage *image = nil;
    if ([JfgLanguage languageType] == 0) {
        image = [OLImage imageNamed:@"help_powersaving_ch.gif"];
    }else{
        image = [OLImage imageNamed:@"help_powersaving_en.gif"];
    }
//    CGFloat scale = 66.0/75.0;
//    CGFloat imageVcHeight = self.view.width*scale;
//    _olImageView.height = imageVcHeight;
    [_olImageView setImage:image];
    [self.bgScroller addSubview:_olImageView];
    
    UILabel *zhuLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _olImageView.bottom+63, self.view.width, 19)];
    zhuLabel.font = [UIFont systemFontOfSize:14];
    zhuLabel.textAlignment = NSTextAlignmentCenter;
    zhuLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_NOTE"] attributes:nil];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage * smileImage = [UIImage imageNamed:@"icon_prompt"];
    textAttachment.image = smileImage;
    textAttachment.bounds = CGRectMake(0, -4, 19, 19);
    
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [string insertAttributedString:textAttachmentString atIndex:2];
    
    zhuLabel.attributedText = string;
    
    [self.bgScroller addSubview:zhuLabel];
    
    self.bgScroller.contentSize = CGSizeMake(0, zhuLabel.bottom+15);
    [self.view addSubview:self.bgScroller];
}

-(UIScrollView *)bgScroller
{
    if (!_bgScroller) {
        _bgScroller = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _bgScroller.showsVerticalScrollIndicator = NO;
        _bgScroller.backgroundColor = [UIColor whiteColor];
    }
    return _bgScroller;
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
