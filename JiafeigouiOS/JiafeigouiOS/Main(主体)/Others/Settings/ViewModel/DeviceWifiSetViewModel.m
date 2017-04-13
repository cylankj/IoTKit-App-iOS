//
//  DeviceWifiSetViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceWifiSetViewModel.h"
#import "JfgGlobal.h"
#import "JfgTableViewCellKey.h"
#import <JFGSDK/JFGSDKBindingDevice.h>
#import <JFGSDK/JFGSDK.h>

@interface DeviceWifiSetViewModel() <JFGSDKBindDeviceDelegate,JFGSDKCallbackDelegate>


@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) JFGSDKBindingDevice *jfgSDKBind;
@property (copy, nonatomic) NSString *connecttedWifi;
@property (copy,nonatomic) NSString *_cid;

@end

@implementation DeviceWifiSetViewModel

- (void)requestDataWithCid:(NSString *)cid connectedWifi:(NSString *)connecttedWifi;
{
    self.connecttedWifi = connecttedWifi;
    
    if ([cid isKindOfClass:[NSString class]] && ![cid isEqualToString:@""]) {
        self._cid = cid;
        [JFGSDK addDelegate:self];
        [JFGSDK fping:@"255.255.255.255"];
    }else{
        self._cid = @"";
        [self.jfgSDKBind scanWifi];
    }
    
   
}

-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([ask.cid isEqualToString:self._cid]) {
        
        [self.jfgSDKBind scanWifiWithCid:ask.cid mac:ask.mac addr:ask.address];
        [JFGSDK removeDelegate:self];
    }
}


#pragma mark JFGSDK Delegate
- (void)jfgScanWifiRespose:(JFGSDKUDPResposeScanWifi *)ask
{
    NSDictionary *wifiDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"",cellIconImageKey,
                              ask.ssid,cellTextKey,
                              @(ask.security),isLocked,
                              @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                              nil];
    if(![ask.ssid isEqualToString:self.connecttedWifi] && ![ask.ssid hasPrefix:@"DOG"]) {//当前的WiFi不要再显示在下面的列表中
        if ([_deviceWifiSetdelegate respondsToSelector:@selector(fetchData:)])
        {
            [_deviceWifiSetdelegate fetchData:wifiDict];
        }
    }
}


#pragma mark getter
- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _groupArray;
}

- (JFGSDKBindingDevice *)jfgSDKBind
{
    if (_jfgSDKBind == nil)
    {
        _jfgSDKBind = [[JFGSDKBindingDevice alloc] init];
        _jfgSDKBind.delegate = self;
    }
    return _jfgSDKBind;
}



@end
