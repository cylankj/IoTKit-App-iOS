//
//  ShareVideoViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ShareVideoViewController.h"
#import "JfgLanguage.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import <JFGSDK/JFGSDK.h>
#import "UIAlertView+FLExtension.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "LoginManager.h"
#import "OemManager.h"
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "FLShareSDKHelper.h"
#import "ProgressHUD.h"
#import "LSAlertView.h"
#import "UIButton+Addition.h"
#import <Masonry.h>


#define UPLOADOVERTIMECOUNT 60

@interface ShareVideoViewController ()<UITextViewDelegate,JFGSDKCallbackDelegate>
{
    uint64_t _seq;
    NSTimer *_timer;
    int uploadProgress;
    NSString *h5url;
    BOOL isUploadSuccess;
}
@property (nonatomic,strong)UIButton *shareBtn;
@property (nonatomic,strong)UIImageView *iconImageView;
@property (nonatomic,strong)UILabel *progressLabel;
@property (nonatomic,strong)UIButton *refreshButton;
@property (nonatomic,strong)UITextView *_textView;
@property (nonatomic,strong)UILabel *countLabel;
@property (nonatomic,strong)UILabel *placeholderLabel;
@property (nonatomic,strong)UILabel *instructionLabel;

@end

@implementation ShareVideoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    isUploadSuccess = NO;
    [self initNavigationBar];
    [self initView];
    [JFGSDK addDelegate:self];
    
    if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline && [JFGSDK currentNetworkStatus] != JFGNetTypeWifi){
        
        //客户端移动网络在线
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Firmware_DataTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:^{
            
        } OKBlock:^{
            [weakSelf uploadFileForPath:weakSelf.filePath];
        }];
        
    }else{
        [self filePathDeal];
        [self uploadFileForPath:self.filePath];
    }

}


//如果缩略图片存在，链接图片不存在，则使用缩略图片上传
-(void)filePathDeal
{
    
    if (self.fileType == ShareFileTypePic) {
        if (self.thumbImage && ![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"shareVideoTemp.png"];
            NSData *imagData = UIImagePNGRepresentation(self.thumbImage);
            [imagData writeToFile:path atomically:YES];
            self.filePath = [path copy];
            
        }
    }
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [self stopTimer];
}

-(void)uploadFileForPath:(NSString *)filePath
{
    if (self.filePath && self.filePath.length>0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            //上传文件到oss
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,self.cid,[self.filePath lastPathComponent]];
            NSLog(@"wonderFilePath:%@",wonderFilePath);
            
            _seq = [JFGSDK uploadFile:self.filePath toCloudFolderPath:wonderFilePath];
            uploadProgress = 0;
            [self startTimer];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"shareVideoVC file start upload %llu",_seq]];
            self.refreshButton.hidden = YES;
            self.shareBtn.enabled = NO;
            self.progressLabel.hidden = NO;
            self.progressLabel.text = @"0%";
        }else{
            [ProgressHUD showText:@"文件不存在"];
        }
    }else{
        [ProgressHUD showText:@"文件不存在"];
    }
}

-(void)startTimer
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

-(void)timerAction
{
    uploadProgress ++;
    if (uploadProgress>99) {
        //上传超时
        uploadProgress = 0;
        [self stopTimer];
        self.progressLabel.hidden = YES;
        self.progressLabel.text = @"0%";
        self.refreshButton.hidden = NO;
    }
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%",uploadProgress];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (!online && !isUploadSuccess) {
        [self stopTimer];
        self.progressLabel.hidden = YES;
        self.progressLabel.text = @"0%";
        self.refreshButton.hidden = NO;
    }
}

-(void)jfgVideoShareUrl:(NSString *)url
{
    NSLog(@"%@",url);
    if (url) {
        isUploadSuccess = YES;
        h5url = [NSString stringWithString:url];
        self.progressLabel.text = @"100%";
        self.progressLabel.hidden = YES;
        self.shareBtn.enabled = YES;
        self.refreshButton.hidden = YES;
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"sharevideoVC sharevideoUrl %@",url]];
    }
}


