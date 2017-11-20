//
//  FaceCreateViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FaceCreateViewController.h"
#import "AIRobotRequest.h"
#import "UIImageView+JFGImageView.h"
#import "ProgressHUD.h"
#import "LoginManager.h"

@interface FaceCreateViewController ()<UITextFieldDelegate>
{
    NSString *beginString;
}
@property (nonatomic,strong)UIImageView *headerImageView;
@property (nonatomic,strong)UITextField *nameTextField;
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIButton *doneBtn;
@property (nonatomic,strong)UIButton *cancelBtn;

@end

@implementation FaceCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    beginString = @"";
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_CREATE_BTN"];
    [self.view addSubview:self.bgView];
    self.backBtn.hidden = YES;
    [self.view bringSubviewToFront:self.topBarBgView];
    [self.topBarBgView addSubview:self.doneBtn];
    [self.topBarBgView addSubview:self.cancelBtn];
    [self.bgView addSubview:self.headerImageView];
    [self.bgView addSubview:self.nameTextField];
    [self.bgView addSubview:self.lineView];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNoticeForKeyboard];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeKeyBoradNotifacation];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

-(void)doneAction:(UIButton *)sender
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    
    NSString *name = self.nameTextField.text;
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    __weak typeof(self) weakSelf = self;
    
    if (name.length>0 && self.access_id) {
        [ProgressHUD showProgress:nil];
        
        [AIRobotRequest robotRegisterFace:self.access_id person:nil cid:self.cid personName:name sucess:^(id responseObject) {
            /*
             data = 20171024142319m7TT5TpufzF0p5Nalp;
             msg = ok;
             ret = 0;
             */
            NSLog(@"%@",responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(faceCreateSuccessForIndex:)]) {
                        [weakSelf.delegate faceCreateSuccessForIndex:self.selectedIndexPath];
                    }
                    
                    int64_t delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        if (weakSelf.navigationController && [weakSelf.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }else{
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        }
                        
                        
                    });
                    return ;
                }
                
            }
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_FAIL_TIPS"]];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_FAIL_TIPS"]];
        }];
        
    }
}

#pragma mark - 键盘通知
- (void)addNoticeForKeyboard {
    
    //注册键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //注册键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidBegin) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(void)removeKeyBoradNotifacation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
}


#pragma mark- 键盘监控通知
///键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //获取视图相对于self.view的坐标
    CGRect rc = [self.nameTextField.superview convertRect:self.nameTextField.frame toView:self.view];
    
    CGFloat offset = rc.origin.y+rc.size.height+kbHeight-self.view.height;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.bgView.top = 64-offset-5;
        }];
    }else{
        [UIView animateWithDuration:duration animations:^{
            self.bgView.top = 64;
        }];
    }
        
    
}

///键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.bgView.top = 64;
    }];
}

-(void)textFieldTextDidBegin
{
    beginString = self.nameTextField.text;
    NSLog(@"%@",beginString);
}

-(void)textFieldTextDidChange
{
    CGSize lblSize = [self.nameTextField.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.nameTextField.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.nameTextField.font.pointSize]} context:nil].size;
    NSLog(@"%@",NSStringFromCGSize(lblSize));
    if (lblSize.width+25>self.nameTextField.width) {
        self.nameTextField.text = beginString;
    }else{
        beginString = self.nameTextField.text;
    }
    if (self.nameTextField.text.length>0) {
        self.doneBtn.enabled = YES;
    }else{
        self.doneBtn.enabled = NO;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *resultStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    CGSize lblSize = [resultStr boundingRectWithSize:CGSizeMake(MAXFLOAT, textField.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:textField.font.pointSize]} context:nil].size;
    NSLog(@"%@",NSStringFromCGSize(lblSize));
    if (lblSize.width+25>textField.width && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

-(UIImageView *)headerImageView
{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 116-64, 120, 120)];
        _headerImageView.x = self.view.width*0.5;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.cornerRadius = 60;
        [_headerImageView jfg_setImageWithURL:[NSURL URLWithString:self.headImageUrl] placeholderImage:[UIImage imageNamed:@"news_head128"]];
    }
    return _headerImageView;
}

-(UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 275-64, 200, 20)];
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.x = self.view.width*0.5;
        _nameTextField.textAlignment = NSTextAlignmentCenter;
        _nameTextField.font = [UIFont systemFontOfSize:16];
        _nameTextField.textColor = [UIColor colorWithHexString:@"#666666"];
        _nameTextField.text = @"";
        _nameTextField.delegate = self;
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextField.returnKeyType =  UIReturnKeyDone;
        _nameTextField.placeholder = [JfgLanguage getLanTextStrByKey:@"LOCATION_NAME_ERROR"];
    }
    return _nameTextField;
}

-(UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(20, 305-64, self.view.width-40, 1)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8"];
    }
    return _lineView;
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

////
-(UIButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 32, 60, 20);
        _doneBtn.right = self.view.width-15;
        [_doneBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _doneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.enabled = NO;
    }
    return _doneBtn;
}

-(UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(15, 32, 60, 20);
        [_cancelBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelBtn;
}

-(void)cancelAction:(UIButton *)sender
{
    if (self.navigationController && [self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
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
