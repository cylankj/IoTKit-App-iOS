//
//  JFGGrayPolicyManager.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/8/14.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGGrayPolicyManager.h"
#import <AFNetworking.h>
#import "JFGBoundDevicesMsg.h"
#import "LoginManager.h"
#import "OemManager.h"
#import "FTBase64.h"
#import "PropertyManager.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/JFGSDK.h>
#import "OemManager.h"
#define ISOPENGRAY YES   //是否开启灰度测试

NSString *const grayTokenKey = @"grayTokenKey_";
NSString *const grayReqTimeKey = @"grayReqTimeKey_";
NSString *const graySupportKey = @"graySupportKey_";

@implementation JFGGrayPolicyManager


//获取token
+(void)reqGrayToken
{
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@"get_token" forKey:@"act"];
    [dict setObject:account forKey:@"account"];
    [dict setObject:@"" forKey:@"app_id"];
    [self afNetWorkingForGrayWithPatameters:dict sucess:^(id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dict = responseObject;
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
            if (!parseError) {
                NSString *logStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [JFGSDK appendStringToLogFile:logStr];
            }
            int ret = [dict[@"ret"] intValue];
            if (ret == 0) {
                NSString *token = dict[@"token"];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",grayTokenKey,account]];
                [[NSUserDefaults standardUserDefaults] setObject:token forKey:[NSString stringWithFormat:@"%@_%@",grayTokenKey,account]];
                [[self class] reqGrayPolicy];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}


//获取策略表
+(void)reqGrayPolicy
{
    if (![[self class] isAllowableReq]) {
        //return;
    }
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",grayTokenKey,account]];
    if (!token) {
        [self reqGrayToken];
        return;
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@"report_data" forKey:@"act"];
    [dict setObject:token forKey:@"Token"];
    [dict setObject:[OemManager getOemVid] forKey:@"vid"];
    [dict setObject:account forKey:@"account"];
    [dict setObject:app_build forKey:@"version"];
    [dict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"sys_version"];
    [dict setObject:[NSNumber numberWithInt:[JFGSDK getRegionType]] forKey:@"region"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"app_type"];
    
    NSArray *devicesList = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    
    NSMutableArray *devList = [NSMutableArray new];
    
    for (JiafeigouDevStatuModel *model in devicesList) {
        NSMutableDictionary *devDict = [NSMutableDictionary new];
        [devDict setObject:model.uuid forKey:@"cid"];
        [devDict setObject:[OemManager getOemVid] forKey:@"vid"];
        [devDict setObject:[NSNumber numberWithInt:[model.pid intValue]] forKey:@"pid"];
        [devDict setObject:[NSNumber numberWithInt:1] forKey:@"region"];
        [devList addObject:devDict];
    }
    [dict setObject:devList forKey:@"data_list"];
    
    [[self class] afNetWorkingForGrayWithPatameters:dict sucess:^(id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = responseObject;
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
            if (!parseError) {
                NSString *logStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [JFGSDK appendStringToLogFile:logStr];
            }
            int ret = [dict[@"ret"] intValue];
            if (ret == 4) {
                //token失效
                [self reqGrayToken];
            }else if (ret == 0){
                
                NSString *base64String = dict[@"gray"];
                //如果数据被回滚了，gray字段会返回空字符串，这时候要关掉AI
                if (base64String == nil || [base64String isEqualToString:@""]) {
                    if ([[self class] isSupportAIForCurrentAcount]) {
                        [self closeDevsAI];
                    }
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
                    return ;
                }
                
                NSData *jsonData = b64_decode([base64String dataUsingEncoding:NSUTF8StringEncoding]);
                NSError *err = nil;
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                if(err){
                    NSLog(@"json解析失败：%@",err);
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
                }else{
                    NSLog(@"%@",dic);
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",grayReqTimeKey,account]];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] forKey:[NSString stringWithFormat:@"%@_%@",grayReqTimeKey,account]];
                    
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary *subDict = dic[@"enable"];
                        if ([subDict isKindOfClass:[NSDictionary class]]) {
                            
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
                            BOOL isExist = NO;
                            for (NSString *key in subDict) {
                                if ([key isEqualToString:@"ai"]) {
                                    
                                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
                                    isExist= YES;
                                    break;
                                    
                                }
                            }
                            if (!isExist) {
                                
                                //如果上次是支持打开，现在关闭了，则自动关系这个账号下所有设备的AI识别功能
                                if ([[self class] isSupportAIForCurrentAcount]) {
                                    [self closeDevsAI];
                                }
                                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
                            }
                        }
                        
                    }
                }
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
    
}

+(void)closeDevsAI
{
    //如果检测到灰度关闭了该账号下的AI识别功能，所有设备设置关闭
    NSArray *devicesList = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    for (JiafeigouDevStatuModel *model in devicesList) {
        
        if ([PropertyManager showPropertiesRowWithPid:[model.pid intValue] key:pAiRecognition]) {
            
            DataPointSeg * seg = [[DataPointSeg alloc]init];
            NSError * error = nil;
            seg.msgId = 515;
            seg.value = [MPMessagePackWriter writeObject:@[] error:&error];
            [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:model.uuid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
        }
    }
}

+(void)afNetWorkingForGrayWithPatameters:(NSDictionary *)parameters sucess:(void (^)(id responseObject))sucess failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *host = [infoDictionary objectForKey:@"Jfgsdk_host"];
    if (!host || [host isEqualToString:@""]) {
        host = @"yun.jfgou.com";
    }
    
    //如果手动修改了地址
    NSString *jfgServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"_jfg_changedDomain_"];
    
    if (jfgServer && [jfgServer isKindOfClass:[NSString class]] && ![jfgServer isEqualToString:@""]) {
        NSRange range = [jfgServer rangeOfString:@":"];
        if (range.location != NSNotFound) {
            host = [jfgServer substringToIndex:range.location];
        }
    }
    //http   80   https  8081       NSString *url = [NSString stringWithFormat:@"http://yf.jfgou.com:80/gray"];

    NSString *url = [NSString stringWithFormat:@"http://%@:80/gray",host];
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"grayResult:%@",responseObject);
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"grayerror:%@",error);
        if (failure) {
            failure(error);
        }
    }];
}

+(BOOL)isAllowableReq
{
    //灰度接口目前服务端未测试，先屏蔽下面代码，禁止请求接口
    if (ISOPENGRAY) {
        NSString *account = [LoginManager sharedManager].currentLoginedAcount;
        NSTimeInterval lastestTime = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",grayReqTimeKey,account]] longLongValue];
        NSTimeInterval currentTime = [[NSDate date]timeIntervalSince1970];
        if (currentTime - lastestTime > 6*60*60) {
            return YES;
        }
    }
    return NO;
}

//当前账号下面支持AI功能的设备是否开放AI功能入口
+(BOOL)isSupportAIForCurrentAcount
{
    //灰度接口目前服务端未测试，先屏蔽下面代码，允许显示AI功能
    if (ISOPENGRAY) {
        NSString *account = [LoginManager sharedManager].currentLoginedAcount;
        return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_%@",graySupportKey,account]];
    }else{
        return YES;
    }
}

+(void)resetGrayTime
{
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",grayReqTimeKey,account]];
}

@end
