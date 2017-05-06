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


#define UPLOADOVERTIMECOUNT 60

@interface ShareVideoViewController ()<UITextViewDelegate,JFGSDKCallbackDelegate>
{
    uint64_t _seq;
    NSTimer *_timer;
    int uploadProgress;
    NSString *h5url;
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
    [self initNavigationBar];
    [self initView];
    [JFGSDK addDelegate:self];
    [self uploadFileForPath:self.filePath];
    // Do any additional setup after loading the view.
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
        
        [JFGSDK getVideoShareUrlForFileName:wonderFilePath content:self._textView.text ossType:[JFGSDK getRegionType] shareType:1];
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
        self.progressLabel.text = @"%0";
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
    if (!online) {
        [self stopTimer];
        self.progressLabel.hidden = YES;
        self.progressLabel.text = @"%0";
        self.refreshButton.hidden = NO;
    }
}

-(void)jfgVideoShareUrl:(NSString *)url
{
    NSLog(@"%@",url);
    if (url) {
        h5url = [NSString stringWithString:url];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"sharevideoVC sharevideoUrl %@",url]];
    }
    
}


//文件上传结果回调
-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    if (requestID == _seq) {
        
        [self stopTimer];
        if (ret == 200) {
            
            self.progressLabel.text = @"100%";
            self.shareBtn.enabled = YES;
            self.refreshButton.hidden = YES;
            
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"shareVideoVC file end upload success %llu",_seq]];
            //添加一条记录到每日精彩
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
            int64_t time = (int64_t)[timeString longLongValue];
            NSError * error = nil;
            DataPointSeg * seg1 = [[DataPointSeg alloc]init];
            seg1.msgId = 602;
            int64_t version = [[NSDate date] timeIntervalSince1970]*1000;
            seg1.version = version;
            int regionType = [JFGSDK getRegionType];
            seg1.value = [MPMessagePackWriter writeObject:@[self.cid,[NSNumber numberWithLongLong:time],@0,@(regionType),[self.filePath lastPathComponent],self.devAlias,@(0)] error:&error];
            
            [[JFGSDKDataPoint sharedClient] robotSetDataByTimeWithPeer:self.cid dsp:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                for (DataPointIDVerRetSeg *seg in dataList) {
            
                    NSLog(@"ret:%d",seg.ret);
                    if (seg.ret == 0) {
                        
                    }else if(seg.ret == 1050){
                        //超过收藏值
                        
                    }
                    break;
                    
                }
            } failure:^(RobotDataRequestErrorType type) {
                
                
                
            }];
            
        }else{
            //上传失败
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"shareVideoVC file end upload failed %llu",_seq]];
            self.progressLabel.hidden = YES;
            self.progressLabel.text = @"%0";
            self.refreshButton.hidden = NO;
        }
        
    }
}

-(void)shareAction
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    
    SSDKPlatformType shareType = self.platformType;

    if (shareType ==SSDKPlatformSubTypeWechatTimeline || shareType ==SSDKPlatformSubTypeWechatSession) {
        
        //微信
        [parameters SSDKSetupWeChatParamsByText:self._textView.text title:@"" url:[NSURL URLWithString:h5url] thumbImage:self.thumbImage image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:shareType];
        
    }else if (shareType == SSDKPlatformTypeSinaWeibo){
        
        //新浪微博
        [parameters SSDKSetupSinaWeiboShareParamsByText:self._textView.text title:@"" image:self.thumbImage url:[NSURL URLWithString:h5url] latitude:0 longitude:0 objectID:nil type:SSDKContentTypeWebPage];
        
    }else if (shareType == SSDKPlatformSubTypeQQFriend || shareType == SSDKPlatformSubTypeQZone){
        
        //QQ
        [parameters SSDKSetupQQParamsByText:self._textView.text title:@"" url:[NSURL URLWithString:h5url] thumbImage:self.thumbImage image:nil type:SSDKContentTypeWebPage forPlatformSubType:shareType];
        
    }else if (shareType == SSDKPlatformTypeFacebook){
        
        //Facebook
        [parameters SSDKSetupFacebookParamsByText:self._textView.text image:self.thumbImage url:[NSURL URLWithString:h5url] urlTitle:@"" urlName:@"" attachementUrl:nil type:SSDKContentTypeWebPage];
        
    }else if (shareType == SSDKPlatformTypeTwitter){
        
        [parameters SSDKSetupTwitterParamsByText:self._textView.text images:self.thumbImage latitude:0 longitude:0 type:SSDKContentTypeImage];
        
    }
    
    [ShareSDK share:shareType parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         //ShareCoverView
         if (error) {
             if (error.code == 0) {
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
             }else{
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
             }
         } else {
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     
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

-(void)refreshAction
{
    [self uploadFileForPath:self.filePath];
}

-(void)backAction
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_UnshareTips"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"OK"], nil];
    [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [super backAction];
        }
    } otherDelegate:nil];
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
    self.titleLabel.text = @"分享给微信";
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 350*0.5)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    [bgView addSubview:self.iconImageView];
    [bgView addSubview:self.progressLabel];
    [bgView addSubview:self.refreshButton];
    [bgView addSubview:self._textView];
    [bgView addSubview:self.countLabel];
    [bgView addSubview:self.placeholderLabel];
    [self.view addSubview:self.instructionLabel];
    
    self.iconImageView.image = [UIImage imageNamed:@"testpic"];
}

-(void)initNavigationBar
{
    [self.backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.backBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
    [self.topBarBgView addSubview:self.shareBtn];
}

-(UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(0, self.backBtn.top, self.backBtn.width, self.backBtn.height);
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
        _progressLabel.text = @"25%";
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
    }
    return __textView;
}

-(UILabel *)countLabel
{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self._textView.bottom+8, 50, 12)];
        _countLabel.right = self.view.width-15;
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.font = [UIFont systemFontOfSize:11];
        _countLabel.textColor = [UIColor colorWithHexString:@"#adadad"];
        _countLabel.text = @"128";
    }
    return _countLabel;
}

-(UILabel *)placeholderLabel
{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(self._textView.left+5, self._textView.top+9, self._textView.width-10, 15)];
        _placeholderLabel.font = [UIFont systemFontOfSize:12];
        _placeholderLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Share_Description"];
        _placeholderLabel.textColor = [self._textView.textColor colorWithAlphaComponent:0.6];
    }
    return _placeholderLabel;
}

-(UILabel *)instructionLabel
{
    if (!_instructionLabel) {
        _instructionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 350*0.5+64+10, self.view.width - 50, 13)];
        _instructionLabel.font = [UIFont systemFontOfSize:12];
        _instructionLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _instructionLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Share_To_Daily_Great"];
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
