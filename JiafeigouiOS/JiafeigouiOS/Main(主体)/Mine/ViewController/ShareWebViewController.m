//
//  ShareWebViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/24.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ShareWebViewController.h"
#import "JfgLanguage.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "OemManager.h"
#import <Masonry.h>
#import "CommonMethod.h"
#import "LoginManager.h"
#import "ShareView.h"
#import "ProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "LSAlertView.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "AKWebView.h"
#import "UIAlertView+FLExtension.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "WebviewProgressLine.h"

@interface ShareWebViewController ()<AKWebViewDelegate>
@property (nonatomic,strong)UIButton *shareBtn;
@property (nonatomic,strong)UIButton *delBtn;
@property (nonatomic,strong)AKWebView *myWebView;
@property (nonatomic,strong)WebviewProgressLine *progressLine;
@end

@implementation ShareWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.topBarBgView addSubview:self.delBtn];
    [self.topBarBgView addSubview:self.shareBtn];
    [self.view addSubview:self.myWebView];
    [self.progressLine startLoadingAnimation];
    
    __weak typeof(self) weakSelf = self;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(weakSelf.topBarBgView.width - 160);
    }];
    if ([OemManager oemType] == oemTypeDoby) {
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title_zhognxing"];
    }else{
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_myWebView webViewWithLoadRequestWithURL:[NSURL URLWithString:self.h5Url] Fram:CGRectMake(0, 64, self.view.width, self.view.height-64)];
}
 
-(void)shareAction
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return ;
    }

    ShareView *sv = [[ShareView alloc]initWithLandScape:NO];
    [sv showShareView:^(SSDKPlatformType platformType) {
        
        NSString *title = [OemManager appName];
        
        //全景图片  Tap1_Shared_Title
        if ([OemManager oemType] == oemTypeDoby) {
            title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title_zhognxing"];
        }else{
            title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title"];
        }
        [self shareToThirdpartyPlatform:platformType url:self.h5Url image:self.thumdImage title:title contentType:SSDKContentTypeWebPage];
        
    } cancel:^{
        
    }];

}

-(void)delAction
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Delete_Share"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
        
    } OKBlock:^{
        
        DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
        seg.msgId = 606;
        seg.version = weakSelf.version;
        
        [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
            if (ret == 0) {
                NSLog(@"delete success");
            }
        } failure:^(RobotDataRequestErrorType type) {
            NSLog(@"delete fail:%ld",(long)type);
        }];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didDelShareContentForVersion:)]) {
            [weakSelf.delegate didDelShareContentForVersion:weakSelf.version];
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }];
}

-(void)akWebViewDidFinishLoad:(AKWebView *)webView
{
    [self.progressLine endLoadingAnimation];
}


-(void)akWebView:(AKWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.progressLine endLoadingAnimation];
}

-(void)shareToFacebookWithContentText:(NSString *)text title:(NSString *)title image:(UIImage *)image url:(NSString *)url contentType:(SSDKContentType)contentType
{
    if (image) {
        
        [SSUIEditorViewStyle setTitle:@"Share To Facebook"];
        
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:@[image]
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        [ShareSDK showShareEditor:SSDKPlatformTypeFacebook
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             
             if (error) {
                 
                 NSLog(@"faceBook分享错误：userInfo:%@",error);
                 if (error.code == 0) {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
                 
                 
             }
             
             switch (state) {
                     
                 case SSDKResponseStateBegin:
                 {
                     //[theController showLoadingView:YES];
                     break;
                 }
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 default:
                     break;
             }
             
             if (state != SSDKResponseStateBegin)
             {
                 
             }
         }];
    }
    
}

-(void)shareToTwitterWithContentText:(NSString *)text title:(NSString *)title image:(UIImage *)image url:(NSString *)url
{
    //UIImage *im = [UIImage imageNamed:@"icon_facebook"];
    //创建分享参数
    //NSArray* imageArray = @[[UIImage imageNamed:@"shareImg.png"]];
    
    if (image) {
        
        [SSUIEditorViewStyle setTitle:@"Share To Twitter"];
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:@[image]
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        [ShareSDK showShareEditor:SSDKPlatformTypeTwitter
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             
             if (error) {
                 if (error.code == 0) {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
             }
             
             switch (state) {
                     
                 case SSDKResponseStateBegin:
                 {
                     //[theController showLoadingView:YES];
                     break;
                 }
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     // [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     // [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 default:
                     break;
             }
             
             if (state != SSDKResponseStateBegin)
             {
                 
             }
         }];
    }
    
}

