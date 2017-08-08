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
#import "UIView+FLExtensionForFrame.h"
#import "WebviewProgressLine.h"

typedef NS_ENUM(NSInteger,WebLoadingState){
    
    WebLoadingStateLoading,
    WebLoadingStateLoadFinished,
    WebLoadingStateLoadFailed,
    
};

@interface JFGHelpViewController ()<UIWebViewDelegate,WKNavigationDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,AKWebViewDelegate>
{
    WebLoadingState loadState;
    NSString *_url;
    AKWebView *_akwebView;
    BOOL isDidFinished;
}

@property (nonatomic,assign)NSUInteger loadCount;
@property (nonatomic,strong)UILabel *redPoint;
@property (nonatomic,strong)WebviewProgressLine *progressLine;

@end

@implementation JFGHelpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_Feedback"];
    [self.topBarBgView addSubview:self.redPoint];
    
    if (self.isXieyi) {
        [self xieyi];
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"TERM_OF_USE"];
    }else{
        [self moreLanguage];
    }
    
    _akwebView = [[AKWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    _akwebView.webDelegate = self;
    [self.view addSubview:_akwebView];
    if (self.showRightBarItem) {
        [self rightBarItem];
    }
    [self.progressLine startLoadingAnimation];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!isDidFinished) {
        [_akwebView webViewWithLoadRequestWithURL:[NSURL URLWithString:_url] Fram:_akwebView.frame];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isShowRedPoint) {
        self.redPoint.hidden = NO;
    }else{
        self.redPoint.hidden = YES;
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

-(void)akWebViewDidFinishLoad:(AKWebView *)webView
{
    isDidFinished = YES;
    [self.progressLine endLoadingAnimation];
}



-(void)akWebView:(AKWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.progressLine endLoadingAnimation];
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

    self.isShowRedPoint = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(UILabel *)redPoint
{
    if (!_redPoint) {
        UILabel *redLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        redLabel.backgroundColor = [UIColor redColor];
        redLabel.right = self.view.width-9;
        redLabel.y = 34;
        redLabel.hidden = YES;
        redLabel.layer.masksToBounds = YES;
        redLabel.layer.cornerRadius = 4;
        _redPoint = redLabel;
    }
    return _redPoint;
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
