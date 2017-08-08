//
//  JfgTypeDefine.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#ifndef JfgTypeDefine_h
#define JfgTypeDefine_h


/**
 *  产品 ID 类型，用来区分什么硬件 对应服务器的 pid
 */
typedef NS_ENUM(NSInteger, productType) {
    
#pragma mark os
    productType_3G_2X = 4,      // 2.0 版本 3G狗 type
    productType_WIFI = 5,
    productType_DoorBell = 6,   // 6
    productType_WIFI_V2,        // 不同硬件的wifi狗
    productType_Efamily,        // 中控
    productType_Air,            // eHome 温湿度计 废弃
    productType_Human = 10,     // eHome 红外    废弃
    productType_Mag,                // 门磁
    productType_Detector,           // 空气 质量检测仪  废弃
    productType_WIFI_V3,            // 不同硬件的wifi狗
    productType_DoorBell_V2 = 15,    // 不同硬件的门铃
    productType_4G,             // 4G 狗
    productType_FreeCam,         // 门铃硬件 的狗 乐视
    productType_Camera_HS = 18,      // 海思
    productType_Camera_ZY,      // 乔安
    productType_Camera_GK,      // 国科
    productType_720p,           // 720
    productType_DoorBell2 = 25,      // 门铃 二代
    productType_ColudCameraOs = 26,  // 看家王 云相机
    productType_CatEye = 27,        // 猫眼
    productType_RS_180 = 36,    // RS camera
    productType_RS_120 = 37,
    productType_IPCam = 38, // 睿视方案（doby）120°
    productType_IPCam_V2,       // 睿视方案   39
    
    productType_KKS_DoorBell = 42,  // 康凯斯 门铃
    productType_CesBell = 44,        // ces 门铃
    productType_CesBell_V2 = 46,       // ces 门铃
    
    productType_CesCamera = 47,         // ces 鱼眼 摄像头
    productType_CesCamera_V2,           // ces 摄像头
    
    productType_RSDoorBell = 50,        // RS 门铃
    productType_RS_180_Panorama,        // RS 180 全景
    productType_DoorBell3 = 52,  //门铃三代
    
    productType_RS_360_pano = 81,   // 全景？然而 又不是
    
#pragma mark pid
    productType_3G = 1071,
    productType_ColudCamera = 1088, // 看家王 云相机
    productType_720,            // 720 VR 全景相机
    productType_Wifi8330,       // wifi版 8330主板
    productType_HS_960,         // 海思 960
    productType_HS_1080,        // 海思 1080
    productType_newDoorBell,      // 门铃
    productType_newDoorBell_V2p,      // 门铃
    
    productType_CatEye_V2 = 1160, //猫眼
    productType_ColudCameraOs_V2 = 1188, //云相机
    productType_DoorBell3_V2 = 1379,  //门铃三代
};


//   文件 所在位置 类型
typedef NS_ENUM(NSInteger, FileExistType) {
    FileExistTypeLocal,                 //本地 有
    FileExistTypeRemote,                //远程 有
    FileExistTypeBoth     //本地，远程 都有
};

// 设备 网络类型
typedef NS_ENUM(NSInteger, DeviceNetType) {
    DeviceNetType_Connetct = -1,
    DeviceNetType_Offline,
    DeviceNetType_Wifi,
    DeviceNetType_2G,
    DeviceNetType_3G,
    DeviceNetType_4G,
    DeviceNetType_5G,
    DeviceNetType_Wired = 10,   // 有线 模式
};

// 自动录像
typedef NS_ENUM(NSInteger, MotionDetect)
{
    MotionDetectNone = -1, // 无
    MotionDetectAbnormal, // 检测到 异常时 录像
    MotionDetectAllDay, //24 小时 录像
    MotionDetectNever, // 不录像
    
};

// 灵敏度
typedef NS_ENUM(NSInteger, sensitiveType) {
    sensitiveTypeLow,       //低灵敏度
    sensitiveTypeNormal,    //中灵敏度
    sensitiveTypeHigh,      //高灵敏度
};

// AI 识别
typedef NS_ENUM(NSInteger, AIRecType) {
    AIRecType_Person = 1,
    AIRecType_Cat,
    AIRecType_Dog,
    AIRecType_Car
};

// 设备提示音
typedef NS_ENUM(NSInteger, soundType) {
    soundTypeMute,      //静音
    soundTypeBark,      //汪汪声
    soundTypeWarning,   //警告声
};

typedef NS_ENUM(NSInteger, SIMType) {
    SIMType_UnKnown = 0,    // 未知
    SIMType_None,       //无 SD卡
    SIMType_PinLock,        // PIN 锁住
    SIMType_PukLock,        // PUK 锁住
    SIMType_NetPinLock,     // PIN 网络被锁
    SIMType_Using,     // 正常 使用
};

typedef NS_ENUM(NSInteger, SDCardType) {
    SDCardType_None,            // 无SDcard
    SDCardType_Using,           // 正常使用
    SDCardType_Error,           // SDcard 错误
};

typedef NS_ENUM(NSInteger, DeviceDirectionType) {
    DeviceDirectionTypePortrait,        // 竖屏
    DeviceDirectionTypeLandScape,       // 支持横屏
    DeviceDirectionTypeALL,             // 所有 方向
};


#pragma mark
#pragma mark  === 设置wifi 跳转 添加页面
typedef NS_ENUM(NSInteger, configWifiType)
{
    configWifiType_default, // 配置 并且跳转
    configWifiType_configWifi, // 仅仅 配置wifi
    configWifiType_resetWifi, 
};

typedef NS_ENUM(NSInteger, angleType) {
    angleType_Over,     // 俯视
    angleType_Front,    //平视
};

#pragma mark
#pragma mark == 登录注册 枚举 ==
 //注册类型
typedef NS_ENUM(NSInteger, registerType)
{
    registerTypePhone = 0,//手机 注册
    registerTypeEmail //邮箱 注册
};

// 验证码类型
typedef NS_ENUM(NSInteger, smsCodeType) {
    smsCodeTypeRegister = 0, // 注册  发送 验证码
    smsCodeTypeForgetPass, // 忘记密码 发送 验证码
    smsCodeTypeModifyPass, // 修改密码 发送 验证码
};


#pragma mark
#pragma mark == 视频播放 枚举 ==
typedef NS_ENUM(NSInteger, DisconnectReason) {
    DisconnectReasonEfamilyAciton = 11,      // 中控主动断开
    DisconnectReasonSDCardClear = 14,        // SDCard 被清空
    DisconnectReasonPeerNotExist = 100,       //
    DisconnectReasonPeerDisconnect,
    DisconnectReasonPeerConnectted,
    DisconnectReasonCallerNotLogin,
};



#endif /* JfgTypeDefine_h */