-(void)shareToThirdpartyPlatform:(SSDKPlatformType)platformType url:(NSString *)url image:(UIImage *)image title:(NSString *)title contentType:(SSDKContentType)contentType
{
    if (platformType == SSDKPlatformSubTypeWechatSession || platformType == SSDKPlatformSubTypeWechatTimeline) {
        if (![ShareSDK isClientInstalled:platformType]) {
            NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],[JfgLanguage getLanTextStrByKey:@"WeChat"]];
            [ProgressHUD showText:als];
            return;
        }
        
    }else if (platformType == SSDKPlatformSubTypeQQFriend || platformType == SSDKPlatformSubTypeQZone){
        if (![ShareSDK isClientInstalled:SSDKPlatformSubTypeQQFriend]) {
            NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],@"QQ"];
            [ProgressHUD showText:als];
            return;
        }
    }
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    SSDKPlatformType shareType = platformType;
    
    if (shareType ==SSDKPlatformSubTypeWechatTimeline || shareType ==SSDKPlatformSubTypeWechatSession) {
        
        //微信
        if (contentType == SSDKContentTypeImage) {
            [parameters SSDKSetupWeChatParamsByText:@"" title:title url:[NSURL URLWithString:url] thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeImage forPlatformSubType:shareType];
        }else{
            [parameters SSDKSetupWeChatParamsByText:@"" title:[JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title"] url:[NSURL URLWithString:url] thumbImage:image image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:shareType];
        }
        
    }else if (shareType == SSDKPlatformTypeSinaWeibo){
        
        //新浪微博
        [parameters SSDKSetupSinaWeiboShareParamsByText:([JfgLanguage languageType] == 0)?@"加菲狗":@"Clever Dog" title:title image:image url:[NSURL URLWithString:url] latitude:0 longitude:0 objectID:nil type:contentType];
        
    }else if (shareType == SSDKPlatformSubTypeQQFriend || shareType == SSDKPlatformSubTypeQZone){
        
        //QQ
        [parameters SSDKSetupQQParamsByText:@"" title:title url:[NSURL URLWithString:url] thumbImage:nil image:[CommonMethod thumbnailWithImageWithoutScale:image size:CGSizeMake(500, 500)] type:contentType forPlatformSubType:SSDKPlatformSubTypeQQFriend];
        shareType = SSDKPlatformSubTypeQQFriend;
        
    }
//    else if(shareType == SSDKPlatformSubTypeQZone){
//        
//        //QQ空间
//        [parameters SSDKSetupQQParamsByText:@"" title:title url:[NSURL URLWithString:url] audioFlashURL:nil videoFlashURL:nil thumbImage:nil images:@[[CommonMethod thumbnailWithImageWithoutScale:image size:CGSizeMake(500, 500)]] type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeQZone];
//        
//    }
    else if (shareType == SSDKPlatformTypeFacebook){
        
        //Facebook
        //[parameters SSDKSetupFacebookParamsByText:@"" image:image url:[NSURL URLWithString:url] urlTitle:title urlName:@"" attachementUrl:nil type:contentType];
        [self shareToFacebookWithContentText:@"" title:title image:image url:url contentType:contentType];
        return;
    }else if (shareType == SSDKPlatformTypeTwitter){
        
        //Twitter
        //        if (contentType == SSDKContentTypeImage) {
        //
        //        }else{
        
        //            [parameters SSDKSetupTwitterParamsByText:text images:image latitude:0 longitude:0 type:SSDKContentTypeImage];
        //        }
        NSString *text = [NSString stringWithFormat:@"%@\n%@",title,url];
        [self shareToTwitterWithContentText:text title:@"" image:image url:url];
        return;
        
    }
    
    //__weak typeof(self) weakself = self;
    
    [ShareSDK share:shareType parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         
         //ShareCoverView
         if (error) {
             if (error.code == 0) {
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
             }else{
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
             }
             NSLog(@"shareError:%@",error);
         } else {
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     if (shareType == SSDKPlatformSubTypeWechatSession) {
                         if (![ShareSDK isClientInstalled:shareType]) {
                             NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],[JfgLanguage getLanTextStrByKey:@"WeChat"]];
                             [ProgressHUD showText:als];
                             break;
                         }else if (shareType == SSDKPlatformSubTypeQQFriend || shareType == SSDKPlatformSubTypeQZone){
                             NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],@"QQ"];
                             [ProgressHUD showText:als];
                             break;
                         }
                         
                     }
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
         
     }];
}



-(UIButton *)delBtn
{
    if (!_delBtn) {
        _delBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_delBtn setImage:[UIImage imageNamed:@"album_icon_delete"] forState:UIControlStateNormal];
        _delBtn.frame = CGRectMake(0, 10.5+20, 23, 23);
        _delBtn.right = self.view.width - 15;
        [_delBtn addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _delBtn;
}

-(UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(0, 10.5+20, 23, 23);
        _shareBtn.right = self.delBtn.left - 18;
        [_shareBtn setImage:[UIImage imageNamed:@"details_icon_share"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

-(AKWebView *)myWebView
{
    if (!_myWebView) {
        _myWebView = [AKWebView shareWebView];
       
        _myWebView.webDelegate = self;
    }
    return _myWebView;
}

-(WebviewProgressLine *)progressLine
{
    if (!_progressLine) {
        _progressLine = [[WebviewProgressLine alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 4)];
        _progressLine.lineColor = [UIColor colorWithHexString:@"#36bdff"];
        [self.view addSubview:_progressLine];
    }
    return _progressLine;
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
