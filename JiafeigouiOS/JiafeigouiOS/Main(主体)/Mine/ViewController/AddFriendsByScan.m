//
//  AddFriendsByScan.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AddFriendsByScan.h"
#import "JfgGlobal.h"
#import "QRBgView.h"
#import "LoginManager.h"
#import "FriendsInfoVC.h"
#import "FLProressHUD.h"
#import "NSString+FLExtension.h"
#import "JFGEquipmentAuthority.h"
#import "CommonMethod.h"
#import "ProgressHUD.h"
#import "OemManager.h"

@interface AddFriendsByScan ()<JFGSDKCallbackDelegate>
{
    NSString *scanResult;
}
/**
 *  扫码区
 */
@property (nonatomic, strong) QRBgView *scanQRView;

@property (nonatomic, strong) UIView *qrBgView;
/**
 *  二维码 图片
 */
@property (nonatomic, strong) UIImageView *qrImageView;

/**
 *  描述 Label
 */
@property (nonatomic, strong) UILabel *qrDescribLabel;



@end

@implementation AddFriendsByScan

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigationView];
    
    self.scanRect = self.scanQRView.frame;
    self.QRDelegate = self;
    [JFGSDK addDelegate:self];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([JFGEquipmentAuthority canCameraPermission]) {
        [self.scanQRView stopLoading];
        [self openQRCodeScan];
        [self.scanQRView startQRAnimation];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark view
- (void)initView
{
    [self.view addSubview:self.scanQRView];
    [self.view addSubview:self.qrBgView];
    [self.qrBgView addSubview:self.qrImageView];
    [self.view addSubview:self.qrDescribLabel];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
}

- (void)initNavigationView
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_QR"];
}

#pragma action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

#pragma mark QR delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    JFGLog(@"22222");
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
  
    // 3. 设置界面显示扫描结果
    if (metadataObjects.count > 0)
    {
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
            
            [CommonMethod showNetDisconnectAlert];
            return;
        }
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *resultStr = obj.stringValue;
        NSLog(@"%@%@",[NSThread currentThread],resultStr);
        resultStr = [resultStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        resultStr = resultStr.lowercaseString;
        NSRange range = [resultStr rangeOfString:@"id="];
        [self closeQRCodeScan];
        
        
        if (range.location != NSNotFound) {
            
            NSString *accountStr = [resultStr substringFromIndex:range.location+range.length];
            scanResult = accountStr;
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            if ([accountStr isEqualToString:account.account] || [accountStr isEqualToString:account.email] || [accountStr isEqualToString:account.phone]) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_NotYourself"]];
                int64_t delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self openQRCodeScan];
                    
                });
            }else{
                [self.scanQRView stopQRAnimation];
                [self.scanQRView showLoading];
                [JFGSDK checkFriendIsExistWithAccount:accountStr];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAccountOvertime) object:nil];
                [self performSelector:@selector(checkAccountOvertime) withObject:nil afterDelay:10];
            }

            
        }else{
            
            [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"EFAMILY_INVALID_DEVICE"] position:FLProgressHUDPositionCenter];
            [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
            
            int64_t delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self openQRCodeScan];
                
            });
        }
        
        
        
        
        
        
        
    }
}

-(void)checkAccountOvertime
{
    [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"Request_TimeOut"] position:FLProgressHUDPositionCenter];
    [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
    [self openQRCodeScan];
    [self.scanQRView startQRAnimation];
    [self.scanQRView stopLoading];
}


-(void)jfgCheckAccount:(NSString *)account alias:(NSString *)alias isExist:(BOOL)isExist errorType:(JFGErrorType)errorType
{
    if([account isEqualToString:scanResult] ){
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAccountOvertime) object:nil];
        if (isExist) {
            //是好友
            FriendsInfoVC * infoVC = [FriendsInfoVC new];
            infoVC.nickNameLabel.text = account;
            infoVC.nameLabel.text = alias;
            infoVC.friendsInfoType = FriendsInfoIsFriens;
            infoVC.isVerifyFriends = NO;
            infoVC.account = account;
            infoVC.nickNameString = alias;
            [self.navigationController pushViewController:infoVC animated:YES];
            [self.scanQRView stopLoading];
            
        }else{
            //非好友
            if (errorType == 240) {
                
                //未注册
                [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"RET_ELOGIN_ACCOUNT_NOT_EXIST"] position:FLProgressHUDPositionCenter];
                [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
                [self openQRCodeScan];
                [self.scanQRView startQRAnimation];
                [self.scanQRView stopLoading];
                
            }else{
                //已注册
                FriendsInfoVC * infoVC = [FriendsInfoVC new];
                infoVC.nickNameLabel.text = account;
                infoVC.nameLabel.text = alias;
                infoVC.friendsInfoType = FriendsInfoUnFiens;
                infoVC.isVerifyFriends = NO;
                infoVC.account = account;
                infoVC.nickNameString = alias;
                [self.navigationController pushViewController:infoVC animated:YES];
                [self.scanQRView stopLoading];
            }
            
        }
        
        
    }
}




