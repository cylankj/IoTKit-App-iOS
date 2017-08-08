//
//  JiafeigouDevStatuModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFGSDK/JFGSDK.h>
#import <MJExtension/MJExtension.h>
#import "JfgTypeDefine.h"

typedef enum{
    DevShareStatuNot,//无分享
    DevShareStatuAlready,//分享给别人了
    DevShareStatuOther,//别人分享给我的(来自于分享)
}DevShareStatu;

@interface JiafeigouDevStatuModel : NSObject

//设备网络状态
@property (nonatomic,assign)JFGNetType netType;

//设备类型
@property (nonatomic,assign)JFGDeviceType deviceType;

//设备cid
@property (nonatomic,copy) NSString *uuid;


@property (nonatomic,copy) NSString *sn;

//设备别名
@property (nonatomic,copy)NSString *alias;

//未读消息数
@property (nonatomic,assign)NSInteger unReadMsgCount;

//720设备拍摄照片未读数
@property (nonatomic,assign)NSUInteger unReadPhotoCount;

//最新一条消息内容
@property (nonatomic,copy)NSString *lastMsg;

//最新一条消息时间
@property (nonatomic,copy)NSString *lastMsgTime;

//分享模式
@property (nonatomic,assign)DevShareStatu shareState;

//延时摄影
@property (nonatomic,assign)BOOL delayCamera;

//安全待机
@property (nonatomic,assign)BOOL safeIdle;

//安全防护
@property (nonatomic,assign)BOOL safeFence;

//电量
@property (nonatomic,assign)int Battery;

//是否充电中
@property (nonatomic,assign)BOOL isPower;

//门磁是否打开
@property (nonatomic,assign)BOOL doorcOpen;

//被分享给了多少人
@property (nonatomic,assign)int shareCount;

@property (nonatomic,copy)NSString *pid;

@end
