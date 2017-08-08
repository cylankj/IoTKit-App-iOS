//
//  AKWebView.m
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2016/12/27.
//  Copyright © 2016年 Kuture. All rights reserved.
//

#import "AKWebView.h"

@interface AKWebView ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong) NSURLConnection *urlConnection;
@property (nonatomic,strong) NSURLRequest *requestW;
@property (nonatomic) SSLAuthenticate authenticated;

@end

@implementation AKWebView

+(instancetype)shareWebView{
    static dispatch_once_t onece = 0;
    static AKWebView *webView = nil;
    dispatch_once(&onece, ^(void){
        webView = [[self alloc]init];
        
    });
    return webView;
}



#pragma mark ***UIWebView 加载方法***
- (void)webViewWithLoadRequestWithURL:(NSURL *)url Fram:(CGRect)fram{
    
    self.frame = fram;
    self.UIDelegate = self;
    self.navigationDelegate = self;
    _requestW = [NSURLRequest requestWithURL:url];
    [self loadRequest:_requestW];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == self) {
            
          
            NSLog(@"webLoadingProgress:%f",self.estimatedProgress);
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
        
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self) {
            
           
            NSLog(@"webTitle:%@",self.title);
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
    }
    else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark ***UIWebView 代理方法***
//https授权
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *credential = [[NSURLCredential     alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (self.webDelegate && [self.webDelegate respondsToSelector:@selector(akWebViewDidStartLoad:)]) {
        [self.webDelegate akWebViewDidStartLoad:self];
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.webDelegate && [self.webDelegate respondsToSelector:@selector(akWebView:didFailLoadWithError:)]) {
        [self.webDelegate akWebView:self didFailLoadWithError:error];
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (self.webDelegate && [self.webDelegate respondsToSelector:@selector(akWebViewDidFinishLoad:)]) {
        [self.webDelegate akWebViewDidFinishLoad:self];
    }
    NSLog(@"webTitle:%@",self.title);
    if (self.webDelegate && [self.webDelegate respondsToSelector:@selector(akWebViewTitle:)]) {
        
        [self.webDelegate akWebViewTitle:self.title];
    }
}


@end
