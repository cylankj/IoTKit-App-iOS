//
//  RegionalizationViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/20.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "RegionalizationViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "FLGlobal.h"
#import <pop/POP.h>
#import "JFGDraggableView.h"
#import "FLLabel.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import "UIImageView+WebCache.h"
#import "ProgressHUD.h"
#import "JfgCachePathManager.h"
#import "LoginManager.h"
#import "CommonMethod.h"

#define AreaDetectionTipMask @"AreaDetectionTipMask_"
#define AreaDetectionSnapSaveKey @"AreaDetectionSnapSaveKey_"

struct CLRect {
    CGFloat ltx;//左上x
    CGFloat lty;//左上y
    CGFloat rbx;//右下x
    CGFloat rby;//右下y
};

@interface RegionalizationViewController ()
{
    struct CLRect areaDetectionRect;//区域侦测范围
    CGSize snapSize;
    UIImage *realTimeSnapImg;
    BOOL isAppear;
}
@property (nonatomic,strong)UIButton *backBtn;//返回
@property (nonatomic,strong)UIButton *doneBtn;//完成按钮
@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)UIView *maskView;//加载动画蒙版
@property (nonatomic,strong)UIImageView *loadingImageView;//加载动画视图
@property (nonatomic,strong)JFGDraggableView *draggableView;//划区域视图
@property (nonatomic,strong)UIView *openDetectView;//点击开始侦测视图
@property (nonatomic,strong)UIButton *detectDefaultBtn;//默认按钮
@property (nonatomic,strong)UIView *tipView;//tip视图

@end

@implementation RegionalizationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //获取实时截图
    [self reqSnampImage];
    [self reqOriginRect];
    
    //初始化坐标
    snapSize = CGSizeMake(self.view.height, self.view.width);
    CGRect tempRect = CGRectMake(0, 0, 209, 139);
    tempRect.origin.x = self.view.center.x - tempRect.size.width*0.5;
    tempRect.origin.y = self.view.center.y - tempRect.size.height * 0.5;
    [self transitionAreaProportionWithSnapSize:snapSize detectionRect:tempRect];
    
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.maskView];
    self.draggableView.hidden = YES;
    [self.maskView addSubview:self.draggableView];
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.doneBtn];
    
    //加号
    self.openDetectView.hidden = YES;
    self.detectDefaultBtn.hidden = YES;
    [self.view addSubview:self.detectDefaultBtn];
    [self.view addSubview:self.openDetectView];
    
    //开始加载动画
    [self startLoadingAnimation];
    
    //加载本地缓存过得图片
    [self loadDiskImage];
    
    //加载截图超时处理
    [self performSelector:@selector(snapLoadFailed) withObject:nil afterDelay:30];

}

//坐标转化成比例
-(void)transitionAreaProportionWithSnapSize:(CGSize)size detectionRect:(CGRect)detectionRect
{
    CGRect tempRect = detectionRect;
    areaDetectionRect.ltx = tempRect.origin.x / size.width;
    areaDetectionRect.lty = tempRect.origin.y / size.height;
    areaDetectionRect.rbx = (tempRect.origin.x+tempRect.size.width) / size.width;
    areaDetectionRect.rby = (tempRect.origin.y+tempRect.size.height) / size.height;
}

//获取实时截图
-(void)reqSnampImage
{
    DataPointSeg *seg = [[DataPointSeg alloc]init];
    seg.msgId = 521;
    seg.version = 0;
    seg.value = [MPMessagePackWriter writeObject:@YES error:nil];
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotDataWithPeer:self.cid action:41 dps:@[seg] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        if (!isAppear) {
            return ;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(snapLoadFailed) object:nil];
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                if (seg.msgId  == 522) {
                    
                    NSArray *obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSArray class]] && obj .count>2) {
                        
                        int ret = [[obj objectAtIndex:0] intValue];
                        if (ret == 0) {
                           
                            int ossType = [[obj objectAtIndex:1] intValue];
                            int64_t time = [[obj objectAtIndex:2] longLongValue];
                            NSString *fileName = [NSString stringWithFormat:@"/%@/tmp/%lld.jpg",self.cid,time];
                            
                            [weakSelf loadSnapImageForFileName:fileName ossType:ossType];
                            
                        }else{
                            [weakSelf snapLoadFailed];
                        }
                        
                    }else{
                       [weakSelf snapLoadFailed];
                    }
                    
                    
                }
                
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        [weakSelf snapLoadFailed];
    }];
}

