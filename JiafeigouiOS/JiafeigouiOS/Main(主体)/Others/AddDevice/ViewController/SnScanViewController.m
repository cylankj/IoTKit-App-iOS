//
//  SnScanViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/10.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "SnScanViewController.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "FLGlobal.h"
#import "JfgLanguage.h"
#import "jfgConfigManager.h"
#import "ProgressHUD.h"
#import "AddDeviceGuideViewController.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import "JFGBoundDevicesMsg.h"

@interface SnScanViewController ()<UITextFieldDelegate,JFGSDKCallbackDelegate>

@property (strong, nonatomic)UITextField *_textField;
@property (strong, nonatomic)UIButton *doneBtn;
@property (strong, nonatomic)NSArray *configArr;

@end

@implementation SnScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
    [self._textField becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [super viewWillDisappear:animated];
}

-(void)doneAction
{
    if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
        
    }else{
        
        
        if (self._textField.text.length >= 12) {
            
            NSArray *devArr = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
            for (JiafeigouDevStatuModel *devModel in devArr) {
                
                if ([devModel.uuid isEqualToString:self._textField.text]) {
                    
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DEVICE_EXISTED"]];
                    return;
                }
                
            }
            
            [ProgressHUD showProgress:nil];
            [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:self._textField.text error:nil] cid:@"" forMsgID:1];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
            [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:3];
            
        }else{
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ERROR_S/N"]];
        }
        
    }
}

-(void)reqTimeout
{
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ADD_FAILED"]];
}

-(void)jfgOnUniversalData:(NSData *)msgData msgID:(int)mid seq:(long)seq
{
    if (![msgData isKindOfClass:[NSData class]]) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSNumber class]]) {
    
        int os = [obj intValue];
        for (NSArray *subArr in self.configArr) {
            for (AddDevConfigModel *model in subArr) {

                for (NSNumber *_os in model.osList) {

                    if (os == [_os intValue]) {
                        
                        [ProgressHUD dismiss];
                        AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
                        addDeviceGuide.pType = (productType)[_os intValue];
                        [self.navigationController pushViewController:addDeviceGuide animated:YES];
                        return;
                    }
                }
            }
        }
    }
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ERROR_S/N"]];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) {
        return NO;
    }else{
        
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (str.length>=12) {
            self.doneBtn.enabled = YES;
            if (str.length>20) {
                return NO;
            }
        }else{
            self.doneBtn.enabled = NO;
        }
        
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.doneBtn.enabled = NO;
    return YES;
}

-(void)initView
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 37, 30, 30);
    
    [backButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 104, Kwidth - 60*2, 29)];
    titleLabel.alpha = 1.0f;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Add_Device_S/N"];
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    titleLabel.font = [UIFont systemFontOfSize:27.0f];
    [self.view addSubview:titleLabel];
    
    [self.view addSubview:self._textField];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(20, self._textField.bottom+8, self.view.width-40, 1)];
    lineView.backgroundColor =[UIColor colorWithHexString:@"#e8e8e8"];
    lineView.height = 1;
    [self.view addSubview:lineView];
    
    [self.view addSubview:self.doneBtn];
}

-(NSArray *)configArr
{
    if (!_configArr) {
        _configArr = [jfgConfigManager getAllDevModel];
    }
    return _configArr;
}

-(UITextField *)_textField
{
    if (!__textField) {
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 197, self.view.width-40, 25)];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.placeholder = [JfgLanguage getLanTextStrByKey:@"Add_Device_ENTER_S/N"];
        textField.font = [UIFont systemFontOfSize:16];
        textField.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        [textField setValue:[UIColor colorWithHexString:@"#cecece"] forKeyPath:@"_placeholderLabel.textColor"];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        __textField = textField;
    }
    return __textField;
}

-(UIButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 272, 180, 44);
        _doneBtn.layer.masksToBounds = YES;
        _doneBtn.x = self.view.x;
        _doneBtn.layer.cornerRadius = 22;
        _doneBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _doneBtn.layer.borderWidth = 1;
        [_doneBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_doneBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        //_doneBtn.selected = YES;
        _doneBtn.enabled = NO;
    }
    return _doneBtn;
}

-(void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
