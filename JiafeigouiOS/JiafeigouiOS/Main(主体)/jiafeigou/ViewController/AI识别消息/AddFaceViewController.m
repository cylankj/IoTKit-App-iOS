//
//  AddFaceViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2018/1/25.
//  Copyright © 2018年 lirenguang. All rights reserved.
//

#import "AddFaceViewController.h"
#import "LoginManager.h"
#import "ProgressHUD.h"
#import "PhotoSelectionAlertView.h"
#import "JFGEquipmentAuthority.h"
#import "PickerEditImageViewController.h"
#import "PickerGroupViewController.h"
#import "UIImage+ImageEffects.h"
#import <AFNetworking.h>
#import "AddFaceVSuccessVC.h"
#import "CommonMethod.h"
/**
 注册流程：
 上传图像到OSS —> 注册一个人 —> 绑定这个人与头像
 */

@interface AddFaceViewController ()<UITextFieldDelegate,PhotoSelectionAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,JFGSDKCallbackDelegate,AddFaceVSuccessVCDelegate>
{
    NSString *beginString;
    BOOL isSelectedLocalImage;
    NSString *cloudImageUrl;
    int64_t uploadMark;
    NSString *person_id;
    BOOL uploadImageSucess;//图片上传OSS成功
    NSMutableArray *taskArr;
}
@property (nonatomic,strong)UIImageView *headerImageView;
@property (nonatomic,strong)UILabel *dtLabel;
@property (nonatomic,strong)UITextField *nameTextField;
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIButton *doneBtn;
@property (nonatomic,strong)UIImageView *faceIcon;

@end

@implementation AddFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_REGISTER_FACE"];
    [self showBackBtn];
    beginString = @"";
    taskArr = [NSMutableArray new];
    [self.view addSubview:self.bgView];
    //self.backBtn.hidden = YES;
    [self.view bringSubviewToFront:self.topBarBgView];
    [self.topBarBgView addSubview:self.doneBtn];
    [self.bgView addSubview:self.headerImageView];
    [self.bgView addSubview:self.dtLabel];
    [self.bgView addSubview:self.faceIcon];
    [self.bgView addSubview:self.nameTextField];
    [self.bgView addSubview:self.lineView];
    [self bottomView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editFinishedImage:) name:@"PickerEditFinisehImage" object:nil];
    // Do any additional setup after loading the view.
}

-(void)doneAction
{
    [self.view endEditing:YES];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    
    NSString *name = self.nameTextField.text;
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (name.length>0) {
        
        [ProgressHUD showProgress:nil Interaction:NO];
        //[ProgressHUD showProgress:nil];
        [ProgressHUD cancelTimeout];
        
        [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:60];
        
        if (uploadImageSucess) {
            
            [self registerFace];
        
        }else{
            
            [self uploadImageToClond];
            
        }
    }
    

    
}

-(void)reqTimeout
{
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"REGISTRATION_FAILED"]];
}

-(void)addFaceSucessNextAction
{
    beginString = @"";
    isSelectedLocalImage = NO;
    self.headerImageView.image = [UIImage imageNamed:@"icon_register_face1"];
    cloudImageUrl = @"";
    person_id = @"";
    uploadImageSucess = NO;
    self.doneBtn.enabled = NO;
    self.nameTextField.text = @"";
    self.faceIcon.hidden = YES;
}

//上传图像到oss
-(void)uploadImageToClond
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        return;
    }
    
    
    UIImage *img = self.headerImageView.image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //上传图像
        NSString *imagePath = [self saveImage:img];
        dispatch_async(dispatch_get_main_queue(), ^{
            JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
            NSString *account = acc.account;
            ///long/account/AI/*
            cloudImageUrl = [NSString stringWithFormat:@"/long/%@/AI/%.0f.png",account,[[NSDate date] timeIntervalSince1970]];
            uploadMark = [JFGSDK uploadFile:imagePath toCloudFolderPath:cloudImageUrl];
            
        });
        
    });
}

-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    if (requestID == uploadMark) {
        
        if (ret == 200) {
            uploadImageSucess = YES;
           [self registerFace];
        }else{
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"REGISTRATION_FAILED"]];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        }
        
    }
    
}