//获取实时截图失败
-(void)snapLoadFailed
{
    if (realTimeSnapImg == nil) {

        [self stopLoadingAnimation];
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertCtrol = [UIAlertController alertControllerWithTitle:[JfgLanguage getLanTextStrByKey:@"DETECTION_AREA_FAILED_LOAD_RETRY"] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[JfgLanguage getLanTextStrByKey:@"OK"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

            [weakSelf backAction];

        }];

        [alertCtrol addAction:action];
        [self presentViewController:alertCtrol animated:YES completion:nil];

    }else{
    
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DETECTION_AREA_FAILED_LOAD"]];
        if (self.isOpenAreaDetection) {
            [self setState];
        }else{
            [self defaultState];
        }
        
    }
}

//根据实时图调整控件尺寸
-(void)layouForSnapImage:(UIImage *)image
{
    CGFloat width = self.view.width;
    CGFloat height = self.view.height;
    if (width<height) {
        width = self.view.height;
        height = self.view.width;
    }
    self.backgroundImageView.image = image;
    
    CGFloat scale = image.size.height/image.size.width;
    snapSize.height = height;
    snapSize.width = height/scale;
    if (snapSize.width > width) {
        snapSize.width = width;
        snapSize.height = width * scale;
    }
    
    self.backgroundImageView.width = snapSize.width;
    self.backgroundImageView.height = snapSize.height;
    self.backgroundImageView.center = CGPointMake(width*0.5, height*0.5);
    
    self.maskView.frame = self.backgroundImageView.frame;
    
    CGFloat x = areaDetectionRect.ltx * snapSize.width;
    CGFloat y = areaDetectionRect.lty * snapSize.height;
    CGFloat width1 = areaDetectionRect.rbx * snapSize.width - x;
    CGFloat height1 = areaDetectionRect.rby * snapSize.height - y;
    self.draggableView.frame = CGRectMake(x, y, width1, height1);
}

//图片链接加载
-(void)loadSnapImageForFileName:(NSString *)fileName ossType:(int)ossType
{
    __weak typeof(self) weakSelf = self;
    NSString *imageUrl = [JFGSDK getCloudUrlWithFlag:ossType fileName:fileName];
    
    [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:realTimeSnapImg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!error) {
            
            [weakSelf saveImgToDisk:image];
            [weakSelf layouForSnapImage:image];
            if (self.isOpenAreaDetection) {
                [weakSelf setState];
            }else{
                [weakSelf defaultState];
            }
            
        }else{
            NSLog(@"%@",error.description);
            [weakSelf snapLoadFailed];
        }
        
    }];
}

//获取设置状态
-(void)reqOriginRect
{
    //__weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@519] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                if (seg.msgId == 519) {
                    
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSArray class]]) {
                        
                        NSArray *sourceArr = obj;
                        if (sourceArr.count>1) {
                            self.isOpenAreaDetection = [sourceArr[0] boolValue];
                            NSArray *rects = sourceArr[1];
                            if ([rects isKindOfClass:[NSArray class]] && rects.count>0) {
                                
                                NSArray *rect = rects[0];
                                if ([rect isKindOfClass:[NSArray class]] && rect.count>3) {
                                    areaDetectionRect.ltx = [rect[0] floatValue];
                                    areaDetectionRect.lty = [rect[1] floatValue];
                                    areaDetectionRect.rbx = [rect[2] floatValue];
                                    areaDetectionRect.rby = [rect[3] floatValue];
                                }
                                
                                
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
        
        
    }];
}

-(void)setRectToServer
{
    
}

//默认状态,未打开区域侦测状态
-(void)defaultState
{
    self.draggableView.hidden = YES;
    self.detectDefaultBtn.hidden = YES;
    self.tipView.hidden = YES;
    self.openDetectView.hidden = NO;
    self.doneBtn.enabled = YES;
    [self stopLoadingAnimation];
}

