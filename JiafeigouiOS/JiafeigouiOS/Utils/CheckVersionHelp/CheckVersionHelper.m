//
//  CheckVersionHelper.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/25.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CheckVersionHelper.h"
#import "LSAlertView.h"
#import "JfgLanguage.h"
#import <JFGSDK/JFGSDK.h>

@implementation CheckVersionHelper

NSString *const cylanBundlID = @"com.jiafeigou.push";

NSString *const checkVersionURL = @"http://itunes.apple.com/lookup?id=922810939";
NSString *const appInAppStoreURL = @"itms-apps://itunes.apple.com/app/id922810939";


- (void)checkVersion
{
    [JFGSDK appendStringToLogFile:@"check Version"];
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:cylanBundlID])
    {
        [self cylanAppStoreUpgradeCheck];
    }
    else
    {
        [self checkVersionInEight];
    }
}

// 8小时 进行升级
- (void)checkVersionInEight
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"url in EightHour [%@]", self.url]];
    
    if (self.url != nil && ![self.url isEqualToString:@""])
    {
        NSString *connectURL = [NSString stringWithFormat:@"%@/app?act=check_version&id=%@&platform=%@&appid=%@", [self.url substringToIndex:[self.url rangeOfString:@"/" options:NSLiteralSearch range:NSMakeRange(8, self.url.length-8)].location],[self.url substringFromIndex:[self.url rangeOfString:@"?id="].location+4], ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone?@"iPhone":@"iPad"), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
        
        NSURL *url = [NSURL URLWithString:connectURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:10];
        [request setHTTPMethod:@"POST"];
        NSOperationQueue *queue = [NSOperationQueue new];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
            if (data != nil)
            {
                NSDictionary *upgradeInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                if ([[upgradeInfoDict objectForKey:@"ret"] intValue] == 0)
                {
                    if (([[upgradeInfoDict objectForKey:@"version"] compare:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] options:NSNumericSearch]==NSOrderedDescending))
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"UPGRADE"] CancelButtonTitle:self.isForeceUpgrade?nil:[JfgLanguage getLanTextStrByKey:@"NEXT_TIME"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"UPGRADE_NOW"] CancelBlock:^{
                                
                            } OKBlock:^{

                                
                                NSString* url = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [upgradeInfoDict objectForKey:@"url"]];
                                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"update jfg app url : %@",url]];
                                NSURL *nsurl=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                if ([[UIApplication sharedApplication] canOpenURL:nsurl]) {
                                    [[UIApplication sharedApplication] openURL:nsurl];
                                }
                            }];
                        });
                    }
                }
                else
                {
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"upgrade error [%d]",[[upgradeInfoDict objectForKey:@"ret"] intValue]]];
                }
            }
            
        }];
    }
}

// cylan appstore 升级
- (void)cylanAppStoreUpgradeCheck
{
    NSURL *url = [NSURL URLWithString:checkVersionURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        
        NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([[receiveDic valueForKey:@"resultCount"] intValue]>0) {
                
                [receiveStatusDic setValue:@"1" forKey:@"status"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"]   forKey:@"version"];
            }else{
                
                [receiveStatusDic setValue:@"-1" forKey:@"status"];
            }
        }else{
            [receiveStatusDic setValue:@"-1" forKey:@"status"];
        }
        
        if ([[receiveStatusDic objectForKey:@"status"] integerValue] == 1) {
            
            NSString *appstoreVer = [receiveStatusDic objectForKey:@"version"];
            //CFBundleShortVersionString
            NSString *appVer = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"appStoreVer:[%@]  localVer[%@]", appstoreVer,appVer]];
            if ([appstoreVer compare:appVer options:NSNumericSearch] == NSOrderedDescending)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"UPGRADE"] CancelButtonTitle:self.isForeceUpgrade?nil:[JfgLanguage getLanTextStrByKey:@"NEXT_TIME"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"UPGRADE_NOW"] CancelBlock:^{
                        
                    } OKBlock:^{
                        NSString  *urlStr = appInAppStoreURL;
                        NSURL *url = [NSURL URLWithString:urlStr];
                        [[UIApplication sharedApplication] openURL:url];
                    }];
                });
            }
        }
    }];
}

// 版本匹配
- (BOOL)compareVersion:(NSString *)appStoreVer with:(NSString *)localVer
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"appStoreVer:[%@]  localVer[%@]", appStoreVer,localVer]];
    NSArray *appStoreVers = [appStoreVer componentsSeparatedByString:@"."];
    NSArray *localVers = [localVer componentsSeparatedByString:@"."];
    NSInteger countNum = appStoreVers.count<localVers.count?appStoreVers.count:localVers.count; // 防止遍历越界
    
    for (NSInteger i = 0; i < countNum; i ++)
    {
        if ([[appStoreVers objectAtIndex:i] intValue] > [[localVers objectAtIndex:i] intValue])
        {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"appStoreValue:[%d]  localValue[%d]", [[appStoreVers objectAtIndex:i] intValue],[[localVers objectAtIndex:i] intValue]]];
            return YES;
        }
    }
    
    return NO;
}
@end
