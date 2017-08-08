//
//  AKWebView.h
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2016/12/27.
//  Copyright © 2016年 Kuture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class AKWebView;

@protocol AKWebViewDelegate <NSObject>

@optional

-(void)akWebViewDidFinishLoad:(AKWebView *)webView;
-(void)akWebViewDidStartLoad:(AKWebView *)webView;
-(void)akWebViewTitle:(NSString *)title;
-(void)akWebView:(AKWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface AKWebView : WKWebView

//回调加载网页标题
@property (nonatomic,weak)id <AKWebViewDelegate> webDelegate;

+(instancetype)shareWebView;
- (void)webViewWithLoadRequestWithURL:(NSURL *)url Fram:(CGRect)fram;

@end
