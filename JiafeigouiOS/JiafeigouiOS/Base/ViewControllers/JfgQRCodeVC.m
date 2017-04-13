//
//  JfgQRCodeVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JfgQRCodeVC.h"
#import "JfgGlobal.h"

NSString *const CIQRCodeGenerator = @"CIQRCodeGenerator";
NSString *const inputMessage = @"inputMessage";
NSString *const inputCorrectionLevel = @"inputCorrectionLevel";

@interface JfgQRCodeVC ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation JfgQRCodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scanRect = [[UIScreen mainScreen] bounds]; // 默认全屏
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)openQRCodeScan
{
    
    if (!self.session) {
        // 1. 摄像头设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // 2. 设置输入
        // 因为模拟器是没有摄像头的，因此在此最好做一个判断
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error)
        {
            JFGLog(@"没有摄像头-%@", error.localizedDescription);
            return;
        }
        // 3. 设置输出(Metadata元数据)
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //    [output setRectOfInterest : CGRectMake ((self.scanRect.size.height)/kheight ,((Kwidth-234)*0.5)/Kwidth , 234/SCREEN_SIZE.height , 234/SCREEN_SIZE.width)];
        
        // 3.1 设置输出的代理
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // 4. 拍摄会话
        self.session = [[AVCaptureSession alloc] init];
        // 添加session的输入和输出
        [self.session addInput:input];
        [self.session addOutput:output];
        
        // 4.1 设置输出的格式
        // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
        [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        
        // 5. 设置预览图层（用来让用户能够看到扫描情况）
        self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        
        // 5.1 设置preview图层的属性
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        // 5.2 设置preview图层的大小
        [self.videoPreviewLayer setFrame:self.scanRect];
        
        // 5.3 将图层添加到视图的图层
        [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    }
    // 6. 启动会话
    [self.session startRunning];
}

- (void)closeQRCodeScan
{
    [self.session stopRunning];
}

- (CIImage *)createQRCodeCIImageWithStr:(NSString *)codeStr
{
    NSData *stringData = [codeStr dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:CIQRCodeGenerator];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:inputMessage];
    [qrFilter setValue:@"M" forKey:inputCorrectionLevel];
    // 返回CIImage
    return qrFilter.outputImage;
    
    return nil;
}

#pragma mark delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self closeQRCodeScan];
    
    if ([self.QRDelegate respondsToSelector:@selector(captureOutput:didDropSampleBuffer:fromConnection:)])
    {
        [self.QRDelegate captureOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection];
    }
}

@end
