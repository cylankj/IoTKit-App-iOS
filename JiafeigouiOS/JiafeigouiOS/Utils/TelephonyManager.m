//
//  TelephonyManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/21.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "TelephonyManager.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>

@interface TelephonyManager()
{
    CTCallCenter *center_;
    
}

@property (nonatomic,strong)CTCallCenter *callCenter;
@end

@implementation TelephonyManager

-(void)startMonitor
{
    //获取电话接入信息
    __weak typeof(self) weakSelf = self;
    self.callCenter.callEventHandler = ^(CTCall *call){
        
        TelephonyCallState state;
        
        if ([call.callState isEqualToString:CTCallStateDisconnected]){
            NSLog(@"挂断了电话咯Call has been disconnected");
            state = TelephonyCallStateDisconnect;
        }else if ([call.callState isEqualToString:CTCallStateConnected]){
            NSLog(@"电话通了Call has just been connected");
            state = TelephonyCallStateConnected;
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            NSLog(@"来电话了Call is incoming");
            state = TelephonyCallStateIncoming;
        }else if ([call.callState isEqualToString:CTCallStateDialing]){
            NSLog(@"正在播出电话call is dialing");
            state = TelephonyCallStateDialing;
        }else{
            NSLog(@"嘛都没做Nothing is done");
            state = TelephonyCallstateNoDone;
        }
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(callState:)]) {
            [weakSelf.delegate callState:state];
        }
    };
}

-(CTCallCenter *)callCenter
{
    if (!_callCenter) {
        _callCenter = [[CTCallCenter alloc]init];
    }
    return _callCenter;
}

@end