//注册人脸
-(void)registerFace
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
         [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        return;
    }
    LoginManager *loginManag = [LoginManager sharedManager];
//    NSMutableDictionary *patameters = [NSMutableDictionary new];
//    [patameters setObject:@"RegisterPerson" forKey:@"action"];
//    [patameters setObject:loginManag.aiReqAuthToken forKey:@"auth_token"];
//    int64_t time = [[NSDate date] timeIntervalSince1970];
//    [patameters setObject:@(time) forKey:@"time"];
//
//    [patameters setObject:self.nameTextField.text forKey:@"person_name"];
//    JFGSDKAcount *acc =[loginManag accountCache];
//    NSString *account = acc.account;
//    [patameters setObject:account forKey:@"account"];
//    [patameters setObject:self.cid forKey:@"cid"];
    NSMutableDictionary *patameters = [NSMutableDictionary new];
    [patameters setObject:@"RegisterByFace" forKey:@"action"];
    [patameters setObject:loginManag.aiReqAuthToken forKey:@"auth_token"];
    int64_t time = [[NSDate date] timeIntervalSince1970];
    [patameters setObject:@(time) forKey:@"time"];
    //去除首尾空格
    NSString *personName = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [patameters setObject:personName forKey:@"person_name"];
    JFGSDKAcount *acc =[loginManag accountCache];
    NSString *account = acc.account;
    [patameters setObject:account forKey:@"account"];
    [patameters setObject:self.cid forKey:@"cid"];
    [patameters setObject:cloudImageUrl forKey:@"image_url"];
    [patameters setObject:@([JFGSDK getRegionType]) forKey:@"oss_type"];
    //NSLog(@"patameters:%@",patameters);
    
    [self afNetWorkingForAIRobotWithUrl:[self reqUrl] patameters:patameters sucess:^(id responseObject) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        NSDictionary *dict = responseObject;
        if ([dict isKindOfClass:[NSDictionary class]]) {
            
            
            NSInteger code = [[dict objectForKey:@"code"] integerValue];
            if (code == 200) {
                
                AddFaceVSuccessVC *vc = [AddFaceVSuccessVC new];
                vc.delegate = self;
                vc.titleText = [JfgLanguage getLanTextStrByKey:@"REGISTRATION_SECCESS"];
                vc.actionText = [JfgLanguage getLanTextStrByKey:@"CONTINUE_REGISTER"];
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{
                
                /*
                 HSRErrCode_NoFace             = 103 //图片未检测到人脸
                 HSRErrCode_FaceSmall          = 104 //人脸太小
                 HSRErrCode_MultiFace          = 105 //多张人脸
                 */
                
                NSString *showMsg = [JfgLanguage getLanTextStrByKey:@"FACE_NOT_RECOGNIZED"];
                if (code == 103) {
                    showMsg = [JfgLanguage getLanTextStrByKey:@"REGFACE_NOFACE"];
                }else if(code == 104){
                    showMsg = [JfgLanguage getLanTextStrByKey:@"REGFACE_FACESMALL"];
                }else if (code == 105){
                    showMsg = [JfgLanguage getLanTextStrByKey:@"REGFACE_MULTIFACE"];
                }
                
                [ProgressHUD showText:showMsg];
                NSString *msg = [dict objectForKey:@"msg"];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"添加人脸失败:{code:%ld,msg:%@}",(long)code,msg]];
            }
            
        }else{
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"FACE_NOT_RECOGNIZED"]];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"添加人脸失败:{msg:数据解析失败}"]];
        }
        
    } failure:^(NSError *error) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"REGISTRATION_FAILED"]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"添加人脸失败:{code:%ld,msg:请求错误}",(long)error.code]];
        
    }];
}