//开启区域侦测设置状态
-(void)setState
{
    self.openDetectView.hidden = YES;
    self.draggableView.hidden = NO;
    self.detectDefaultBtn.hidden = NO;
    self.doneBtn.enabled = YES;
    [self stopLoadingAnimation];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:AreaDetectionTipMask]) {
        [self showTip];
    }
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 10, 30, 30);
        [_backBtn setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 14, 50, 30);
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _doneBtn.right = self.view.height - 10;
        [_doneBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
        CGSize maxSize = CGSizeOfString([JfgLanguage getLanTextStrByKey:@"SAVE"], CGSizeMake(1000, 30), [UIFont systemFontOfSize:16]);
        _doneBtn.width = maxSize.width;
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        _doneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.enabled = NO;
    }
    return _doneBtn;
}

-(void)doneAction
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    [ProgressHUD showProgress:nil];
    [self transitionAreaProportionWithSnapSize:snapSize detectionRect:self.draggableView.frame];
    DataPointSeg *seg = [DataPointSeg new];
    seg.msgId = 519;
    
    
    //最高保留三位小数
    seg.value = [MPMessagePackWriter writeObject:@[@(self.isOpenAreaDetection),
        @[@[
              @(floorf(areaDetectionRect.ltx*1000) / 1000),@(floorf(areaDetectionRect.lty*1000) / 1000),@(floorf(areaDetectionRect.rbx*1000) / 1000),@(floorf(areaDetectionRect.rby*1000) / 1000)]]] error:nil];
    
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
        for (DataPointIDVerRetSeg *seg in dataList) {
            
            if (seg.ret == 0) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PWD_OK_2"]];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(updateAreaDetection)]) {
                    [self.delegate updateAreaDetection];
                }
                
                int64_t delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [weakSelf backAction];
                    
                });
                
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
            }
            break;
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
        
    }];
}

-(void)addDragAction
{
    self.isOpenAreaDetection = YES;
    [self setState];
}

-(void)detectDefaultAction
{
    self.isOpenAreaDetection = NO;
    [self defaultState];
    [self closeTip];
}

-(void)showTip
{
    if (self.tipView.superview == nil) {
        [self.view addSubview:self.tipView];
    }
    self.tipView.alpha = 1;
    self.tipView.hidden = NO;
}

-(void)closeTip
{
    if (self.tipView.hidden) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.tipView.alpha = 0;
    } completion:^(BOOL finished) {
        self.tipView.hidden = YES;
    }];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AreaDetectionTipMask];
}

-(void)startLoadingAnimation
{
    [self stopLoadingAnimation];
    [self.view addSubview:self.loadingImageView];
    
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    //baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [self.loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopLoadingAnimation
{
    if (self.loadingImageView.superview) {
        [self.loadingImageView removeFromSuperview];
        [self.loadingImageView.layer pop_removeAnimationForKey:@"rotation"];
    }
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.backgroundImageView.width, self.backgroundImageView.height)];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

-(UIImageView *)loadingImageView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
         _loadingImageView.image = [UIImage imageNamed:@"camera_loading"];
        _loadingImageView.center = self.maskView.center;
    }
    return _loadingImageView;
}

-(UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.height, self.view.width)];
        _backgroundImageView.image = [UIImage imageNamed:@"camera_bg"];
        _backgroundImageView.userInteractionEnabled = YES;
    }
    return _backgroundImageView;
}

-(JFGDraggableView *)draggableView
{
    if (!_draggableView) {
        _draggableView = [[JFGDraggableView alloc]initWithFrame:CGRectMake(0, 0, 418*0.5, 278*0.5)];
        _draggableView.x = self.view.height*0.5;
        _draggableView.y = self.view.width*0.5;
        _draggableView.minDragViewSize = CGSizeMake(80, 80);
        _draggableView.hint = [JfgLanguage getLanTextStrByKey:@"DETECTION_AREA_GUIDE"];
        _draggableView.backgroundColor = [[UIColor colorWithHexString:@"#fa0a0a"] colorWithAlphaComponent:0.3];
    }
    return _draggableView;
}

