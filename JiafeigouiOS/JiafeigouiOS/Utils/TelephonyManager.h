//
//  TelephonyManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/21.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const TelephonyManagerNotificationKey = @"TelephonyManagerNotificationKey";

typedef NS_ENUM(NSInteger,TelephonyCallState){
    TelephonyCallStateDisconnect,//挂了电话
    TelephonyCallStateConnected,//接通了电话
    TelephonyCallStateIncoming,//来电话了
    TelephonyCallStateDialing,//正在播出电话
    TelephonyCallstateNoDone,//啥事都没有
};

@protocol TelephonyManagerDelegate <NSObject>

-(void)callState:(TelephonyCallState)state;

@end

@interface TelephonyManager : NSObject

@property (nonatomic,weak)id <TelephonyManagerDelegate> delegate;

-(void)startMonitor;


@end
