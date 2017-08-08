//
//  QRViewController.m
//  JiafeigouIOS
//
//  Created by lirenguang on 15/8/17.
//  Copyright (c) 2015年 liao tian. All rights reserved.
//

#import "QRViewController.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "QRViewModel.h"
#import "FLGlobal.h"
#import "FLLog.h"
#import "JFGEquipmentAuthority.h"
#import "ProgressHUD.h"
#import "AddDeviceGuideViewController.h"

@interface QRViewController ()<QRVMDelegate>
{
    BOOL isPushed;
}
@property (nonatomic, retain) AVCaptureSession * session;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer * videoPreviewLayer;

@property (strong, nonatomic) QRBgView *qrView;
@property (strong, nonatomic) UIView *topNavView; // 顶部导航View

// 数据处理
@property (strong, nonatomic) QRViewModel *qrViewModel;

@end

@implementation QRViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
    
    // 权限处理 处
    if ([JFGEquipmentAuthority canCameraPermission]) {
        [self readQRcode];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_session startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [self.view addSubview:self.qrView];
    [self.view addSubview:self.topNavView];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, (44-30)/2.0 + 20, 30, 30);
    [backButton setBackgroundImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, Kwidth - 60*2, 44)];
    titleLabel.alpha = 1.0f;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [JfgLanguage getLanTextStrByKey:@"DEVICES_TITLE"];
    titleLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.view addSubview:titleLabel];
}


#pragma mark action
-(void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 读取二维码
- (void)readQRcode
{
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入
    // 因为模拟器是没有摄像头的，因此在此最好做一个判断
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
//        JFGLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
    // 3. 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
//    [output setRectOfInterest : CGRectMake ((104)/SCREEN_SIZE.height ,((SCREEN_SIZE.width-234)/2)/ SCREEN_SIZE.width , 234/SCREEN_SIZE.height , 234/SCREEN_SIZE.width)];
    
    // 3.1 设置输出的代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 拍摄会话
    _session = [[AVCaptureSession alloc] init];
    // 添加session的输入和输出
    [_session addInput:input];
    [_session addOutput:output];
    
    // 4.1 设置输出的格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    // 5.1 设置preview图层的属性
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // 5.2 设置preview图层的大小
    [_videoPreviewLayer setFrame:CGRectMake(0, 0, Kwidth, kheight)];
    
    // 5.3 将图层添加到视图的图层
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    // 6. 启动会话
    [_session startRunning];
}

#pragma mark -- setter
- (QRBgView *)qrView
{
    if (_qrView == nil)
    {
        _qrView = [[QRBgView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _qrView.backgroundColor = [UIColor clearColor];
    }
    
    return _qrView;
}

- (UIView *)topNavView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 44 + 20;
    CGFloat widgetX = 0;
    CGFloat widgetY = 0;
    
    if (_topNavView == nil)
    {
        _topNavView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _topNavView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        _topNavView.alpha = 0.45;
    }
    
    return _topNavView;
}

- (QRViewModel *)qrViewModel
{
    if (_qrViewModel == nil)
    {
        _qrViewModel = [[QRViewModel alloc] init];
        _qrViewModel.vmDelegate = self;
    }
    return _qrViewModel;
}

#pragma mark
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [self.session stopRunning];
    
    // 2. 删除预览图层
    if (self.videoPreviewLayer)
    {
        //[self.videoPreviewLayer removeFromSuperlayer];
    }
    
    // 3. 设置界面显示扫描结果
    if (metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *resultStr = obj.stringValue;
        
        if ([self.qrViewModel requestWithString:resultStr] == NO) {
            
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self.session startRunning];
                
            });
            
        }
        
    }
}

#pragma mark VMDelegate
- (void)QRScanDidFinished:(QRReustType)resultType forPid:(NSString *)pid
{
    switch (resultType)
    {
        case QRReustTypeSuccess:
        {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Added_successfully"]];
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            });
            
        }
            break;
            
        case QRReustTypeError:
        {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_QR_Fail"]];
            [self performSelector:@selector(backButtonAction:) withObject:nil afterDelay:1.0];
        }
            break;
        case QRReustTypeInvalidQRCode:
        {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EFAMILY_INVALID_DEVICE"]];
            [self performSelector:@selector(backButtonAction:) withObject:nil afterDelay:2.0];
        }
            break;
            
        case QRReustTypeFailed:{
            [self.session startRunning];
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_ECID_UNBIND"]];
        }
            break;
        case QRReustTypeBinded:{
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_AddedDeviceTips"]];
            [self performSelector:@selector(backButtonAction:) withObject:nil afterDelay:2.0];
        }
            break;
        default:{
            
            AddDevConfigModel *model = nil;
            NSArray *cofigArr = [jfgConfigManager getAllDevModel];
            
            for (NSArray *subArr in cofigArr) {
                for (AddDevConfigModel *m in subArr) {
                    
                    for (NSNumber *_pid in m.osList) {
                        
                        if ([_pid integerValue] == [pid integerValue]) {
                            model = m;
                            break;
                        }
                        
                    }
                    
                }
            }
            
            if (model && !isPushed) {
                
                isPushed = YES;
                AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
                addDeviceGuide.pType = (productType)[pid intValue];
                addDeviceGuide.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addDeviceGuide animated:YES];
            
            }
            
            
        }
            break;
    }
    
    //
}

@end
