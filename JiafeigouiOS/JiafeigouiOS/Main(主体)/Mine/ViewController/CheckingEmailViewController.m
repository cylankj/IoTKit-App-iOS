//
//  CheckingEmailViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/2/14.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CheckingEmailViewController.h"
#import "JfgLanguage.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"

@interface CheckingEmailViewController ()

@end

@implementation CheckingEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap0_register_EmailVerification"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)initView
{
    UILabel *label1 = [self factoryLabelWithFrame:CGRectMake(0, 94+64, self.view.bounds.size.width, 16)];
    label1.text = [JfgLanguage getLanTextStrByKey:@"Tap0_AlreadyEmailed"];
    [self.view addSubview:label1];
    
    UILabel *label2 = [self factoryLabelWithFrame:CGRectMake(0, label1.bottom+16+15, self.view.bounds.size.width, 16)];
    label2.text = self.email;
    [self.view addSubview:label2];
    
    UILabel *label3 = [self factoryLabelWithFrame:CGRectMake(0, label2.bottom+16+15, self.view.bounds.size.width, 16)];
    label3.text = [JfgLanguage getLanTextStrByKey:@"Tap0_Click_ActivateAccount"];
    [self.view addSubview:label3];
    
    //[self.backBtn removeTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(UILabel *)factoryLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textColor = [UIColor colorWithHexString:@"#7c7c7c"];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
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
