//
//  SetDevNicNameViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/16.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SetDevNicNameViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/JFGSDK.h>
#import "JfgLanguage.h"
#import "JFGBoundDevicesMsg.h"

@interface SetDevNicNameViewController ()<UITextFieldDelegate>
{
    NSString *recordText;
}
@property (nonatomic,strong)UILabel *topTipLabel;
@property (nonatomic,strong)UILabel *subTopTipLabel;
@property (nonatomic,strong)UITextField *nameTextFiled;
@property (nonatomic,strong)UIButton *quedingBtn;

@end

@implementation SetDevNicNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.topTipLabel];
    [self.view addSubview:self.subTopTipLabel];
    [self.view addSubview:self.nameTextFiled];
    [self.view addSubview:self.quedingBtn];
    
    
    int pid = -10;
    NSArray *temArr = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    for (JiafeigouDevStatuModel *model in temArr) {
        
        if ([model.uuid isEqualToString:self.cid]) {
            pid = [model.pid intValue];
        }
        
    }
    //4.5.7.17.18.19.20.21.23
    if (pid >0) {
        switch (pid) {
            case 4:
            case 5:
            case 7:
            case 17:
            case 18:
            case 19:
            case 20:
            case 21:
            case 23:{
               self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"];
            }
               break;
                
                
            case 15://门铃：15.22.24
            case 22:
            case 24:{
                self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"];
            }
                break;
                
            default:
                break;
        }
    }
    
    if ([self.cid isKindOfClass:[NSString class]] && self.cid.length>2) {
        
        if ([[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"50"]) {
            self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"];
        }else if([[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"20"]){
            self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"];
        }else{
            
            if (self.pType == productType_DoorBell) {
                 self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"];
            }else{
                 self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"];
            }
            
        }
        
    }else{
        if (self.pType == productType_DoorBell) {
            self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"];
        }else{
            self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"];
        }
    }
    if (self.pType == productType_720) {
        self.nameTextFiled.text = [JfgLanguage getLanTextStrByKey:@"_720PanoramicCamera"];
    }else if (self.pType == productType_IPCam){
        self.nameTextFiled.text = @"IPCam";
    }
    
    // Do any additional setup after loading the view.
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (recordText) {
        self.nameTextFiled.text = recordText;
    }
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)quedingAction
{
    NSString *name = @"";
    if ([self.nameTextFiled.text isEqualToString:@""])
    {
        if ([self.cid isKindOfClass:[NSString class]] && self.cid.length>2) {
            
            switch (self.pType)
            {
                case productType_DoorBell:
                {
                    name = [JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"];
                }
                    break;
                case productType_WIFI:
                default:
                {
                    name = [JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"];
                }
                    break;
            }
            
        }
    }else{
        name = self.nameTextFiled.text;
    }
    if (self.cid) {
        [JFGSDK setAlias:name forCid:self.cid];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"cid:%@ nickName:%@",self.cid,name]];
    }
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
   
    return YES;
}

-(void)textFieldValueChanged:(UITextField *)textField
{
    NSString *lang = [[UITextInputMode currentInputMode]primaryLanguage];//键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) {// 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (textField.text.length >12) {
                textField.text = [textField.text substringToIndex:12];
            }
        }
        //有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    }
    recordText = textField.text;
}


#pragma mark- getter
-(UILabel *)topTipLabel
{
    if (!_topTipLabel) {
        
        _topTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100-6, self.view.width-20, 16+12)];
        _topTipLabel.text = [JfgLanguage getLanTextStrByKey:@"ADD_SUCC_1"];
        _topTipLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _topTipLabel.font = [UIFont systemFontOfSize:27];
        _topTipLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _topTipLabel;
}

-(UILabel *)subTopTipLabel
{
    if (!_subTopTipLabel) {
        
        _subTopTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.topTipLabel.bottom+21, self.view.width-20, 16)];
        _subTopTipLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_SetName"];
        _subTopTipLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _subTopTipLabel.font = [UIFont systemFontOfSize:17];
        _subTopTipLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _subTopTipLabel;
}

-(UITextField *)nameTextFiled
{
    if (!_nameTextFiled) {
        
        _nameTextFiled = [[UITextField alloc]initWithFrame:CGRectMake(20, self.subTopTipLabel.bottom+45, self.view.width-40, 16)];
        _nameTextFiled.delegate = self;
        _nameTextFiled.returnKeyType = UIReturnKeyDone;
        _nameTextFiled.placeholder = [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"];
        _nameTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextFiled.textAlignment = NSTextAlignmentCenter;
        _nameTextFiled.font = [UIFont systemFontOfSize:16];
        _nameTextFiled.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        [_nameTextFiled setValue:[UIColor colorWithHexString:@"#cecece"] forKeyPath:@"_placeholderLabel.textColor"];
        [_nameTextFiled addTarget:self action:@selector(textFieldValueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(_nameTextFiled.left, _nameTextFiled.bottom+6, _nameTextFiled.width, 1)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#cecece"];
        [self.view addSubview:lineView];
        
    }
    return _nameTextFiled;
}

-(UIButton *)quedingBtn
{
    if (!_quedingBtn) {
        _quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _quedingBtn.frame = CGRectMake(0, self.nameTextFiled.bottom+45, 360*0.5, 44);
        _quedingBtn.layer.masksToBounds = YES;
        _quedingBtn.x = self.view.x;
        _quedingBtn.layer.cornerRadius = 22;
        _quedingBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _quedingBtn.layer.borderWidth = 1;
        [_quedingBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_quedingBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
        [_quedingBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        _quedingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_quedingBtn addTarget:self action:@selector(quedingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quedingBtn;
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