//添加人脸
-(void)addFaceToPerson
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        return;
    }
    LoginManager *loginManag = [LoginManager sharedManager];
    NSMutableDictionary *patameters = [NSMutableDictionary new];
    [patameters setObject:@"AddFace" forKey:@"action"];
    [patameters setObject:loginManag.aiReqAuthToken forKey:@"auth_token"];
    int64_t time = [[NSDate date] timeIntervalSince1970];
    [patameters setObject:@(time) forKey:@"time"];
    [patameters setObject:person_id forKey:@"person_id"];
    [patameters setObject:cloudImageUrl forKey:@"image_url"];
    [patameters setObject:@([JFGSDK getRegionType]) forKey:@"oss_type"];
    [self afNetWorkingForAIRobotWithUrl:[self reqUrl] patameters:patameters sucess:^(id responseObject) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        NSDictionary *dict = responseObject;
        if ([dict isKindOfClass:[NSDictionary class]]) {
            
            
            NSInteger code = [[dict objectForKey:@"code"] integerValue];
            if (code == 200) {
                
                AddFaceVSuccessVC *vc = [AddFaceVSuccessVC new];
                vc.delegate = self;
                vc.titleText = [JfgLanguage getLanTextStrByKey:@"REGISTRATION_SECCESS"];
                vc.actionText = [JfgLanguage getLanTextStrByKey:@"CONTINUE_REGISTER"];
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{
                
                /*
                 HSRErrCode_NoFace             = 103 //图片未检测到人脸
                 HSRErrCode_FaceSmall          = 104 //人脸太小
                 HSRErrCode_MultiFace          = 105 //多张人脸
                 */
                
                NSString *showMsg = [JfgLanguage getLanTextStrByKey:@"FACE_NOT_RECOGNIZED"];
                if (code == 103) {
                   showMsg = [JfgLanguage getLanTextStrByKey:@"REGFACE_NOFACE"];
                }else if(code == 104){
                    showMsg = [JfgLanguage getLanTextStrByKey:@"REGFACE_FACESMALL"];
                }else if (code == 105){
                    showMsg = [JfgLanguage getLanTextStrByKey:@"REGFACE_MULTIFACE"];
                }
                
                [ProgressHUD showText:showMsg];
                NSString *msg = [dict objectForKey:@"msg"];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"添加人脸失败:{code:%ld,msg:%@}",(long)code,msg]];
            }
            
        }else{
             [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"FACE_NOT_RECOGNIZED"]];
             [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"添加人脸失败:{msg:数据解析失败}"]];
        }
        
    } failure:^(NSError *error) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"REGISTRATION_FAILED"]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"添加人脸失败:{code:%ld,msg:请求错误}",(long)error.code]];
        
    }];
}


- (void)afNetWorkingForAIRobotWithUrl:(NSString *)url
                           patameters:(NSDictionary *)parameters
                               sucess:(void (^)(id responseObject))sucess
                              failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"http_ai_success:%@",responseObject);
        if (sucess) {
            sucess(responseObject);
        }
        [taskArr removeObject:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"http_ai_error:%@",error);
        if (failure) {
            failure(error);
        }
        [taskArr removeObject:task];
    }];
    
    [taskArr addObject:task];
}

-(NSString *)reqUrl
{
    /*
     https://yun.jfgou.com:8085/aiappe
     http://yun.jfgou.com:8082/aiapp
     */
    NSString *url = [NSString stringWithFormat:@"http://%@:8082/aiapp",[self reqHost]];
    NSLog(@"url%@",url);
    return url;
}

-(NSString *)reqHost
{
    NSString *jfgServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"_jfg_changedDomain_"];
    if (jfgServer && [jfgServer isKindOfClass:[NSString class]] && ![jfgServer isEqualToString:@""]) {
        
        NSRange range = [jfgServer rangeOfString:@":"];
        if (range.location !=NSNotFound && range.location>1) {
            
            NSString *addr = [jfgServer substringToIndex:range.location];
            return addr;
        }else{
            return @"yun.jfgou.com";
        }
        
    }else{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *addr = [infoDictionary objectForKey:@"Jfgsdk_host"];
        if (!addr || [addr isEqualToString:@""]) {
            addr = @"yun.jfgou.com";
        }
        return addr;
    }
    
    
}

-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)headerTap
{
    [self.view endEditing:YES];
    PhotoSelectionAlertView *actionSheet = [[PhotoSelectionAlertView alloc]initWithMark:@"photo" delegate:self otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"DOOR_CAMERA"],[JfgLanguage getLanTextStrByKey:@"CHOOSE_PHOTOS"],[JfgLanguage getLanTextStrByKey:@"CANCEL"],nil];
    [actionSheet show];
}

