//
//  SetPwForOpenLoginViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SetPwForOpenLoginViewController.h"
#import "JfgLanguage.h"
#import "UIAlertView+FLExtension.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "FLGlobal.h"
#import <Masonry/Masonry.h>
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import "CommonMethod.h"
#import "CheckingEmailViewController.h"
#import "LSAlertView.h"
#import "JfgConstKey.h"

@interface SetPwForOpenLoginViewController ()<UITextFieldDelegate,JFGSDKCallbackDelegate>

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UITextField *pwTextFiled;
@property (strong, nonatomic) UIView * pwTextFieldRightView;

@end

@implementation SetPwForOpenLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initNavigation];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [ProgressHUD dismiss];
}

- (void)leftButtonAction:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_logout_tips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_No"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Yes"] CancelBlock:^{
        
    } OKBlock:^{
        [weakSelf.view endEditing:YES];
        [super leftButtonAction:sender];
    }];
    
}

- (void)rightButtonAction:(UIButton *)sender
{
    if (self.pwTextFiled.text.length<6) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
    }else{
        [ProgressHUD showProgress:nil];
        if (self.isPhoneNumber) {
             [JFGSDK setPassword:self.pwTextFiled.text forType:0 smsToken:self.smsToken];
        }else{
             [JFGSDK setPassword:self.pwTextFiled.text forType:1 smsToken:@""];
        }
    }
}

-(void)jfgSetPasswordForOpenLoginResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            if (!self.isPhoneNumber) {
                CheckingEmailViewController *check = [[CheckingEmailViewController alloc]init];
                check.email = self.smsToken;
                [self.navigationController pushViewController:check animated:YES];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
            //
            
        });
    }else{
        
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        
    }
}

#pragma mark view
- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.deviceNameTextFiled];
    [self.view addSubview:self.pwTextFieldRightView];
}


- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
    
    self.rightButton.hidden = NO;
    self.rightButton.enabled = NO;
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"FINISHED"] forState:UIControlStateNormal];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SET_PWD"];
}

- (UIView *)bgView
{
    if (_bgView == nil)
    {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+20, Kwidth, 44)];
        _bgView.backgroundColor = [UIColor whiteColor];
        [_bgView.layer setBorderColor:[UIColor colorWithHexString:@"#e8e8e8"].CGColor];
        [_bgView.layer setBorderWidth:.5f];
    }
    return _bgView;
}

- (UITextField *)deviceNameTextFiled
{
    if (_pwTextFiled == nil)
    {
        _pwTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(self.bgView.left+15, self.bgView.top, self.bgView.width-50, self.bgView.height)];
        _pwTextFiled.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        _pwTextFiled.delegate = self;
        _pwTextFiled.textColor = [UIColor colorWithHexString:@"#333333"];
        [_pwTextFiled setFont:[UIFont fontWithName:@"PingFangSC" size:16.0f]];
        _pwTextFiled.clearButtonMode = UITextFieldViewModeAlways;
        _pwTextFiled.secureTextEntry = YES;
        
    }
    
    return _pwTextFiled;
}

//创建密码输入框右边控件
-(UIView *)pwTextFieldRightView
{
    if (_pwTextFieldRightView == nil) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(self.bgView.right-40, 0, 35, 35)];
        bgView.y = self.bgView.y;
        UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lockBtn.frame = CGRectMake(0, 0, 35, 35);
        [lockBtn setImage:[UIImage imageNamed:@"lock_btn_noshow password"] forState:UIControlStateNormal];
        [lockBtn setImage:[UIImage imageNamed:@"lock_btn_show password"] forState:UIControlStateSelected];
        lockBtn.adjustsImageWhenHighlighted = NO;
        [lockBtn addTarget:self action:@selector(lockPwAction:) forControlEvents:UIControlEventTouchUpInside];
        lockBtn.selected = NO;
        [bgView addSubview:lockBtn];
        _pwTextFieldRightView = bgView;
    }
    return _pwTextFieldRightView;
}

//密码明文密文切换
-(void)lockPwAction:(UIButton *)sender
{
    NSString *text = _pwTextFiled.text;
    if (sender.selected) {
        self.pwTextFiled.secureTextEntry = YES;
        sender.selected  = NO;
    }else{
        self.pwTextFiled.secureTextEntry = NO;
        self.pwTextFiled.keyboardType = UIKeyboardTypeASCIICapable;
        sender.selected  = YES;
    }
    _pwTextFiled.text= text;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //note：键盘智能输入不会触发此代理方法，这是一个bug吗
    
    //不能输入空字符
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    //禁止输入表情
    if ([[[UITextInputMode currentInputMode] primaryLanguage]         isEqualToString:@"emoji"]) {
        return NO;
    }
    
    NSString *lang = [[UITextInputMode currentInputMode]primaryLanguage];//键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]){
        //禁止中文输入
        return NO;
    }
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (str.length > pwMaxLength) {
        return NO;
    }
    
    if (str.length>0) {
        self.rightButton.enabled = YES;
    }else{
        self.rightButton.enabled = NO;
    }
    return YES;
}

//-(void)textFieldValueChanged:(UITextField *)textField
//{
//    NSString *lang = [[UITextInputMode currentInputMode]primaryLanguage];//键盘输入模式
//    if ([lang isEqualToString:@"zh-Hans"]) {// 简体中文输入，包括简体拼音，健体五笔，简体手写
//        //return NO;
////        UITextRange *selectedRange = [textField markedTextRange];
////        //获取高亮部分
////        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
////        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
////        if (!position) {
////            if (textField.text.length >12) {
////                textField.text = [textField.text substringToIndex:12];
////            }
////        }
////        //有高亮选择的字符串，则暂不对文字进行统计和限制
////        else{
////            
////        }
//    }
//    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//    else{
//        if (textField.text.length >12) {
//            textField.text = [textField.text substringToIndex:12];
//        }
//    }
//}


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
