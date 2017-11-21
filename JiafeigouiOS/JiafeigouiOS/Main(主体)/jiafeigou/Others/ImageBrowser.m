//
//  ImageBrowser.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ImageBrowser.h"
#import "FLGlobal.h"
#import "DelButton.h"
#import "UIView+FLExtensionForFrame.h"
#import <SDWebImage/SDImageCache.h>
#import "ShareClassView.h"
#import <ShareSDK/ShareSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/MPMessagePackWriter.h>
#import "JfgLanguage.h"
#import "JfgMsgDefine.h"
#import "ProgressHUD.h"
#import "JfgConfig.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "OemManager.h"
#import "JfgConfig.h"
#import "JFGAlbumManager.h"
#import "JFGBoundDevicesMsg.h"
#import "FLTipsBaseView.h"
#import "UIColor+HexColor.h"
#import "UIAlertView+FLExtension.h"
#import "MessageImageView.h"
#import "videoPlay1ViewController.h"
#import "ShareView.h"
#import "LSAlertView.h"
#import "FLShareSDKHelper.h"
#import "JfgCacheManager.h"
#import "DevPropertyManager.h"
#import "PropertyManager.h"

#define ImageViewTag_0 633
#define ImageViewTag_1 1+633
#define ImageViewTag_2 2+633
#define BigScrollViewTag 1002
#define PreViewLeftTag 1003
#define PreViewCenterTag 1004
#define PreViewRightTag 1005
#define MaxScale 3.0
#define MinScale 1.0
#define BigScrollWidth [[UIScreen mainScreen] bounds].size.width

@interface JFGFileNameImageView : UIImageView
@property (nonatomic,copy)NSString *fileName;
@property (nonatomic,assign)BOOL isCollected;
@property (nonatomic,strong)UIImage *subImage;
@end

@implementation JFGFileNameImageView
@end

@interface JFGMarkModel : NSObject
@property (nonatomic,assign)int64_t picTimestamp;
@property (nonatomic,assign)int64_t jingCaiTimestamp;
@end

@implementation JFGMarkModel
@end

@interface ImageBrowser()<JFGSDKCallbackDelegate,UIAlertViewDelegate>{
    BOOL showTopBottomView;
    int currentImage;
    NSInteger originIndex;
    BOOL isCollectedImage;
    BOOL _isExpore;//是否是每日精彩视图
    BOOL _isAllAngle;
    int orignalFileCode;
    NSMutableArray *showImageViewArr;
    NSMutableArray *markCollectArr;
    int allAngleTly;
}
@property(strong, nonatomic)UIView * topView;
@property(strong, nonatomic)UIView * bottomView;
//黑色的背景
@property(nonatomic, strong)UIView * bgView;
//放image的scroll
@property(strong, nonatomic)UIScrollView *bigScrollView;
@property(strong, nonatomic)DelButton * exitBtn;
@property(strong, nonatomic)DelButton * downloadButton;
@property(strong, nonatomic)DelButton * shareButton;
@property(strong, nonatomic)DelButton * collectButton;
@property(strong, nonatomic)DelButton * delButton;
@property(strong, nonatomic)UIView *previewBgView;


@end


@implementation ImageBrowser

