//
//  CheckVersionHelper.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/25.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CheckVersionHelper.h"
#import "LSAlertView.h"
#import "OemManager.h"
#import "JfgLanguage.h"
#import <JFGSDK/JFGSDK.h>

@implementation CheckVersionHelper

NSString *const cylanBundlID = @"com.jiafeigou.pushnew";
NSString *const zhongxingBundleID = @"com.cylan.jiafeigouapnsnew";
NSString *const cellcBundleID = @"com.cell.push";

//NSString *const checkVersionURL = @"http://itunes.apple.com/lookup?id=922810939";
//NSString *const appInAppStoreURL = @"itms-apps://itunes.apple.com/app/id922810939";

NSString *const cylanAppID = @"1259002501";     // 922810939 原app
NSString *const zhongxingAppID = @"1258090582";     // 990165409 原app
NSString *const cellCAppID = @"1182940293";

- (void)checkVersion
{
    [JFGSDK appendStringToLogFile:@"check Version"];
    if([self isUpgradeInAppStore])
    {
        [self cylanAppStoreUpgradeCheck];
        
    }else{
        [self checkVersionInEight];
    }
}

// 8小时 进行升级
- (void)checkVersionInEight
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"url in EightHour [%@]", self.url]];
    
    if (self.url != nil && ![self.url isEqualToString:@""])
    {
        
        //substringFromIndex：有崩溃风险
        @try {
            
            NSString *idString = nil;
            NSString *domainString = nil;
            
            if ([self.url containsString:@"/"] && self.url.length > 8)
            {
                domainString = [self.url substringToIndex:[self.url rangeOfString:@"/" options:NSLiteralSearch range:NSMakeRange(8, self.url.length-8)].location];
            }
            else
            {
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"url error"]];
                return;
            }
            
            if ([self.url containsString:@"?id="])
            {
                idString = [self.url substringFromIndex:[self.url rangeOfString:@"?id="].location+4];
            }
            else
            {
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"url error: did not find [?id=] "]];
                return;
            }
            
            
            NSString *connectURL = [NSString stringWithFormat:@"%@/app?act=check_version&id=%@&platform=%@&appid=%@",
                                    domainString, idString, ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone?@"iPhone":@"iPad"), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
            
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
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
       
    }
}

// cylan appstore 升级
- (void)cylanAppStoreUpgradeCheck
{
    NSURL *url = [NSURL URLWithString:[self checkVersionURL]];
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
                        NSString  *urlStr = [self appUpgradeURL];
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

// 检测是否需要跳转 AppStore上升级
- (BOOL)isUpgradeInAppStore
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    switch ([OemManager oemType])
    {
        case oemTypeDoby:
        {
            return [bundleID isEqualToString:zhongxingBundleID];
        }
            break;
        case oemTypeCylan:
        {
            return [bundleID isEqualToString:cylanBundlID];
        }
            break;
        case oemTypeCell_C:
        {
            return [bundleID isEqualToString:cellcBundleID];
        }
            break;
        default:
            break;
    }
    
    return NO;
}

//  检测版本 的url
- (NSString *)checkVersionURL
{
    NSString *resultURL = nil;
    NSString *checkVerURL = @"http://itunes.apple.com/lookup?id=%@";
    
    switch ([OemManager oemType])
    {
        case oemTypeCylan:
        {
            resultURL = [NSString stringWithFormat:checkVerURL,cylanAppID];
        }
            break;
        case oemTypeDoby:
        {
            resultURL = [NSString stringWithFormat:checkVerURL,zhongxingAppID];
        }
            break;
        case oemTypeCell_C:
        {
            resultURL = [NSString stringWithFormat:checkVerURL,cellCAppID];
        }
            break;
        default:
            break;
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"checkVersion URL [%@]",resultURL]];
    
    return resultURL;
}

// 升级 跳转 AppStore的url
- (NSString *)appUpgradeURL
{
    NSString *resultURL = nil;
    NSString *appInAppStoreURL = @"itms-apps://itunes.apple.com/app/id%@";
    
    switch ([OemManager oemType])
    {
        case oemTypeCylan:
        {
            resultURL = [NSString stringWithFormat:appInAppStoreURL,cylanAppID];
        }
            break;
        case oemTypeDoby:
        {
            resultURL = [NSString stringWithFormat:appInAppStoreURL,zhongxingAppID];
        }
            break;
        case oemTypeCell_C:
        {
            resultURL = [NSString stringWithFormat:appInAppStoreURL,cellCAppID];
        }
            break;
        default:
            break;
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"appstore's url [%@]", resultURL]];
    
    return resultURL;
}
@end