-(UIView *)openDetectView
{
    if (!_openDetectView) {
        _openDetectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 180)];
        _openDetectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _openDetectView.center = CGPointMake(self.view.height*0.5, self.view.width*0.5);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(68, 44, 44, 44);
        [btn setImage:[UIImage imageNamed:@"icon_drag_and_drop"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addDragAction) forControlEvents:UIControlEventTouchUpInside];
        [_openDetectView addSubview:btn];
        
        FLLabel *tLabel = [[FLLabel alloc]initWithFrame:CGRectMake(9, 114, 162, 180-114-10)];
        tLabel.numberOfLines = 0;
        tLabel.textColor = [UIColor whiteColor];
        tLabel.textAlignment = NSTextAlignmentCenter;
        tLabel.verticalAlignment = FLVerticalAlignmentTop;
        tLabel.text = [JfgLanguage getLanTextStrByKey:@"DETECTION_AREA_ADD"];
        [_openDetectView addSubview:tLabel];
        _openDetectView.hidden = YES;
    }
    
    return _openDetectView;
}

-(UIButton *)detectDefaultBtn
{
    if (!_detectDefaultBtn) {
        _detectDefaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _detectDefaultBtn.frame = CGRectMake(0, 0, 36, 36);
        _detectDefaultBtn.right = self.view.height-20;
        _detectDefaultBtn.bottom = self.view.width-20;
        [_detectDefaultBtn setImage:[UIImage imageNamed:@"icon_default_area"] forState:UIControlStateNormal];
        [_detectDefaultBtn addTarget:self action:@selector(detectDefaultAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detectDefaultBtn;
}

-(UIView *)tipView
{
    if (!_tipView) {
        
        _tipView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 109, 46)];
        _tipView.backgroundColor = [UIColor clearColor];
        
        CGFloat width = self.view.height;
        if (self.view.width>width) {
            width = self.view.width;
        }
        
        _tipView.right = width-20;
        _tipView.bottom = self.detectDefaultBtn.top-5;
        
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.text = [JfgLanguage getLanTextStrByKey:@"DETECTION_AREA_RESTORE"];
        [textLabel sizeToFit];
        
        CGFloat totalWidth = textLabel.size.width + 40 + 14;
        
        UIImageView *bgImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, totalWidth, 40)];
        bgImageView1.image = [UIImage imageNamed:@"tip_bg2"];
        
        UIImageView *bgImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, 6)];
        bgImageView2.right = totalWidth-12;
        bgImageView2.top = 40;
        bgImageView2.image = [UIImage imageNamed:@"tip_bg"];
        bgImageView2.transform = CGAffineTransformMakeRotation(180 * (M_PI / 180.0f));
        bgImageView1.userInteractionEnabled = YES;
        
        [_tipView addSubview:bgImageView1];
        [_tipView addSubview:bgImageView2];
        [_tipView addSubview:textLabel];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(0, 0, 40, 40);
        [closeBtn setImage:[UIImage imageNamed:@"tips_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeTip) forControlEvents:UIControlEventTouchUpInside];
        
        [_tipView addSubview:closeBtn];
        _tipView.hidden = YES;
    }
    return _tipView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    //self.navigationController.navigationBarHidden = YES;
    isAppear = YES;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //self.navigationController.navigationBarHidden = NO;
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self stopLoadingAnimation];
    isAppear = NO;
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [ProgressHUD dismiss];
}

-(void)loadDiskImage
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        UIImage *image = [self getDiskImage];
        if (image) {
            realTimeSnapImg = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layouForSnapImage:image];
            });
        }else{
            realTimeSnapImg = self.backgroundImageView.image;
        }
        
    });
}

-(UIImage *)getDiskImage
{
    NSString *path = [JfgCachePathManager cylanDic];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpg",AreaDetectionSnapSaveKey,self.cid]];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

-(void)saveImgToDisk:(UIImage *)image
{
    NSData *imgData = UIImagePNGRepresentation(image);
    if (!imgData) {
        imgData = UIImageJPEGRepresentation(image, 1);
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *path = [JfgCachePathManager cylanDic];
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpg",AreaDetectionSnapSaveKey,self.cid]];
        [imgData writeToFile:path atomically:YES];
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}
//
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}

//一开始的方向  很重要
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft;
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