-(void)actionSheet:(PhotoSelectionAlertView *)actionSheet mark:(NSString *)mark clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        
        if ([JFGEquipmentAuthority canCameraPermission]) {
            [self pickerController:UIImagePickerControllerSourceTypeCamera];
        }
        
    }else if (buttonIndex == 1){
        
        PickerGroupViewController *group = [[PickerGroupViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:group];
        [self presentViewController:nav animated:YES completion:nil];
        
    }
    
}

-(void)pickerController:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}


#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    image = [image normalizedImage];
    PickerEditImageViewController *edit = [[PickerEditImageViewController alloc ]init];
    edit.image = image;
    edit.sourceType = PickerEditImageSourceTypeCamera;
    [picker pushViewController:edit animated:YES];
    
}

-(void)editFinishedImage:(NSNotification *)notification
{
    isSelectedLocalImage = YES;
    if (![self.nameTextField.text isEqualToString:@""]) {
        self.doneBtn.enabled = YES;
    }else{
        self.doneBtn.enabled = NO;
    }
    UIImage *image = notification.object;
    self.headerImageView.image = image;
    self.faceIcon.hidden = NO;
    //换了头像需要重新上传
    uploadImageSucess = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNoticeForKeyboard];
    [JFGSDK addDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeKeyBoradNotifacation];
    [JFGSDK removeDelegate:self];
    [ProgressHUD dismiss];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    for (NSURLSessionDataTask *task in taskArr) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [task cancel];
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
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
    if (self.nameTextField.text.length>0 && isSelectedLocalImage) {
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
        _headerImageView.image = [UIImage imageNamed:@"icon_register_face1"];
        _headerImageView.userInteractionEnabled = YES;
        _headerImageView.layer.borderColor = [UIColor colorWithHexString:@"#e7e7e7"].CGColor;
        _headerImageView.layer.borderWidth = 0.5;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerTap)];
        [_headerImageView addGestureRecognizer:tap];
    }
    return _headerImageView;
}

-(UIImageView *)faceIcon
{
    if (!_faceIcon) {
        _faceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
        _faceIcon.right = self.headerImageView.right;
        _faceIcon.bottom = self.headerImageView.bottom;
        _faceIcon.image = [UIImage imageNamed:@"tianjia"];
        _faceIcon.hidden = YES;
    }
    return _faceIcon;
}

-(UITextField *)nameTextField
{
    if (!_nameTextField) {
        //241  215
        _nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 275-64, 200, 20)];
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.width = self.view.width-40;
        _nameTextField.top = self.headerImageView.bottom+82;
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
        _lineView.top = self.nameTextField.top+26;
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
        [_doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.enabled = NO;
    }
    return _doneBtn;
}

-(UILabel *)dtLabel
{
    if (!_dtLabel) {
        _dtLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width-40, 21)];
        _dtLabel.top = self.headerImageView.bottom+15;
        _dtLabel.numberOfLines = 0;
        _dtLabel.textAlignment = NSTextAlignmentCenter;
        _dtLabel.font = [UIFont systemFontOfSize:15];
        _dtLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _dtLabel.text = [JfgLanguage getLanTextStrByKey:@"REGISTER_FACE_TIPS"];
        [_dtLabel sizeToFit];
        _dtLabel.x = self.view.width/2;
    }
    return _dtLabel;
}

-(void)bottomView
{
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_positive_face-1"]];
    imageV.top = self.lineView.bottom+50;
    imageV.x = self.view.width/2;
    [self.bgView addSubview:imageV];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 18)];
    label.x = imageV.x;
    label.top = imageV.bottom + 12;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor colorWithHexString:@"#888888"];
    label.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_EXPLAIN"];
    label.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:label];
    
}

#pragma mark- 图像处理
-(NSString *)saveImage:(UIImage *)currentImage
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"AI_header_pic.png"];
    NSData *imageData = [self compressImageQuality:currentImage toByte:2097152];
    [imageData writeToFile:path atomically:YES];// 将图片写入文件
    return path;
}

- (NSData *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    //UIImage *resultImage = [UIImage imageWithData:data];
    return data;
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