//文件上传结果回调
-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    if (requestID == _seq) {
        
        [self stopTimer];
        if (ret == 200) {
            self.progressLabel.text = @"99%";
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            //  long/vid/account/wonder/cid/fileName
            NSString *wonderFilePath = [NSString stringWithFormat:@"long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,self.cid,[self.filePath lastPathComponent]];
            
            int shareType = 2;
            if ([self.filePath rangeOfString:@".jpg"].location != NSNotFound) {
                shareType = 1;
            }
            
            [JFGSDK getVideoShareUrlForFileName:wonderFilePath content:self._textView.text ossType:[JFGSDK getRegionType] shareType:shareType];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"shareVideoVC file end upload success %llu",_seq]];
            
        }else{
            
            //上传失败
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"shareVideoVC file end upload failed %llu  %@",_seq,result]];
            self.progressLabel.hidden = YES;
            self.progressLabel.text = @"0%";
            self.refreshButton.hidden = NO;
        }
        
    }
}

-(void)shareAction
{
    [self addToExplore];
    self.shareBtn.enabled = NO;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    SSDKPlatformType shareType = self.platformType;
    NSString *title = @"";
    if ([OemManager oemType] == oemTypeDoby) {
        title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title_zhognxing"];
    }else{
        title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title"];
    }
    if (shareType ==SSDKPlatformSubTypeWechatTimeline || shareType ==SSDKPlatformSubTypeWechatSession) {
        
        //微信
        [parameters SSDKSetupWeChatParamsByText:self._textView.text title:title url:[NSURL URLWithString:h5url] thumbImage:self.thumbImage image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:shareType];
        
    }else if (shareType == SSDKPlatformTypeSinaWeibo){
        
        NSString *text = self._textView.text;
        if ([self._textView.text isEqualToString:@""]) {
            text = ([JfgLanguage languageType] == 0)?@"加菲狗":@"Clever Dog";
        }
        //新浪微博
        [parameters SSDKSetupSinaWeiboShareParamsByText:text title:title image:self.thumbImage url:[NSURL URLWithString:h5url] latitude:0 longitude:0 objectID:nil type:SSDKContentTypeImage];
        
    }else if (shareType == SSDKPlatformSubTypeQQFriend){
        
        //QQ
        [parameters SSDKSetupQQParamsByText:self._textView.text title:title url:[NSURL URLWithString:h5url] thumbImage:nil image:[self thumbnailWithImageWithoutScale:self.thumbImage size:CGSizeMake(500, 500)] type:SSDKContentTypeWebPage forPlatformSubType:shareType];
        
    }else if(shareType == SSDKPlatformSubTypeQZone){
        
        //QQ空间
        [parameters SSDKSetupQQParamsByText:@"" title:title url:[NSURL URLWithString:h5url] audioFlashURL:nil videoFlashURL:nil thumbImage:nil images:@[[self thumbnailWithImageWithoutScale:self.thumbImage size:CGSizeMake(500, 500)]] type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeQZone];
        
    }else if (shareType == SSDKPlatformTypeFacebook){
        
        //Facebook
        if ([self.filePath rangeOfString:@"jpg"].location != NSNotFound) {
            [parameters SSDKSetupFacebookParamsByText:self._textView.text image:self.thumbImage type:SSDKContentTypeImage];
        }else{
            [parameters SSDKSetupFacebookParamsByText:self._textView.text image:[self thumbnailWithImageWithoutScale:self.thumbImage size:CGSizeMake(500, 500)] url:[NSURL URLWithString:h5url] urlTitle:nil urlName:nil attachementUrl:nil type:SSDKContentTypeWebPage];
        }
        
        
    }else if (shareType == SSDKPlatformTypeTwitter){
        
        //Twitter
        NSString *text = [NSString stringWithFormat:@"%@\n%@",self._textView.text,h5url];
        [parameters SSDKSetupTwitterParamsByText:text images:self.thumbImage latitude:0 longitude:0 type:SSDKContentTypeImage];
        
    }
    
    __weak typeof(self) weakself = self;
    
    [ShareSDK share:shareType parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         weakself.shareBtn.enabled = YES;
         //ShareCoverView
         if (error) {
             if (error.code == 0) {
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
             }else{
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
             }
             NSLog(@"%@",error);
         } else {
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     int64_t delayInSeconds = 1.5;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                         
                         [super backAction];
                         
                     });
                     
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
                     break;
                 }
                 default:
                     break;
             }
         }
         //
         
     }];
}

