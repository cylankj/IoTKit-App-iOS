


//
//  ForgetEmailPasswordViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ForgetEmailPasswordViewController.h"
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"

@interface ForgetEmailPasswordViewController ()

@property (nonatomic,strong)UIButton *exitBtn;
@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UILabel *declareLabel;
@property (nonatomic,strong)UILabel *declareLabel2;
@property (nonatomic,strong)UILabel *declareLabel3;
@property (nonatomic,strong)UIButton *querenBtn;

@end

@implementation ForgetEmailPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
   
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.declareLabel];
    [self.view addSubview:self.declareLabel2];
    [self.view addSubview:self.declareLabel3];
    [self.view addSubview:self.querenBtn];
    if (self.type == EmailCheckTypeForgetPassword) {
        [self.view addSubview:self.exitBtn];
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap0_register_EmailVerification"];
    }
    // Do any additional setup after loading the view.
}

-(UIButton *)exitBtn
{
    if (!_exitBtn) {
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(10-2, 130/2-5-2, 33+4, 33+4);
        [_exitBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.width-150)*0.5, 130*0.5, 150, 23)];
        _titleLabel.font = [UIFont systemFontOfSize:23];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#444444"];
        _titleLabel.text= [JfgLanguage getLanTextStrByKey:@"EMAIL"];
    }
    return _titleLabel;
}

-(UILabel *)declareLabel
{
    if (!_declareLabel) {
        _declareLabel = [self factoryLabel:CGRectMake(20, self.titleLabel.bottom+70, self.view.width-40, 20) text:[JfgLanguage getLanTextStrByKey:@"Tap0_AlreadyEmailed"]];
    }
    return _declareLabel;
}



-(UILabel *)declareLabel2
{
    if (!_declareLabel2) {
        _declareLabel2 = [self factoryLabel:CGRectMake(20, self.declareLabel.bottom+15, self.view.width-40, 20) text:self.email];
        _declareLabel2.font = [UIFont boldSystemFontOfSize:_declareLabel2.font.pointSize];
    }
    return _declareLabel2;
}

-(UILabel *)declareLabel3
{
    if (!_declareLabel3) {
        _declareLabel3 = [self factoryLabel:CGRectMake(20, self.declareLabel2.bottom+15, self.view.width-40, 20) text:[JfgLanguage getLanTextStrByKey:@"Tap0_Click_ResetPassword"]];
        if (self.type == EmailCheckTypeCheckEmailTip) {
            _declareLabel3.text = [JfgLanguage getLanTextStrByKey:@"Tap0_Click_ActivateAccount"];
        }
    }
    return _declareLabel3;
}

-(UILabel *)factoryLabel:(CGRect)frame text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithHexString:@"#7c7c7c"];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    return label;
}

-(UIButton *)querenBtn
{
    if (!_querenBtn) {
        
        _querenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _querenBtn.frame = CGRectMake(0, self.declareLabel3.bottom+40, 360*0.5, 44);
        _querenBtn.layer.masksToBounds = YES;
        _querenBtn.x = self.view.x;
        _querenBtn.layer.cornerRadius = 22;
        _querenBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _querenBtn.layer.borderWidth = 1;
        [_querenBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_querenBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
        if (self.type == EmailCheckTypeCheckEmailTip) {
            [_querenBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_register_GoToLogin"] forState:UIControlStateNormal];
        }
        _querenBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_querenBtn addTarget:self action:@selector(querenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _querenBtn;
}

-(void)querenAction
{
    if (self.type == EmailCheckTypeCheckEmailTip) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginViewTransformLoginView" object:nil];
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)exitAction
{
    if (self.navigationController.viewControllers>0) {
        UIViewController *fristView = [self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToViewController:fristView animated:YES];
    }
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