-(instancetype)initAllAnglePicViewWithImageView:(NSArray<UIImageView *> *)oldImageViews Title:(NSString *)title tly:(int)tly currentImageIndex:(NSInteger)index cid:(NSString *)cid
{
    self = [super initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    _isExpore = NO;
    _isAllAngle = YES;
    originIndex = index;
    allAngleTly = tly;
    self.cid = cid;
    self.oldImageViews = [NSMutableArray arrayWithArray:oldImageViews];
    [self addSubview:self.bgView];
    
    
    self.titleLabel.text = title;
    //重要:设置scroll当前偏移量,由当前选的图片决定
    self.bigScrollView.frame = CGRectMake(0, 0, Kwidth, kheight);
    [self.bigScrollView setContentOffset:CGPointMake(index*Kwidth, 0)];
    showImageViewArr = [[NSMutableArray alloc]init];
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    //[self.bgView addSubview:self.bigScrollView];
    
    //往scroll上面加图片
    for (int i = 0; i<oldImageViews.count; i++) {
        //获取到小图
        UIImageView *oldImageView = [oldImageViews objectAtIndex:i];
//        CGSize imageSize = oldImageView.image.size;
//        CGFloat scale = imageSize.height/imageSize.width;
//        CGFloat height = Kwidth * scale;
        
        JFGFileNameImageView * imageV = [[JFGFileNameImageView alloc]initWithFrame:CGRectMake(Kwidth*i, 64 + kheight*0.04, Kwidth, Kwidth)];
        //imageV.y = kheight*0.5;
        imageV.userInteractionEnabled = YES;
        imageV.subImage = oldImageView.image;
        if ([oldImageView isKindOfClass:[MessageImageView class]]) {
            
            MessageImageView *mg = (MessageImageView *)oldImageView;
            imageV.fileName = mg.fileName;
            
        }else{
            imageV.fileName = self.fileName;
        }
        
        imageV.contentMode = UIViewContentModeScaleAspectFill;
        imageV.tag = i+ImageViewTag_0;
        //这里以后会用SDWebImage
        //imageV.image = oldImageView.image;
        [showImageViewArr addObject:imageV];
  
        [self.bigScrollView addSubview:imageV];
        
        NSString *pid = @"";
        NSArray *devList = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
        for (JiafeigouDevStatuModel *model in devList) {
            if ([model.uuid isEqualToString:cid]) {
                pid = model.pid;
                break;
            }
        }
        
        BOOL isRS = [DevPropertyManager isRSDevForPid:pid];
        
        UIView *_remoteView = [[PanoramicIosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, Kwidth, Kwidth)];
        
        if ([CommonMethod devBigTypeForOS:pid] == JFGDevBigType360 || ([CommonMethod devBigTypeForOS:pid] == JFGDevBigTypeSinglefisheyeCamera && isRS)){
            _remoteView = [[PanoramicIosViewRS alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, Kwidth, Kwidth)];
        }
        
        SFCParamModel *paramModel =[CommonMethod panoramicViewParamModelForCid:self.cid];
        struct SFCParamIos param;
        if (paramModel) {
            param.cx = paramModel.x;
            param.cy = paramModel.y;
            param.r = paramModel.r;
            param.w = paramModel.w ;
            param.h = paramModel.h;
            param.fov = 180;
        }else{
            param.cx = 640;
            param.cy = 480;
            param.r = 480;
            param.w = 1280;
            param.h = 960;
            param.fov = 180;
            
        }
        
        //给每个大图加上单击手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBigImageView:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [imageV addGestureRecognizer:tap];
        
        if ([_remoteView isKindOfClass:[PanoramicIosView class]]) {
            PanoramicIosView *remoteView = (PanoramicIosView *)_remoteView;
            [remoteView configV360:param];
            [remoteView loadUIImage:oldImageView.image];
            if (tly == 1) {
                //挂壁
                [remoteView setMountMode:MOUNT_WALL];
            }else{
                //吊顶
                [remoteView setMountMode:MOUNT_TOP];
            }
            BOOL isSupportAngleSwitch = YES;
            
            isSupportAngleSwitch = [PropertyManager showSharePropertiesRowWithPid:[pid intValue] key:pAngleKey];
            
            if (!isSupportAngleSwitch) {
                [remoteView setMountMode:MOUNT_WALL];
            }
            UITapGestureRecognizer *panTap = [remoteView getDoubleTapRecognizer];
            [tap requireGestureRecognizerToFail:panTap];
            
        }else{
            PanoramicIosViewRS *remoteView = (PanoramicIosViewRS *)_remoteView;
            [remoteView configV360:param];
            [remoteView loadUIImage:oldImageView.image];
            if (tly == 1) {
                //挂壁
                [remoteView setMountMode:MOUNT_WALL];
            }else{
                //吊顶
                [remoteView setMountMode:MOUNT_TOP];
            }
            BOOL isSupportAngleSwitch = YES;
            
            isSupportAngleSwitch = [PropertyManager showSharePropertiesRowWithPid:[pid intValue] key:pAngleKey];
            
            if (!isSupportAngleSwitch) {
                [remoteView setMountMode:MOUNT_WALL];
            }
            UITapGestureRecognizer *panTap = [remoteView getDoubleTapRecognizer];
            [tap requireGestureRecognizerToFail:panTap];
        }
        
        
        [imageV addSubview:_remoteView];
        //MODE_TOP = 0 吊顶 MODE_WALL = 1 壁挂    
    }
    [self initPreview];
    showTopBottomView = NO;
    [window addSubview:self];
    [JFGSDK addDelegate:self];
    [self getCollectedData];
    /**
     *  开始生成 设备旋转 通知
     */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    /**
     *  添加 设备旋转 通知
     *
     *  当监听到 UIDeviceOrientationDidChangeNotification 通知时，调用handleDeviceOrientationDidChange:方法
     *  @param handleDeviceOrientationDidChange: handleDeviceOrientationDidChange: description
     *
     *  @return return value description
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    return self;
}


-(instancetype)initWithImageView:(NSArray<UIImageView *> *)oldImageViews Title:(NSString *)title currentImageIndex:(NSInteger)index isExpore:(BOOL)isExpore
{
    if (self = [super initWithFrame:CGRectMake(0, 0, Kwidth, kheight)]) {
      
        _isExpore = isExpore;
        self.oldImageViews = [NSMutableArray arrayWithArray:oldImageViews];
        [self addSubview:self.bgView];

        
        self.titleLabel.text = title;
        //重要:设置scroll当前偏移量,由当前选的图片决定
        self.bigScrollView.frame = CGRectMake(0, 0, Kwidth, kheight);
        [self.bigScrollView setContentOffset:CGPointMake(index*Kwidth, 0)];
        showImageViewArr = [NSMutableArray new];
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        //往scroll上面加图片
        for (int i = 0; i<oldImageViews.count; i++) {
            //获取到小图
            UIImageView *oldImageView = [oldImageViews objectAtIndex:i];
            
            //获取到小图映射在window上的frame
            //CGRect oldFrame = [oldImageView convertRect:oldImageView.bounds toView:window];
            
            UIImage *image = oldImageView.image;
            CGFloat scale = image.size.height/image.size.width;
            CGFloat height = Kwidth * scale;
            
            JFGFileNameImageView * imageV = [[JFGFileNameImageView alloc]initWithFrame:CGRectMake(0,(kheight-height)*0.5, Kwidth, height)];
            imageV.userInteractionEnabled = YES;
            imageV.contentMode = UIViewContentModeScaleAspectFill;
            imageV.tag = i+ImageViewTag_0;
            //这里以后会用SDWebImage
            imageV.image = oldImageView.image;
            [showImageViewArr addObject:imageV];
            if ([oldImageView isKindOfClass:[MessageImageView class]]) {
                
                MessageImageView *mg = (MessageImageView *)oldImageView;
                imageV.fileName = mg.fileName;
                
            }else{
                imageV.fileName = self.fileName;
            }
           
            
            UIScrollView *smallScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(Kwidth*i, 0, Kwidth, kheight)];
            smallScrollView.delegate =self;
            smallScrollView.minimumZoomScale =MinScale;
            smallScrollView.maximumZoomScale =MaxScale;
            [smallScrollView setClipsToBounds:YES];
            smallScrollView.showsVerticalScrollIndicator = NO;
            smallScrollView.showsHorizontalScrollIndicator = NO;
            smallScrollView.bounces = NO;
            smallScrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight ;
            [smallScrollView addSubview:imageV];
            [self.bigScrollView addSubview:smallScrollView];

            //给每个大图加上单击手势
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBigImageView:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [self addGestureRecognizer:tap];
            
            UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubletapImage:)];
            doubleTap.numberOfTapsRequired = 2;
            doubleTap.numberOfTouchesRequired = 1;
            [tap requireGestureRecognizerToFail:doubleTap];
            [imageV addGestureRecognizer:doubleTap];
        }
        
        showTopBottomView = NO;
        [window addSubview:self];
        [JFGSDK addDelegate:self];
        /**
         *  开始生成 设备旋转 通知
         */
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        
        /**
         *  添加 设备旋转 通知
         *
         *  当监听到 UIDeviceOrientationDidChangeNotification 通知时，调用handleDeviceOrientationDidChange:方法
         *  @param handleDeviceOrientationDidChange: handleDeviceOrientationDidChange: description
         *
         *  @return return value description
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
        
    }
    return self;
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    
    
    
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    
}

-(void)didMoveToWindow
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreImage:) name:@"showDoorBellCallingVC" object:nil];
}

-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initPreview
{
    self.previewBgView = [[UIView alloc]initWithFrame:CGRectMake(0, kheight-62-40-59, Kwidth, 62+40)];
    self.previewBgView.userInteractionEnabled = YES;
    self.previewBgView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.3];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewBgTapAction)];
    [self.previewBgView addGestureRecognizer:tap];
    
    CGFloat space = 38.5;
    CGFloat previewSmallWidth = 45;
    CGFloat left = (Kwidth - self.oldImageViews.count*previewSmallWidth - (self.oldImageViews.count-1)*space)*0.5;
    
    int i=0;
    for (UIImageView *imageV in self.oldImageViews) {
        
        if ([imageV isKindOfClass:[UIImageView class]]) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(left+i*(previewSmallWidth+space), 8.5+20, previewSmallWidth, previewSmallWidth);
            btn.showsTouchWhenHighlighted = NO;
            btn.adjustsImageWhenHighlighted = NO;
            //[btn setBackgroundImage:imageV.image forState:UIControlStateNormal];
            [btn setImage:imageV.image forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [btn addTarget:self action:@selector(previewAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            btn.layer.borderWidth = 1;
           
            UIColor *color = [UIColor colorWithHexString:@"#4d4d4d"];
            btn.layer.borderColor = color.CGColor;
            [self.previewBgView addSubview:btn];
            
            if (i==0) {
                btn.tag = PreViewLeftTag;
            }else if (i==1){
                btn.tag = PreViewCenterTag;
            }else if (i==2){
                btn.tag = PreViewRightTag;
            }
            
            i++;
        }
        
        
    }
    UIButton *selectedBtn = nil;
    
    switch (originIndex) {
        case 0:
            selectedBtn = [self.previewBgView viewWithTag:PreViewLeftTag];
            break;
        case 1:
            selectedBtn = [self.previewBgView viewWithTag:PreViewCenterTag];
            break;
        case 2:
            selectedBtn = [self.previewBgView viewWithTag:PreViewRightTag];
            break;
        default:
            break;
    }
    if (selectedBtn) {
        CGPoint point = selectedBtn.center;
        CGRect rect = CGRectMake(point.x-8.5, point.y-8.5, 62, 62);
        selectedBtn.frame = rect;
        selectedBtn.center = point;
        selectedBtn.layer.borderColor = [UIColor colorWithHexString:@"#319de4"].CGColor;
    }
    
    [self.bgView addSubview:self.previewBgView];
}

-(void)setSelectedPreview:(UIButton *)btn
{
    CGPoint point = btn.center;
    CGRect rect = CGRectMake(point.x-8.5, point.y-8.5, 62, 62);
    
    [UIView animateWithDuration:0.3 animations:^{
        btn.frame = rect;
        btn.center = point;
    }];
    btn.layer.borderColor = [UIColor colorWithHexString:@"#319de4"].CGColor;
}

-(void)previewBgTapAction
{
    
}

-(void)previewAction:(UIButton *)btn
{
    [self setSelectedPreview:btn];
    for (UIView *v in self.previewBgView.subviews) {
        
        if ([v isKindOfClass:[UIButton class]]) {
            
            if (v != btn) {
                CGPoint point = v.center;
                CGRect rect = CGRectMake(0, 0, 45, 45);
                
                [UIView animateWithDuration:0.2 animations:^{
                    v.frame = rect;
                    v.center = point;
                }];
                
                v.layer.borderColor = [UIColor colorWithHexString:@"#4d4d4d"].CGColor;
            }
            
        }
        
    }
    
    if (btn.tag == PreViewLeftTag) {
        [self.bigScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }else if (btn.tag == PreViewCenterTag){
        if (_isAllAngle) {
            [self.bigScrollView setContentOffset:CGPointMake(Kwidth, 0) animated:NO];
        }else{
            [self.bigScrollView setContentOffset:CGPointMake(Kwidth, 0) animated:NO];
        }
        
    }else{
        if (_isAllAngle) {
           [self.bigScrollView setContentOffset:CGPointMake(Kwidth*2, 0) animated:NO];
        }else{
           [self.bigScrollView setContentOffset:CGPointMake(Kwidth*2, 0) animated:NO];
        }
        
    }
    [self refreshCollectedView];
}

-(void)showCurrentImageViewIndex:(NSInteger)curImageViewIndex {
  //由于创建的时候已经将初始frame布置好了,所以只需要放大到想要的效果即可
    for (int i = 0; i<self.oldImageViews.count; i++) {
        
        //UIImageView *oldImageV = self.oldImageViews[i];
        
        UIImageView * imageV = [self viewWithTag:i+ImageViewTag_0];
        
        if (_isAllAngle) {
//            CGFloat height = imageV.height;
//            if ([oldImageV isKindOfClass:[UIImageView class]]) {
//                CGSize imageSize = oldImageV.image.size;
//                CGFloat scale = imageSize.height/imageSize.width;
//                height = Kwidth * scale;
//            }
            //CGRect frame = imageV.frame;
            //[imageV setFrame:CGRectMake(15, 0.25 *kheight, Kwidth, height)];
        }else{
            UIImage *image = imageV.image;
            CGFloat scale = image.size.height/image.size.width;
            CGFloat height = Kwidth * scale;
            [imageV setFrame:CGRectMake(0, (kheight-height)*0.5, Kwidth, height)];
        }
        
        
    }
    
    [self getCollectedData];
    [UIView animateWithDuration:0.3f animations:^{
        self.bgView.alpha = 1;
    } completion:^(BOOL finished) {
       
        if (!_isExpore) {
            //
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"JFGFristNoIntoExperot"]) {
                [self showTransionLiveVideoTip];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JFGFristNoIntoExperot"];
            }
            
            
        }
        
        
    }];
}
-(void)tapBigImageView:(UITapGestureRecognizer *)tap{
    showTopBottomView = !showTopBottomView;
    if (showTopBottomView == YES) {
        [self hiddenTopandBottom];
        
    }
    else{
        [self showTopandBottom];
    }
}
-(void)hiddenTopandBottom{
    [UIView animateWithDuration:0.3 animations:^{
        [self.topView setFrame:CGRectMake(0, -64, Kwidth, 64)];
        if (_isAllAngle) {
            
        }
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomView setFrame:CGRectMake(0, kheight, Kwidth, 59)];
    }];
    
    if (self.previewBgView) {
        [UIView animateWithDuration:0.4 animations:^{
            self.previewBgView.alpha = 0;
        }];
    }
}
-(void)showTopandBottom{
    [UIView animateWithDuration:0.3 animations:^{
        [self.topView setFrame:CGRectMake(0, 0, Kwidth, 64)];
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomView setFrame:CGRectMake(0, kheight-59, Kwidth, 59)];
    }];
    if (self.previewBgView) {
        [UIView animateWithDuration:0.4 animations:^{
            self.previewBgView.alpha = 1;
        }];
    }
    
}
//恢复原状
-(void)restoreImage:(UIButton *)btn
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    int currentIndex = (int)self.bigScrollView.contentOffset.x/BigScrollWidth;
    UIImageView *imageView = (UIImageView *)[self viewWithTag:ImageViewTag_0+currentIndex];
    UIScrollView * smallScrollView = (UIScrollView *)[[self viewWithTag:ImageViewTag_0+currentIndex] superview];
    if (smallScrollView &&imageView) {
        UIImageView * oldImageView = [self.oldImageViews objectAtIndex:imageView.tag-ImageViewTag_0];
        CGRect frame = [oldImageView convertRect:oldImageView.bounds toView:window];
        [UIView animateWithDuration:0.3f animations:^{
            imageView.frame = frame;
            self.bgView.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    [JFGSDK removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGPoint)centerOfView:(UIView *)view
{
    return [[UIApplication sharedApplication].keyWindow convertPoint:CGPointMake(Kwidth /2, kheight /2) toView:view];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ButtonAction
-(void)saveImageToAlbum:(DelButton *)button{
    int currentIndex = (int)(self.bigScrollView.contentOffset.x/Kwidth);
     JFGFileNameImageView * imageV = [self viewWithTag:ImageViewTag_0+currentIndex];
    
    [JFGAlbumManager jfgWriteImage:imageV.image?imageV.image:imageV.subImage toPhotosAlbum:nil completionHandler:^(UIImage *image, NSError *error) {
        
        if (error == nil) {
            
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"]];
            
        }else{
            
        }
        
    }];
    
}


-(JFGFileNameImageView *)getCurrentShowImageView
{
    int currentIndex = (int)(self.bigScrollView.contentOffset.x/BigScrollWidth);
    JFGFileNameImageView * imageV = [self viewWithTag:ImageViewTag_0+currentIndex];
    if ([imageV isKindOfClass:[JFGFileNameImageView class]]) {
        return imageV;
    }
    return nil;
}

-(void)shareImage:(DelButton *)button{
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    int currentIndex = (int)(self.bigScrollView.contentOffset.x/BigScrollWidth);
    JFGFileNameImageView *imageV = [self viewWithTag:ImageViewTag_0+currentIndex];
    
    NSString *imageUrl = @"";
    if (self.imagesUrl.count > currentIndex) {
        imageUrl = self.imagesUrl[currentIndex];
    }
    
    ShareView *sv = [[ShareView alloc]initWithLandScape:NO];
    [sv showShareView:^(SSDKPlatformType platformType) {
        
        NSString *title = [OemManager appName];
        NSString *url = @"www.jfgou.com";
        if ([OemManager oemType] == oemTypeDoby) {
            url = @"";
        }
        [FLShareSDKHelper shareToThirdpartyPlatform:platformType url:url image:imageV.image?imageV.image:imageV.subImage title:title contentType:SSDKContentTypeImage];
        
    } cancel:^{
        
    }];
    
}


-(void)markDeal
{
    for (JFGFileNameImageView *imv in showImageViewArr) {
        imv.isCollected = NO;
    }
    if(markCollectArr.count){
        
        for (JFGMarkModel *model in markCollectArr) {
            for (JFGFileNameImageView *imv in showImageViewArr) {
                NSInteger mark = [self markForFileName:imv.fileName];
                if (model.picTimestamp == self.timestamp+mark) {
                    if (model.jingCaiTimestamp != 0) {
                        imv.isCollected = YES;
                    }else{
                        imv.isCollected = NO;
                    }
                    break;
                }
            }
        }
    }
    [self refreshCollectedView];
}

-(void)refreshCollectedView
{
    JFGFileNameImageView *iv = [self getCurrentShowImageView];
    if (iv) {
        if (iv.isCollected) {
            self.collectButton.selected = YES;
        }else{
            self.collectButton.selected = NO;
        }
    }
}

-(void)addToExplore:(DelButton *)button
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    if (_isExpore) {
        
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tips_SureDelete"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:JFGDelExporePicKey object:weakSelf._indexPath];
            [weakSelf restoreImage:nil];
            
        }];
        
        return;
        
    }
    
    JFGFileNameImageView *showIv = [self getCurrentShowImageView];
    if (showIv.isCollected) {
        
        //[self delWarnCollected];
        //[self cancelMarkCollected];
        [self cancelCollected];
    }else{
        [self collectWarn];
    }
   
}

//获取收藏标记
-(void)getCollectedData
{
    if (self.cid == nil) {
        return;
    }
    NSMutableArray *segArr = [[NSMutableArray alloc]init];
    for (JFGFileNameImageView *imv in showImageViewArr) {
        NSInteger mark = [self markForFileName:imv.fileName];
        DataPointIDVerSeg *_seg = [[DataPointIDVerSeg alloc]init];
        _seg.msgId = 511;
        _seg.version = self.timestamp+mark;
        [segArr addObject:_seg];
    }
    
    [[JFGSDKDataPoint sharedClient] robotGetDataByTimeWithPeer:self.cid msgIds:segArr success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        markCollectArr = [[NSMutableArray alloc]init];
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *ds in subArr) {
                
                if (ds.msgId == 511) {
                    
                    JFGMarkModel *model = [[JFGMarkModel alloc]init];
                    model.picTimestamp = ds.version;
                    id obj = [MPMessagePackReader readData:ds.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        int64_t timestamp = [obj longLongValue];
                        model.jingCaiTimestamp = timestamp;
                    }else{
                        model.jingCaiTimestamp = 0;
                    }
                    [markCollectArr addObject:model];
                    
                }
                [self markDeal];
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        [self markDeal];
    }];
    
}

//收藏
-(void)collectWarn
{
    JFGFileNameImageView *fileIv = [self getCurrentShowImageView];
    if (!fileIv) {
        return;
    }
    
    self.collectButton.userInteractionEnabled = NO;
    NSString *_fileNam = fileIv.fileName;
    if (!_fileNam) {
        _fileNam = self.fileName;
    }
    
    //拷贝数据到oss
    ///%@/%lld_%d
    NSString *cloudFilePath = [NSString stringWithFormat:@"/%@/%@",self.cid,_fileNam];
    
    if (self.deviceVersion == 3) {
        ///cid/[vid]/[cid]/[timestamp]_[id].jpg
        cloudFilePath = [NSString stringWithFormat:@"/cid/%@/%@/%@",[OemManager getOemVid],self.cid,_fileNam];
    }
    
    //如果是AI图片的路径
    if ([_fileNam containsString:@"AI"]) {
        cloudFilePath = _fileNam;
        _fileNam = [cloudFilePath lastPathComponent];
    }
   
    
    //set 602
    NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    NSString *alias = self.cid;
    for (JiafeigouDevStatuModel *model in list) {
        if ([model.uuid isEqualToString:self.cid]) {
            alias = model.alias;
            break;
        }
    }
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    int64_t time = (int64_t)[timeString longLongValue];
    NSError * error = nil;
    DataPointSeg * seg1 = [[DataPointSeg alloc]init];
    seg1.msgId = dpMsgAccount_Wonder;
    int64_t version = [[NSDate date] timeIntervalSince1970]*1000;
    seg1.version = version;
    NSInteger mark = [self markForFileName:_fileNam];
    seg1.value = [MPMessagePackWriter writeObject:@[self.cid,[NSNumber numberWithLongLong:time],@0,@(self.regionType),_fileNam,alias,[NSNumber numberWithLongLong:self.timestamp+mark]] error:&error];
    
    [[JFGSDKDataPoint sharedClient] robotSetDataByTimeWithPeer:self.cid dsp:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        for (DataPointIDVerRetSeg *seg in dataList) {
            
            self.collectButton.userInteractionEnabled = YES;
            NSLog(@"ret:%d",seg.ret);
            
            if (seg.ret == 0) {
                
                JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
                NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,self.cid,_fileNam];
                
                NSLog(@"wonderFilePath:%@",wonderFilePath);
                [JFGSDK copyCloudFile:cloudFilePath toWonderPath:wonderFilePath requestId:1111];
                
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Success"]];
                self.collectButton.selected = YES;
                
                //标记收藏
                DataPointSeg *seg2 = [[DataPointSeg alloc]init];
                seg2.msgId = 511;
                NSInteger mark = [self markForFileName:_fileNam];
                seg2.version = self.timestamp+mark;
                seg2.value = [MPMessagePackWriter writeObject:[NSNumber numberWithLongLong:version] error:nil];
                //[[NSNotificationCenter defaultCenter] postNotificationName:JFGExploreRefreshNotificationKey object:nil userInfo:nil];
                
                [[JFGSDKDataPoint sharedClient] robotSetDataByTimeWithPeer:self.cid dsp:@[seg2] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                    for (DataPointIDVerRetSeg *seg in dataList) {
                        
                        self.collectButton.userInteractionEnabled = YES;
                        NSLog(@"ret:%d",seg.ret);
                        
                        if (seg.ret == 0) {
                            [self getCollectedData];
                        }
                        
                    }
                } failure:^(RobotDataRequestErrorType type) {
                    
                    
                }];
                
                
                
                
            }else if(seg.ret == 1050){
                
                //超过收藏值
                //NSLog(@"retError:%d",seg.ret);
                
                __weak typeof(self) weakSelf = self;
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"DailyGreatTips_Full"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_No"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Yes"] CancelBlock:^{
                    
                } OKBlock:^{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGJumpingRootView" object:nil];
                    [weakSelf restoreImage:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:JFGTabBarJumpVcKey object:[NSNumber numberWithInt:1]];
                    
                }];
            
                
            }
            
            break;
            
        }

    } failure:^(RobotDataRequestErrorType type) {
        
        self.collectButton.userInteractionEnabled = YES;
        
    }];
    

}



//取消收藏
-(void)cancelCollected
{
    self.collectButton.userInteractionEnabled = NO;
    JFGFileNameImageView *fileIv = [self getCurrentShowImageView];
    if (fileIv) {
        
        NSString *fileName = fileIv.fileName;
        if (!fileName) {
            fileName = self.fileName;
        }
        NSInteger mark = [self markForFileName:fileName];
        for (JFGMarkModel *model in markCollectArr) {
            
            if (model.picTimestamp == self.timestamp+mark) {
                
                if (model.jingCaiTimestamp != 0) {
                    
                    //取消标记
                    DataPointSeg *seg2 = [[DataPointSeg alloc]init];
                    seg2.msgId = 511;
                    seg2.version = model.picTimestamp;
                    seg2.value = [MPMessagePackWriter writeObject:[NSNumber numberWithLongLong:0] error:nil];
                    
                    [[JFGSDKDataPoint sharedClient] robotSetDataByTimeWithPeer:self.cid dsp:@[seg2] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                        for (DataPointIDVerRetSeg *seg in dataList) {
                            
                            self.collectButton.userInteractionEnabled = YES;
                            NSLog(@"ret:%d",seg.ret);
                            
                            if (seg.ret == 0) {
                                
                                //[ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Success"]];
                                
                                //[[NSNotificationCenter defaultCenter] postNotificationName:JFGExploreRefreshNotificationKey object:nil userInfo:nil];
                                self.collectButton.selected = NO;
                                [self getCollectedData];
                                
                            }
                        }
                        self.collectButton.userInteractionEnabled = YES;
                    } failure:^(RobotDataRequestErrorType type) {
                        
                        self.collectButton.userInteractionEnabled = YES;
                        
                    }];
                    
                    //删除每日精彩数据
                    DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
                    seg.msgId = dpMsgAccount_Wonder;
                    seg.version = model.jingCaiTimestamp;
                    [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
                        if (ret == 0) {
                            NSLog(@"delete 602 success");
                        }
                    } failure:^(RobotDataRequestErrorType type) {
                        NSLog(@"delete fail:%ld",(long)type);
                    }];
                    
                }
                
                break;
                
            }else{
                self.collectButton.userInteractionEnabled = YES;
            }
            
        }
        
    }else{
        self.collectButton.userInteractionEnabled = YES;
    }
}


-(NSInteger)markForFileName:(NSString *)fileName
{
    if (fileName) {
        
        NSRange range = [fileName rangeOfString:@"_"];
        if (range.location != NSNotFound) {
            
            NSString *fileMark = [fileName substringWithRange:NSMakeRange(range.location+1, 1)];
            NSInteger mark = [fileMark intValue];
            return mark;
            
        }else{
            
            return 0;
        }
        
    }
    
    return 0;
}

-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10223 && buttonIndex == 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JFGDelExporePicKey object:self._indexPath];
        [self restoreImage:nil];

    }
}

#pragma mark - UIScrollView
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView.tag != BigScrollViewTag) {
        UIView *zoomingView =[[scrollView subviews] lastObject];
        return zoomingView;
    }
    return nil;
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scrollView.tag != BigScrollViewTag) {
        currentScale = scale;
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView.tag != BigScrollViewTag) {
        CGSize imageViewSize = scrollView.frame.size;
        CGSize scrollViewSize = scrollView.bounds.size;
        
        CGFloat verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0;
        CGFloat horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0;
        scrollView.contentInset = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
        
        UIView *zoomingView =[[scrollView subviews] lastObject];
        CGPoint center = [self centerOfView:scrollView];
        zoomingView.y = center.y;
        
//        if (imageViewSize.width<Kwidth) {
//            zoomingView.x = center.x;
//        }else{
//            zoomingView.x = 15;
//        }
        
        //zoomingView.center =[self centerOfView:scrollView];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.tag == BigScrollViewTag) {
        currentImage = scrollView.contentOffset.x/BigScrollWidth;
        NSLog(@"currentImageIndex:%d",currentImage);
    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == BigScrollViewTag) {
        NSArray * smallS = scrollView.subviews;
        if (smallS) {
            for (int i = 0; i<smallS.count; i++) {
                if (i!=currentImage) {
                    UIScrollView * sc = [smallS objectAtIndex:i];
                    
                    if ([sc isKindOfClass:[UIScrollView class]]) {
                        if (sc.zoomScale != 1.0) {
                            [sc setZoomScale:1.0 animated:YES];
                        }
                    }
                    
                }
            }
        }
        
        NSLog(@"%f",scrollView.contentOffset.x);
        UIButton *selectedBtn = nil;
        if (scrollView.contentOffset.x<Kwidth) {
            selectedBtn = [self.previewBgView viewWithTag:PreViewLeftTag];
        }else if (scrollView.contentOffset.x>=Kwidth && scrollView.contentOffset.x<2*Kwidth){
            selectedBtn = [self.previewBgView viewWithTag:PreViewCenterTag];
        }else{
            selectedBtn = [self.previewBgView viewWithTag:PreViewRightTag];
        }
        if (selectedBtn) {
            [self previewAction:selectedBtn];
        }
        [self refreshCollectedView];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


-(void)doubletapImage:(UIGestureRecognizer *)doubleTap{
    
    UIScrollView *scroll =(UIScrollView *)doubleTap.view.superview;
    //当前为最大倍数,双击回复原装
    if(scroll.zoomScale == MaxScale){
        currentScale= MinScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
    //当前是最小倍数,双击放大到最大倍数
    if(scroll.zoomScale == MinScale){
        currentScale = MaxScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
    CGFloat aveScale = MinScale+(MaxScale-MinScale)/2;
    //当前倍数大于平均倍数
    if(scroll.zoomScale>=aveScale){
        currentScale = MaxScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
    //当前倍数小于平均数
    if(scroll.zoomScale<aveScale){
        currentScale = MinScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
}


// 处理旋转手势
- (void)rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
}

#pragma mark - 控件
-(UIView *)bgView{
    if (!_bgView) {
        //黑色背景
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0;
        [_bgView addSubview:self.topView];
        [_bgView addSubview:self.bottomView];
        [_bgView addSubview:self.bigScrollView];
        [_bgView bringSubviewToFront:self.topView];
        [_bgView bringSubviewToFront:self.bottomView];
    }
    return _bgView;
}
-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, 64)];
        _topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.30];;
        [_topView addSubview:self.exitBtn];
        [_topView addSubview:self.titleLabel];

    }
    return _topView;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kheight-59, Kwidth, 59)];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.30];
        
        [_bottomView addSubview:self.downloadButton];
        [_bottomView addSubview:self.shareButton];
        [_bottomView addSubview:self.collectButton];
        if ([OemManager oemType] == oemTypeCell_C) {
            [self.shareButton removeFromSuperview];
        }
    }
    return _bottomView;
}
-(UILabel *)titleLabel{
    //title
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((Kwidth-200)/2, 35, 200, 18)];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
-(DelButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(14, 30, 30, 30);
        [_exitBtn setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(restoreImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}
-(DelButton *)downloadButton{
    if (!_downloadButton) {
        //下面左(中)
        _downloadButton = [DelButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.frame = CGRectMake(45*designWscale, 18, 23, 23);
        [_downloadButton setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(saveImageToAlbum:) forControlEvents:UIControlEventTouchUpInside];
        if (_isExpore) {
            _downloadButton.frame = CGRectMake(self.collectButton.right+108*designWscale, 18, 23, 23);
        }
    }
    
    if ([OemManager oemType] == oemTypeCell_C) {
        if (_isExpore) {
            _downloadButton.x = self.width/3*2;
        }else{
            _downloadButton.x = self.width/3;
        }
    }
    
    return _downloadButton;
    
}
-(DelButton *)shareButton{
    if (!_shareButton) {
        //下面中（右）
        _shareButton = [DelButton buttonWithType:UIButtonTypeCustom];
        
        [_shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
        if (_isExpore) {
            _shareButton.frame = CGRectMake(self.downloadButton.right+108*designWscale, 18, 23, 23);
        }else{
            _shareButton.frame = CGRectMake(self.downloadButton.right+108*designWscale, 18, 23, 23);
        }
    }
    return _shareButton;
    
    
}
-(DelButton *)collectButton{
    if (!_collectButton) {
        //下面右（左）
        _collectButton = [DelButton buttonWithType:UIButtonTypeCustom];
        if (_isExpore) {
            [_collectButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
            _collectButton.frame = CGRectMake(45*designWscale, 18, 23, 23);
        }else{
            _collectButton.frame = CGRectMake(self.shareButton.right+108*designWscale, 18, 23, 23);
            [_collectButton setImage:[UIImage imageNamed:@"icon_collection"] forState:UIControlStateNormal];
            [_collectButton setImage:[UIImage imageNamed:@"icon_be_collected"] forState:UIControlStateSelected];
        }
        if ([OemManager oemType] == oemTypeCell_C) {
            if (_isExpore) {
                _collectButton.x = self.width/3;
            }else{
                _collectButton.x = self.width/3*2;
            }
        }
        [_collectButton addTarget:self action:@selector(addToExplore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectButton;
}
-(UIScrollView *)bigScrollView{
    if (!_bigScrollView) {
        _bigScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, BigScrollWidth, kheight)];
        [_bigScrollView setContentSize:CGSizeMake(BigScrollWidth * self.oldImageViews.count, kheight)];
        _bigScrollView.pagingEnabled = YES;
        _bigScrollView.showsVerticalScrollIndicator = NO;
        _bigScrollView.showsHorizontalScrollIndicator = NO;
        _bigScrollView.bounces = NO;
        _bigScrollView.delegate = self;
        _bigScrollView.decelerationRate = 0.7;
        _bigScrollView.tag = BigScrollViewTag;
    }
    return _bigScrollView;
}

-(void)showTransionLiveVideoTip
{
    NSString *content = [JfgLanguage getLanTextStrByKey:@"Tap1_BigPic_FavoriteTips"];
    
    CGSize size = CGSizeOfString(content, CGSizeMake(124, 200), [UIFont systemFontOfSize:13]);
    CGFloat width = size.width+10;
    CGFloat height = size.height+16;
    
    //bottomView  18
    [self showTipWithFrame:CGRectMake(self.collectButton.right-width+24, self.bottomView.top-height, width, height) triangleLeft:73 content:[JfgLanguage getLanTextStrByKey:@"Tap1_BigPic_FavoriteTips"]];
}

-(void)showTipWithFrame:(CGRect)frame triangleLeft:(CGFloat)left content:(NSString *)content
{
    FLTipsBaseView *tipBaseView = [FLTipsBaseView tipBaseView];
    
    UIView *tipBgView = [[UIView alloc]initWithFrame:frame];
    tipBgView.backgroundColor = [UIColor clearColor];
    
    [tipBaseView addTipView:tipBgView];
    
    UIImageView *tipbgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tipBgView.width, tipBgView.height-6)];
    tipbgImageView.image = [UIImage imageNamed:@"tip_bg2"];
    
    
    UIImageView *roleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, tipbgImageView.bottom, 12, 6)];
    roleImageView.transform = CGAffineTransformMakeRotation(180 * (M_PI / 180.0f));
    roleImageView.image = [UIImage imageNamed:@"tip_bg"];
    [tipBgView addSubview:roleImageView];
    
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, tipbgImageView.width-10, tipbgImageView.height-10)];
    tipLabel.text = content;
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:13];
    [tipbgImageView addSubview:tipLabel];
    
    [tipBgView addSubview:tipbgImageView];
    
    [tipBaseView show];
}


@end