#pragma mark property
/**
 *  扫描区
 *
 *  @return
 */
- (QRBgView *)scanQRView
{
    if (_scanQRView == nil)
    {
        CGFloat widgetWidth = 250.0f*designHscale;
        CGFloat widgetHeight = 250.0f*designHscale;
        CGFloat widgetX = (Kwidth - widgetWidth)*0.5;
        CGFloat widgetY = self.navigationView.height + 65.0f*designHscale;
        _scanQRView = [[QRBgView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        
        CGFloat widgetWidth1 = 204.0f*designHscale;
        CGFloat widgetHeight1 = 204.0f*designHscale;
        CGFloat widgetX1 = (_scanQRView.width - widgetWidth1)*0.5;
        CGFloat widgetY1 = (_scanQRView.height - widgetHeight1)*0.5;
        _scanQRView.centerImageView.frame = CGRectMake(widgetX1, widgetY1, widgetWidth1, widgetHeight1);
        
        CGFloat fontSize = 16.0f;
        _scanQRView.describLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_QR_Tips"];
        _scanQRView.describLabel.font = [UIFont systemFontOfSize:fontSize];
        _scanQRView.describLabel.textColor = [UIColor colorWithHexString:@"#333333"];
//        _scanQRView.describLabel.backgroundColor = [UIColor orangeColor];
//        _scanQRView.backgroundColor = [UIColor orangeColor];
    }
    return _scanQRView;
}

/**
 *  二维码 生成区
 *
 *  @return <#return value description#>
 */

- (UIView *)qrBgView
{
    if (_qrBgView == nil)
    {
        CGFloat widgetWidth = 90.0f*designHscale;
        CGFloat widgetHeight = 90.0f*designHscale;
        CGFloat widgetX = (Kwidth - widgetWidth)*0.5;
        CGFloat widgetY = self.qrDescribLabel.top - 19.0*designHscale - widgetHeight;
        _qrBgView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _qrBgView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _qrBgView.layer.borderWidth = 0.5f;
        _qrBgView.layer.borderColor = [UIColor colorWithHexString:@"#e1e1e1"].CGColor;
        
    }
    return _qrBgView;
}

- (UIImageView *)qrImageView
{
    if (_qrImageView == nil)
    {
        CGFloat widgetWidth = 82.0f*designHscale;
        CGFloat widgetHeight = 82.0f*designHscale;
        CGFloat widgetX = (self.qrBgView.width - widgetWidth)*0.5;
        CGFloat widgetY = (self.qrBgView.height - widgetHeight)*0.5;
        
        _qrImageView = [[UIImageView alloc] initWithImage:[self qrImage]];
        _qrImageView.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
    }
    
    return _qrImageView;
}

-(UIImage *)qrImage
{
    JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
    NSString *content = [NSString stringWithFormat:@"http://www.jfgou.com/app/download.html?id=%@",acc.account];
    if ([OemManager oemType] == oemTypeDoby || [OemManager oemType] == oemTypeCell_C) {
        content = [NSString stringWithFormat:@"id=%@",acc.account];
    }
    UIImage *image = [self qrCodeByAccount:content];
    return image;
}

//生成有关账号信息的二维码
-(UIImage *)qrCodeByAccount:(NSString *)account
{
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据
    NSString *dataString = account;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // 4.通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:82.0f*designHscale];
    
    return  image;
}


- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


- (UILabel *)qrDescribLabel
{
    if (_qrDescribLabel == nil)
    {
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = 16.0;
        CGFloat widgetX = 0;
        CGFloat widgetY = kheight - 63.0*designHscale - widgetHeight+15;
        
        _qrDescribLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _qrDescribLabel.textAlignment = NSTextAlignmentCenter;
        _qrDescribLabel.font = [UIFont systemFontOfSize:widgetHeight];
        _qrDescribLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"];
    }
    
    return _qrDescribLabel;
}



@end
