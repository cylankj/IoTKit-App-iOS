//
//  JFGWebViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGWebViewController.h"
#import "FLGlobal.h"
#import "JfgLanguage.h"
@interface JFGWebViewController ()
@property(nonatomic, strong)UIWebView *_webView;

@end

@implementation JFGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self._webView];
    switch (self.type) {
        case webViewTypeJFG:{
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"WEB"];
            self.urlString = [JfgLanguage getLanTextStrByKey:@"web"];
            [self loadWebView];
        }
            break;
        case webViewTypeUserProtocol:
        {
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"TERM_OF_USE"];
            BOOL isOem = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"oemname"] isEqualToString:@"zhongxing"]; // 是否是中性版本
            NSString *oemString = isOem?@"_zhongxing":@"";
            NSString *cnString = ([JfgLanguage languageType] == LANGUAGE_TYPE_CHINESE)?@"_cn":@"_en";
            self.urlString = [NSString stringWithFormat:@"http://www.jfgou.com/app/treaty%@%@.html",oemString,cnString];
            [self loadWebView];
        }
            break;
        case webViewTypePhone:{
            self.urlString = self.urlString;

        }
            break;
        case webViewTypeAd:
        {
            [self loadWebView];
        }
            break;
        default:
            break;
    }
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];

}
-(void)loadWebView{
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self._webView loadRequest:req];
}
-(void)leftButtonAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
-(UIWebView *)_webView{
    if (!__webView) {
        __webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, Kwidth, kheight-64)];

    }
    return __webView;
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
