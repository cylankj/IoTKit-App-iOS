//
//  WeiboLiveAPIHelper.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/12.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "WeiboLiveAPIHelper.h"
#import "ProgressHUD.h"
#import "JfgLanguage.h"
#import "LSAlertView.h"

@interface WeiboLiveAPIHelper()

@property (nonatomic) WeiboLiveSDK *weiboLiveSDK;
@property (nonatomic,copy)NSString *liveID;

@end

@implementation WeiboLiveAPIHelper

-(BOOL)hasAuthorized
{
    return [ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo];
}

-(void)createLiveWithHandler:(void(^)(NSError *error,id result))handler
{
    if ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            SSDKUser *user = [ShareSDK currentUser:SSDKPlatformTypeSinaWeibo];
            
            NSString *summary = [[NSUserDefaults standardUserDefaults] objectForKey:WEIBOLIVETITLEKEY];
            if (!summary || [summary isEqualToString:@""]) {
                summary = [JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"];
            }
            
            //文档地址：http://open.weibo.com/wiki/Live/api#.E6.8E.88.E6.9D.83.E6.9C.BA.E5.88.B6

            NSString *result = [self.weiboLiveSDK createLive:user.credential.token title:summary width:@"2560" height:@"1280" summary:summary published:@"0" image:nil replay:@"1" is_panolive:@"1"];
            NSError *_error = nil;
            if(result != nil){
                
                NSData* rd = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dataDic=[NSJSONSerialization JSONObjectWithData:rd options:NSJSONReadingMutableLeaves error:nil];
                NSString *error = [dataDic objectForKey:@"error"];
                if (error) {
                    
                    [LSAlertView showAlertWithTitle:@"ERROR" Message:[NSString stringWithFormat:@"error:%@ error_code:%@",[dataDic objectForKey:@"error"],[dataDic objectForKey:@"error_code"]] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
                        
                    } OKBlock:^{
                        
                    }];
                    _error = [NSError errorWithDomain:@"sina.weibolive.com" code:52 userInfo:@{@"reason":error}];
                    
                }else{
                    
                    NSString * liveid = [dataDic objectForKey:@"id"];//直播ID
                    //NSString* room_id = [dataDic objectForKey:@"room_id"];//房间号
                    NSString *url = [dataDic objectForKey:@"url"];//直播推流地址
                    self.liveID = [liveid copy];
                    NSLog(@"liveID:%@ url:%@",liveid,url);
                    
                }
                
                if (handler) {
                    
                    handler(_error,dataDic);
                }
                
            }else{
                
                [ProgressHUD showText:@"API直播接口权限未开通"];
                if (handler) {
                    NSError *_error = [NSError errorWithDomain:@"sina.weibolive.com" code:52 userInfo:@{@"reason":@"unauthorized"}];
                    handler(_error,nil);
                }
            }
            
            
            NSLog(@"%@",result);
            
        });
        
    }else{
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_BIND_TIPS"]];
        if (handler) {
            NSError *_error = [NSError errorWithDomain:@"sina.weibolive.com" code:52 userInfo:@{@"reason":@"unbind account"}];
            handler(_error,nil);
        }
        
    }
}

-(void)updateLive
{
    SSDKUser *user = [ShareSDK currentUser:SSDKPlatformTypeSinaWeibo];
    NSString *result = [self.weiboLiveSDK showLive:user.credential.token liveid:self.liveID detail:@"1"];
    NSData* rd = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataDic=[NSJSONSerialization JSONObjectWithData:rd options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dataDic);
}


-(WeiboLiveSDK *)weiboLiveSDK
{
    if (!_weiboLiveSDK) {
        _weiboLiveSDK = [[WeiboLiveSDK alloc] init];
    }
    return _weiboLiveSDK;
}

@end
