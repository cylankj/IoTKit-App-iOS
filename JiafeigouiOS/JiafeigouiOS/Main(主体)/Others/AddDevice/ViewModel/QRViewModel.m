//
//  QRViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "QRViewModel.h"
#import "ProgressHUD.h"
#import "JfgTypeDefine.h"
#import "JfgGlobal.h"
#import "JfgMsgDefine.h"
#import "EfamilyRequest.h"
#import <JFGSDK/JFGSDK.h>
#import "JFGBoundDevicesMsg.h"
#import "JFGPidMap.h"

@interface QRViewModel()

@property (nonatomic, assign) BOOL isOldVersion; // 是否是老版本

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *mac;

@property (nonatomic, strong) EfamilyRequest *efamRequest;
@property (nonatomic,strong)JFGPidMap *pidMap;
@end

NSString *const snKey = @"_snKey"; // cid 串号

#pragma mark --- new versoin key ----
NSString *const vidKey = @"_vidKey";
NSString *const pidKey = @"_pidKey";

#pragma mark --- old versoin key ----

NSString *const macKey = @"_macKey";

@implementation QRViewModel

- (BOOL)requestWithString:(NSString *)qrResult
{
//    http://www.jfgou.com/app/download.html?vid=001&pid=0012&sn=200000041777
    [JFGSDK appendStringToLogFile:qrResult];
    
    
    if ([qrResult rangeOfString:@"www.jfgou.com"].location == NSNotFound) {
        
        [self resultCallBack:QRReustTypeInvalidQRCode forPid:@"0"];
        return YES;
    }
    
    NSMutableDictionary *dataInfo = [self QRResultStringParse:qrResult];
    self.vid = [dataInfo objectForKey:vidKey];
    self.pid = [dataInfo objectForKey:pidKey];
    self.sn = [dataInfo objectForKey:snKey];
    self.mac = [dataInfo objectForKey:macKey];

    NSMutableArray <JiafeigouDevStatuModel *>* devList =[[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    
    for (JiafeigouDevStatuModel *model in devList) {
        
        if ([model.uuid isEqualToString:self.sn]) {
            
            [self resultCallBack:QRReustTypeBinded forPid:@"0"];
            return YES;
        }
        
    }
    //先判断sn 是否存在
    if ([self.sn isEqualToString:@""] || self.sn == nil)
    {
        [self resultCallBack:QRReustTypeError forPid:@"0"];
        return YES;
    }
    
    // 判断pid 和vid 是否 存在
    if (self.pid == nil || [self.pid isEqualToString:@""] || self.vid == nil || [self.vid isEqualToString:@""])
    {
        [self resultCallBack:QRReustTypeError forPid:@"0"];
        return YES;
    }
    
    //pid 转成os
    NSInteger os = [self.pidMap osFromPid:[self.pid intValue]];
    [self resultCallBack:QRReustTypePUshGuideCamera forPid:[NSString stringWithFormat:@"%d",os]];

    return YES;
}

- (void)sendBindMsg
{
    [self.efamRequest bindDeviceZKWithMac:self.mac cid:self.sn alias:[JfgLanguage getLanTextStrByKey:@"DOOR_MAGNET_NAME"]];
}

/**
 *  二维码 结果 URL 解析
 */
// http://www.jfgou.com/app/download.html?cid=700...01&mac=AA:BB:CC:DD:EE:FF

- (NSMutableDictionary *)QRResultStringParse:(NSString *)parseString
{
    // 结果 返回字典
    NSMutableDictionary *parseResultDict = [[NSMutableDictionary alloc] init];
    
    if ([parseString isKindOfClass:[NSString class]] && [parseString containsString:@"?cid"] && [parseString containsString:@"&mac"])  //老版本
    {
        self.isOldVersion = YES;
        NSArray *keys= @[snKey,macKey];
        
        NSArray *subStrArray = [parseString componentsSeparatedByString:@"&"];
        
        for (NSInteger i = 0; i < subStrArray.count; i ++)
        {
            // 再用 “=” 切割 取后面那个就是 我们需要的
            NSArray *valueArray = [[subStrArray objectAtIndex:i] componentsSeparatedByString:@"="];
            
            [parseResultDict setObject:[valueArray lastObject] forKey:[keys objectAtIndex:i]];
        }
        
        [parseResultDict setObject:[NSString stringWithFormat:@"%d",8] forKey:pidKey];
        [parseResultDict setObject:@"随便" forKey:vidKey];
    }
    else // 新版本
    {
        self.isOldVersion = NO;
        // 字典的 Key
        NSArray *keys= @[vidKey,pidKey,snKey];
        // 以 & 切割出来的 数组
        NSArray *subStrArray = [parseString componentsSeparatedByString:@"&"];
        
        for (NSInteger i = 0; i < subStrArray.count; i ++)
        {
            // 再用 “=” 切割 取后面那个就是 我们需要的
            NSArray *valueArray = [[subStrArray objectAtIndex:i] componentsSeparatedByString:@"="];
            
            [parseResultDict setObject:[valueArray lastObject] forKey:[keys objectAtIndex:i]];
        }
    }
    
    return parseResultDict;
}



- (void)resultCallBack:(QRReustType)resultType forPid:(NSString *)pid
{
    if ([_vmDelegate respondsToSelector:@selector(QRScanDidFinished:forPid:)])
    {
        [_vmDelegate QRScanDidFinished:resultType forPid:pid];
    }
}

#pragma  mark bindDelegate


#pragma  mark Property
- (EfamilyRequest *)efamRequest
{
    if (_efamRequest == nil)
    {
        _efamRequest = [[EfamilyRequest alloc] init];
        //_efamRequest.delegate = self;
    }
    return _efamRequest;
}

-(JFGPidMap *)pidMap
{
    if (!_pidMap) {
        _pidMap = [[JFGPidMap alloc]init];
    }
    return _pidMap;
}

@end
