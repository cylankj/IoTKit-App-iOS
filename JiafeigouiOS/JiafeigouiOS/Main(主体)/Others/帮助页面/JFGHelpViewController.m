//
//  JFGHelpViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/19.
//  Copyright © 2016年 lirenguang. All rights reserved.
//  http://yun.jfgou.com/help/zh-rCN.html

#import "JFGHelpViewController.h"
#import <WebKit/WebKit.h>
#import "UIColor+FLExtension.h"
#import "HelpViewController.h"
#import <JFGSDK/JFGSDKToolMethods.h>
#import "OemManager.h"
#import "JfgLanguage.h"
#import "AKWebView.h"

typedef NS_ENUM(NSInteger,WebLoadingState){
    
    WebLoadingStateLoading,
    WebLoadingStateLoadFinished,
    WebLoadingStateLoadFailed,
    
};

@interface JFGHelpViewController ()<UIWebViewDelegate,WKNavigationDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    WebLoadingState loadState;
    NSString *_url;
    
}
@property (nonatomic,strong)WKWebView *webView;
@property (nonatomic,strong)UIWebView *uiWebView;
@property (nonatomic,strong)UIProgressView *progressView;
@property (nonatomic,assign)NSUInteger loadCount;
@property (nonatomic,strong) NSURLConnection *urlConnection;
@property (nonatomic,strong) NSURLRequest *requestW;
@property (nonatomic) SSLAuthenticate authenticated;
@end

@implementation JFGHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_Feedback"];
    [self.view addSubview:self.progressView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    if (self.isXieyi) {
        [self xieyi];
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"TERM_OF_USE"];
    }else{
        [self moreLanguage];
    }
    
    
    AKWebView *_akwebView = [[AKWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    [_akwebView webViewWithLoadRequestWithURL:[NSURL URLWithString:_url] Fram:_akwebView.frame];
    [self.view addSubview:_akwebView];
    if (self.showRightBarItem) {
        [self rightBarItem];
    }
    
}

-(void)xieyi
{
    _url = [OemManager getOemProtocolUrl];
}

-(void)moreLanguage
{
    _url = [OemManager getOemHelpUrl];
}

-(void)rightBarItem
{
    UIButton *_editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(self.view.frame.size.width-60-20, 5+20, 70, 34);
    [_editBtn setTitle:[JfgLanguage getLanTextStrByKey:@"FEEDBACK"] forState:UIControlStateNormal];
    _editBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.topBarBgView addSubview:_editBtn];
    [_editBtn addTarget:self action:@selector(clickEditBtn) forControlEvents:UIControlEventTouchUpInside];
}

-(void)clickEditBtn
{
    HelpViewController * help = [[HelpViewController alloc]init];
    help.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:help animated:YES];

}

-(void)tap:(UITapGestureRecognizer *)tap
{
    if (loadState == WebLoadingStateLoadFailed) {
        if (_webView) {
            [_webView reload];
        }else{
            [_uiWebView reload];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLoadCount:(NSUInteger)loadCount
{
    
    _loadCount = loadCount;
    
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
        
    }
}


#pragma mark- WKWebView Delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* scheme = [[request URL] scheme];
    NSLog(@"scheme = %@",scheme);
    //判断是不是https
    if ([scheme containsString:@"https"]) {
        //如果是https:的话，那么就用NSURLConnection来重发请求。从而在请求的过程当中吧要请求的URL做信任处理。
        if (!_authenticated) {
            _authenticated = kNeverAuthenticate;
            
            _urlConnection = [[NSURLConnection alloc] initWithRequest:_requestW delegate:self];
            
            [_urlConnection start];
            return NO;
        }
    }
    return YES;
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    
//    NSString* scheme = [webView.URL scheme];
//    NSLog(@"scheme = %@",scheme);
//    //判断是不是https
//    if ([scheme containsString:@"https"]) {
//        //如果是https:的话，那么就用NSURLConnection来重发请求。从而在请求的过程当中吧要请求的URL做信任处理。
//        if (!self.isAuthed) {
//            NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:webView.URL] delegate:self];
//            [conn start];
//
//        }
//    }
//    
//    self.webView.hidden = NO;
//    loadState = WebLoadingStateLoading;
//    self.loadCount ++;
}



// 内容返回时
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    self.loadCount --;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    loadState = WebLoadingStateLoadFinished;
    self.webView.hidden = NO;
}

//失败
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.loadCount --;
    loadState = WebLoadingStateLoadFailed;
    self.webView.hidden = YES;
    NSLog(@"%@",error);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        
    }}

#pragma mark- UIWebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.uiWebView.hidden = NO;
    self.loadCount ++;
    loadState = WebLoadingStateLoading;
}



-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    loadState = WebLoadingStateLoadFinished;
    self.uiWebView.hidden = NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadCount --;
    loadState = WebLoadingStateLoadFailed;
    self.uiWebView.hidden = YES;
}


#pragma mark ***NURLConnection 代理方法***
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSLog(@"WebController 已经得到授权正在请求 NSURLConnection");
    
    if ([challenge previousFailureCount] == 0){
        _authenticated = kTryAuthenticate;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    } else{
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"WebController 已经收到响应并通过了 NSURLConnection请求");
    
    _authenticated = kTryAuthenticate;
    [self.uiWebView loadRequest:_requestW];
    [_urlConnection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

#pragma mark- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loading"]) {
        
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = _webView.title;
    } else if ([keyPath isEqualToString:@"URL"]) {
        
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        //525 15558
        self.progressView.progress = _webView.estimatedProgress;
        NSLog(@"%f",self.progressView.progress);
    }
    
    if (object == _webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            
            
            [self.progressView setProgress:1 animated:YES];
            //
            int64_t delayInSeconds = 0.99;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.progressView.hidden = YES;
                
                
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}


#pragma mark- getter
-(WKWebView *)webView
{
    if (_webView == nil) {
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        //_webView.UIDelegate = self;
        //_webView.navigationDelegate = self;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}

-(UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 5)];
        _progressView.progressTintColor = [UIColor colorWithHexString:@"#36bdff"];
        _progressView.trackTintColor = [UIColor whiteColor];
        _progressView.progress = 0;
    
       
    }
    return _progressView;
}

-(UIWebView *)uiWebView
{
    if (!_uiWebView) {
        _uiWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _uiWebView.delegate = self;
        [_uiWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _uiWebView;
}


-(void)dealloc
{
    if (_webView) {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }else{
        [_uiWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
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