-(void)addToExplore
{
    //添加一条记录到分享记录
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    int64_t time = (int64_t)[timeString longLongValue];
    NSError * error = nil;
    DataPointSeg * seg1 = [[DataPointSeg alloc]init];
    seg1.msgId = 606;
    int64_t version = [[NSDate date] timeIntervalSince1970]*1000;
    seg1.version = version;
    int regionType = [JFGSDK getRegionType];
    
    NSString *fileName = [self.filePath lastPathComponent];
    int fileType = 0;
    //0-附带图片，1-附带视频
    if ([fileName rangeOfString:@".jpg"].location != NSNotFound) {
        fileType = 0;
    }else{
        fileType = 1;
    }
    
    NSString *content = @"";
    if (![self._textView.text isEqualToString:@""]) {
        content = self._textView.text;
    }else{
        if ([OemManager oemType] == oemTypeDoby) {
            content = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Description_zhongxing"];
        }else{
            content = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Description"];
        }
        
    }
    
    seg1.value = [MPMessagePackWriter writeObject:@[self.cid,[NSNumber numberWithLongLong:time],@(fileType),@(regionType),[self.filePath lastPathComponent],content,h5url] error:&error];
    
    __weak typeof(self) weakSelf = self;
    
    NSNumber *num = [[JFGSDKDataPoint sharedClient] robotSetDataByTimeWithPeer:self.cid dsp:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        for (DataPointIDVerRetSeg *seg in dataList) {
            
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            NSLog(@"ret:%d",seg.ret);
            if (seg.ret == 0) {
                NSString *fileName = [weakSelf.filePath lastPathComponent];
                //0-附带图片，1-附带视频
                if ([fileName rangeOfString:@".jpg"].location == NSNotFound) {
                    //视频，需要自己上传缩略图
                    NSString *newName = [fileName stringByDeletingPathExtension];
                    newName = [newName stringByAppendingString:@".jpg"];
                    NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,weakSelf.cid,newName];
                    NSLog(@"wonderFilePath:%@",wonderFilePath);
                    
                    if (weakSelf.thumbImage) {
                        
                        NSData *data = UIImageJPEGRepresentation(weakSelf.thumbImage, 1);
                        NSString *tmpDir =  NSTemporaryDirectory();
                        NSString *tempPath = [tmpDir stringByAppendingPathComponent:@"temp.jpg"];
                        if ([data writeToFile:tempPath atomically:YES]) {
                            [JFGSDK uploadFile:tempPath toCloudFolderPath:wonderFilePath];
                        }
                    }
                }
            }
            break;
            
        }
    } failure:^(RobotDataRequestErrorType type) {
        
        NSLog(@"%ld",(long)type);
    }];
    
    NSLog(@"%@",num);
}

-(void)refreshAction
{
    [self uploadFileForPath:self.filePath];
}

-(void)backAction
{
    
    //__weak typeof(self) weakSelf = self;
    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_UnshareTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
        
    } OKBlock:^{
        
        [super backAction];
        
    }];

}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 128) {
        textView.text = [textView.text substringToIndex:128];
    }
    if (textView.text.length>0) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
    self.countLabel.text = [NSString stringWithFormat:@"%u",128 - textView.text.length];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    self.titleLabel.text = [self titleFovVC];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 350*0.5)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    [bgView addSubview:self.iconImageView];
    [bgView addSubview:self.progressLabel];
    [bgView addSubview:self.refreshButton];
    [bgView addSubview:self._textView];
    [bgView addSubview:self.countLabel];
    [bgView addSubview:self.placeholderLabel];
   
    self.iconImageView.image = [UIImage imageNamed:@"testpic"];
    if (self.thumbImage) {
        self.iconImageView.image = self.thumbImage;
    }
    [self.view addSubview:self.instructionLabel];
}

