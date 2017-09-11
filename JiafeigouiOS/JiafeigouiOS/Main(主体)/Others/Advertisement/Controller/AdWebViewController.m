
//
//  AdWebViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AdWebViewController.h"
#import "AKWebView.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "WebviewProgressLine.h"
#import "ShareView.h"
#import "ProgressHUD.h"
#import "JfgLanguage.h"
#import "LSAlertView.h"
#import "FLShareSDKHelper.h"

@interface AdWebViewController ()<AKWebViewDelegate>
{
    NSString *webImageUrl;
    UIImage *fristWebImage;
}
@property (nonatomic,strong)AKWebView *_akwebView;
@property (nonatomic,strong)WebviewProgressLine *progressLine;
@property (nonatomic,strong)UIButton *shareBtn;
@end

@implementation AdWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBarBgView addSubview:self.shareBtn];
    self.shareBtn.enabled = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self._akwebView webViewWithLoadRequestWithURL:[NSURL URLWithString:self.url] Fram:self._akwebView.frame];
}


-(void)akWebViewDidStartLoad:(AKWebView *)webView
{
    [self.progressLine startLoadingAnimation];
}

-(void)akWebView:(AKWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.progressLine endLoadingAnimation];
}

-(void)akWebViewDidFinishLoad:(AKWebView *)webView
{
    NSString *js = @"document.getElementsByTagName(\"img\")[0].src;";
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
    
        if (response && [response isKindOfClass:[NSString class]]) {
            webImageUrl = response;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                 NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webImageUrl]];
                fristWebImage = [UIImage imageWithData:imgData];
            });
           
            
        }
        
    }];
    self.shareBtn.enabled = YES;
    [self.progressLine endLoadingAnimation];
}

-(void)akWebViewTitle:(NSString *)title
{
    self.titleLabel.text = title;
}



-(AKWebView *)_akwebView
{
    if (__akwebView == nil) {
        __akwebView = [[AKWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
        __akwebView.webDelegate = self;
        [self.view addSubview:__akwebView];
    }
    return __akwebView;
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

-(UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(0, 10.5+20, 23, 23);
        _shareBtn.right = self.view.width - 16;
        [_shareBtn setImage:[UIImage imageNamed:@"details_icon_share"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

-(void)shareAction
{
    ShareView *sv = [[ShareView alloc]initWithLandScape:NO];
    [sv showShareView:^(SSDKPlatformType platformType) {
        
        UIImage* image = nil;
        if (fristWebImage) {
            image = fristWebImage;
        }else{
            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
            NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
            image = [UIImage imageNamed:icon];
        }
        
        [FLShareSDKHelper shareToThirdpartyPlatform:platformType url:self.url image:image title:self.titleLabel.text contentType:SSDKContentTypeWebPage];
        
    } cancel:^{
        
    }];
    
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