-(NSString *)titleFovVC
{
    SSDKPlatformType shareType = self.platformType;

    NSString *title = @"";
    if (shareType ==SSDKPlatformSubTypeWechatTimeline) {
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],[JfgLanguage getLanTextStrByKey:@"Tap2_Share_Moments"]];
        
    }else if (shareType ==SSDKPlatformSubTypeWechatSession){
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],[JfgLanguage getLanTextStrByKey:@"Tap2_Share_Wechat"]];
        
    }else if (shareType == SSDKPlatformTypeSinaWeibo){
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],[JfgLanguage getLanTextStrByKey:@"Weibo"]];
       
    }else if (shareType == SSDKPlatformSubTypeQQFriend){
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],@"QQ"];
        
    }else if (shareType == SSDKPlatformSubTypeQZone){
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],[JfgLanguage getLanTextStrByKey:@"Qzone_QQ"]];
        
    }else if (shareType == SSDKPlatformTypeFacebook){
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],@"Facebook"];
        
    }else if (shareType == SSDKPlatformTypeTwitter){
        
        title = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"ShareTo" ],@"Twitter"];
       
    }
    return title;
}

-(void)initNavigationBar
{
    [self.backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.backBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
    [self.topBarBgView addSubview:self.shareBtn];
    
    [self.shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topBarBgView.mas_right).offset(-5);
        make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
        make.height.greaterThanOrEqualTo(@50);
        make.width.greaterThanOrEqualTo(@50);
    }];
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image)
    {
        newimage = nil;
    } else {
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height)
            
        {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = (asize.width - rect.size.width)/2;
            
            rect.origin.y = 0;
            
        } else {
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}

-(UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(0, self.backBtn.top, self.backBtn.width, self.backBtn.height);
        _shareBtn.isRelatingNetwork = YES;
        _shareBtn.right = self.view.width - self.backBtn.left;
        _shareBtn.titleLabel.font = self.backBtn.titleLabel.font;
        _shareBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        _shareBtn.adjustsImageWhenDisabled = NO;
        [_shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"] forState:UIControlStateNormal];
        [_shareBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
        _shareBtn.enabled = NO;
    }
    return _shareBtn;
}


-(UIButton *)refreshButton
{
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.frame = CGRectMake(15, 15, 64, 64);
        _refreshButton.layer.masksToBounds = YES;
        _refreshButton.layer.cornerRadius = 32;
        [_refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
        [_refreshButton setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
        _refreshButton.hidden = YES;
    }
    return _refreshButton;
}

-(UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]initWithFrame:self.refreshButton.frame];
        _progressLabel.layer.masksToBounds = YES;
        _progressLabel.layer.cornerRadius = 32;
        _progressLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:15];
        _progressLabel.text = @"0%";
        _progressLabel.textColor = [UIColor whiteColor];
    }
    return _progressLabel;
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:self.refreshButton.frame];
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.layer.cornerRadius = 32;
    }
    return _iconImageView;
}

-(UITextView *)_textView
{
    if (!__textView) {
        __textView = [[UITextView alloc]initWithFrame:CGRectMake(188*0.5, 15, self.view.width-188*0.5-15, 130)];
        __textView.textColor = [UIColor colorWithHexString:@"#666666"];
        __textView.font = [UIFont systemFontOfSize:14];
        __textView.delegate = self;
        //__textView.tintColor =
    }
    return __textView;
}

-(UILabel *)countLabel
{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self._textView.bottom+8, 50, 12)];
        _countLabel.right = self.view.width-15;
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.font = [UIFont systemFontOfSize:13];
        _countLabel.textColor = [UIColor colorWithHexString:@"#adadad"];
        _countLabel.text = @"128";
    }
    return _countLabel;
}

-(UILabel *)placeholderLabel
{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(self._textView.left+5, self._textView.top+9, self._textView.width-10, 15)];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Share_Description"];
        _placeholderLabel.textColor = [UIColor colorWithHexString:@"#cecece"];
    }
    return _placeholderLabel;
}

-(UILabel *)instructionLabel
{
    if (!_instructionLabel) {
        _instructionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 350*0.5+64+10, self.view.width - 30, 30)];
        _instructionLabel.font = [UIFont systemFontOfSize:13];
        _instructionLabel.numberOfLines = 0;
        _instructionLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _instructionLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Share_To_Daily_Great"];
        [_instructionLabel sizeToFit];
    }
    return _instructionLabel;
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
