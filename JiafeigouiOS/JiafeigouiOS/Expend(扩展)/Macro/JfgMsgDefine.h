//
//  JfgMsgDefine.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#ifndef JfgMsgDefine_h
#define JfgMsgDefine_h

#define dpGlobalBegin  0   //全局配置消息 开始
#define dpBaseBegin    200
#define dpVideoBegin   300
#define dpBellBegin    400
#define dpCameraBegin  500
#define dpAccountBegin 600
#define efamilyMsgBegin     16900

#pragma mark
#pragma mark DataPoint 全局Key

NSString *const dpTimeKey = @"_dpTime"; //dp对象对应的时间戳
NSString *const dpValueKey = @"_dpValue"; // dp对象 key
NSString *const dpIdKey = @"_dpId"; //dp ID
NSString *const dpTypeflagKey = @"typeFlag";

#pragma mark
#pragma mark DataPoint 全局配置定义
//typedef NS_ENUM(NSInteger, dpMsgGlobal) {
//    
//};

#pragma mark
#pragma mark DataPoint 基础功能定义

NSString *const msgBaseBeginKey = @"_baseBegin"; //200
NSString *const msgBaseNetKey = @"_net";
NSString *const msgBaseMacKey = @"_mac";
NSString *const msgBaseSDCardFormat = @"_sdCardFomat";
NSString *const msgBaseSDStatusKey = @"_sdStatus";
NSString *const msgBasePowerKey = @"_power"; //205
NSString *const msgBaseBatteryKey = @"_battery";
NSString *const msgBaseVersionKey = @"_version";
NSString *const msgBaseSysVersionKey = @"_sysVersion";
NSString *const msgBaseLEDKey = @"_led";
NSString *const msgBaseUptimeKey = @"_uptime";  // 210
NSString *const msgBaseClinetLogKey = @"_clientLog";
NSString *const msgBaseCidLogKey = @"_cidLog";
NSString *const msgBaseP2PVersionKey = @"_p2pVersion";
NSString *const msgBaseTimeZoneKey = @"_timeZone";
NSString *const msgBasePushFlowKey = @"_pushFlow";  //215
NSString *const msgBaseNTSCKey = @"_NTSC";
NSString *const msgBaseMobileKey = @"_mobile";
NSString *const msgBaseFormatSDKey = @"_formatSDCard";
NSString *const msgBaseBindKey = @"_bindInfo";
NSString *const msgBaseSdkVersionKey = @"_sdkVersionKey"; // 220
NSString *const msgBaseCtrlLogKey = @"_ctrlLog";
NSString *const msgBaseSDCardListKey = @"_sdCardInfoList";
NSString *const msgBaseSIMInfoKey = @"_SIMInfo";
NSString *const msgBaseCtrlLogUploadKey = @"_CtrlLogUpload";
NSString *const msgBaseWiredNetAvailableKey = @"_wiredNetAvailable";
NSString *const msgBaseUsingWiredNetKey = @"_usingWiredNet";
NSString *const msgBaseIpAdressKey = @"_ipAdrss";
NSString *const msgBaseUpgradeStatusKey = @"_upgradeStatus";


typedef NS_ENUM(NSInteger, dpMsgBase){
    dpMsgBase_Begin = dpBaseBegin,            //基础功能定义 开始 不使用  200
    dpMsgBase_Net,                            //网络类型
    dpMsgBase_Mac,                            //MAC地址
    dpMsgBase_SDCardFomat,                    // SDCard 格式化 push消息
    dpMsgBase_SDStatus = 204,                       //SD卡容量信息
    dpMsgBase_Power = dpBaseBegin + 5,            //是否连接电源线
    dpMsgBase_Battery,                        //剩余电量
    dpMsgBase_Version,                        //软件版本号
    dpMsgBase_SysVersion,                     //系统版本号
    dpMsgBase_LED,                            //设备指示灯配置
    dpMsgBase_Uptime = dpBaseBegin + 10,           //开机时间
    dpMsgBase_ClientLog,                      //客户端上报日志消息（提交WIFI信息）
    dpMsgBase_CidLog,                         //设备上报日志消息
    dpMsgBase_P2PVersion,                     //设备P2P版本号
    dpMsgBase_Timezone,                       //设备时区配置
    dpMsgBase_PushFlow = dpBaseBegin + 15,      //设备推流配置
    dpMsgBase_NTSC,                             //设备电流频率配置
    dpMsgBase_Mobile,                           //设备优先使用移动网络配置
    dpMsgBase_FormatSD,                         //格式化SD卡
    dpMsgBase_Bind,                             // 绑定，解绑
    dpMsgBase_sdkVersion = dpBaseBegin + 20,                       // SDK version
    dpMsgBase_CtrlLog,                          // 客户端，设备端 日志
    dpMsgBase_SDCardInfoList,                       // SD卡信息 插拔
    dpMsgBase_SIMInfo,                          // SIM 卡信息
    dpMsgBase_CtrlLogUpload,                    // 日志上传
    dpMsgBase_isWiredNetAvailable = dpBaseBegin + 25,              // 有线网 可用？
    dpMsgBase_isUsingWiredNet,                  // 正在用 有线网
    dpMsgBase_ipAdress,                         // 私有 ip
    dpMsgBase_upgradeStatus,                    // 升级 状态
};

#pragma mark
#pragma mark DataPoint 视频功能定义

NSString *const dpMsgVideoBeginKey = @"_videoBegin";
NSString *const dpMsgVideoMicKey = @"_mic";
NSString *const dpMsgVideoSpeakerKey = @"_speaker";
NSString *const dpMsgVideoAutoRecordKey = @"_autoRecord";
NSString *const dpMsgVideoDiretionKey = @"_diretion";
NSString *const dpMsgVideoRecordWhenWatchingKey = @"_recordWhenWatching";

typedef NS_ENUM(NSInteger, dpMsgVideo) {
    dpMsgVideo_mic = dpVideoBegin + 1,          //控制设备麦克风 300
    dpMsgVideo_speaker,                         //控制设备喇叭
    dpMsgVideo_autoRecord,                      //自动录像配置
    dpMsgVideo_diretion,                        //控制设备画面翻转
    dpMsgVideo_recordWhenWatching,              // 查看时 录像
};

#pragma mark
#pragma mark DataPoint 门铃功能定义
NSString *const dpMsgBellBeginKey = @"_bellBegin";
NSString *const dpMsgBellCallMsgKey = @"_bellCallMsg";
NSString *const dpMsgBellLeaveMsgKey = @"_bellLeaveMsg";
NSString *const dpMsgBellCallMsgV3Key = @"_dpMsgBellCallMsgV3Key";
NSString *const dpMsgBellDeepSleepKey = @"_deepsleepStatus";

typedef NS_ENUM(NSInteger, dpMsgBell) {
    dpMsgBell_callMsg = dpBellBegin + 1, // 400
    dpMsgBell_leaveMsg,
    dpMsgBell_callMsgV3,
    dpMsgBell_deepSleep, // 省电模式
};

#pragma mark
#pragma mark DataPoint 摄像头功能定义

NSString *const dpMsgCameraBeginKey = @"_cameraBegin";
NSString *const dpMsgCameraWarnEnableKey = @"_warnEnable";
NSString *const dpMsgCameraWarnTimeKey = @"_warnTime";
NSString *const dpMsgCameraWarnSenKey = @"_warnSenitivity";
NSString *const dpMsgCameraWarnSoundKey = @"_warnSound";
NSString *const dpMsgCameraWarnMsgKey = @"_warnMsg";
NSString *const dpMsgCameraTimeLapseKey = @"_timeLapse";
NSString *const dpMsgCameraWonderKey = @"_wonder";
NSString *const dpMsgCameraisLiveKey = @"_isLive";
NSString *const dpMsgCameraAngleKey = @"_cameraAngle";

NSString *const dpMsgCameraCameraCoord = @"_CameraCoord";
NSString *const dpMsgCameraWarnAndWonder = @"_WarnAndWonder";
NSString *const dpMsgCameraWarnMSGV3 = @"_warnMsg_v3";
NSString *const dpMsgCameraBitRateKey = @"_bitRate";
NSString *const dpMsgCameraWarnDurKey = @"_warnDuration";
NSString *const dpMsgCameraAIRecgnitionKey = @"_aiRecognition";
NSString *const dpMsgCameraInfraredEnhanced = @"_InfraredEnhanced";

typedef NS_ENUM(NSInteger, dpMsgCamera){
    dpMsgCamera_Begin = dpCameraBegin,          //摄像头功能定义 开始 不使用 500
    dpMsgCamera_WarnEnable,                     //报警开关配置
    dpMsgCamera_WarnTime,                       //报警时间段
    dpMsgCamera_WarnSenitivity,                 //报警灵敏度设置
    dpMsgCamera_WarnSound,                      //报警提示音配置
    dpMsgCamera_WarnMsg,                        //报警消息2.0版
    dpMsgCamera_TimeLapse,                      //延迟摄影 设置
    dpMsgCamera_Wonder,                         //前每日精彩 废弃不用了
    dpMsgCamera_isLive = 508,                         //待机
    dpMsgCamera_Angle,                          //全景 平视、俯视
    dpMsgCamera_CameraCoord,
    dpMsgCamera_WarnAndWonder,
    dpMsgCamera_WarnMsgV3 = 512,                //报警消息3.0版
    dpMsgCamera_BitRate,                        //速率.分辨率
    dpMsgCamera_WarnDuration,                   // 报警 时间间隔
    dpMsgCamera_AIRecgnition,                   // AI 识别
    dpMsgCamera_Infraredenhanced = 520,         // 红外增强
    
    
};

#pragma mark
#pragma mark DataPoint 账号功能定义

NSString *const dpMsgAccountBeginKey = @"_accountBegin";
NSString *const dpMsgAccountBindKey = @"_accountBind";
NSString *const dpMsgAccountWonderKey = @"_accountWonder";
typedef NS_ENUM(NSInteger, dpMsgAccount)
{
    dpMsgAccount_Begin = dpAccountBegin,    // 600
    dpMsgAccount_Bind,                      // 强制绑定账号，解绑消息
    dpMsgAccount_Wonder,                    // 每日精彩消息 (3.0 新增)
};


#pragma mark
#pragma mark msgPack 中控 消息 定义
typedef NS_ENUM(NSInteger, EfamilyMsgType){
    
    clientPushOSSConfig = 15000,
    ClientPost  = 15500,
    
    EfamilyMsgType_bindCidReq = 16200,
    EfamilyMsgType_bindCidRsp,
    
    EfamilyMsgType_GetAlarmReq = efamilyMsgBegin,
    EfamilyMsgType_GetAlarmRsp,
    EfamilyMsgType_SetAlarmReq,
    EfamilyMsgType_SetAlarmRsp,
    EfamilyMsgType_EfamlListReq,
    EfamilyMsgType_EfamlListRsp = efamilyMsgBegin + 5,
    EfamilyMsgType_VoiceMsgListReq,
    EfamilyMsgType_VoiceMsgListRsp,
    EfamilyMsgType_ClearVoiceMsgReq,
    EfamilyMsgType_ClearVoiceMsgRsp,
    EfamilyMsgType_MsgSafeListReq = efamilyMsgBegin + 10,
    EfamilyMsgType_MsgSafeListRsp,
    EfamilyMsgType_StatusListReq,
    EfamilyMsgType_StatusListRsp,
    EfamilyMsgType_SetBellReq,
    EfamilyMsgType_SetBellRsp = efamilyMsgBegin + 15,
    EfamilyMsgType_GetBellsReq,
    EfamilyMsgType_GetBellsRsp,
    EfamilyMsgType_MsgListReq,
    EfamilyMsgType_MsgListRsp,
    EfamilyMsgType_MagSetWarnReq = efamilyMsgBegin + 20,
    EfamilyMsgType_MagSetWarnRsp,
    EfamilyMsgType_MagGetWarnReq,
    EfamilyMsgType_MagGetWarnRsp,
    EfamilyMsgType_MagGetInfoReq,
    EfamilyMsgType_MagGetInfoRsp = efamilyMsgBegin + 25,
};

#pragma mark
#pragma mark Pano720 消息定义
typedef NS_ENUM(NSInteger, JfgPanoMsgType) {
    JfgPanoMsgType_DOWNLOAD_REQ = 1,    //	下载请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_DOWNLOAD_RSP = 2,    //	下载响应	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_DELETE_REQ = 3,      //	删除请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_DELETE_RSP = 4,      //	删除响应	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_LIST_REQ = 5,        //	列表请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_LIST_RSP = 6,        //	列表响应	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_PICTURE_REQ = 7,     //	拍照请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_PICTURE_RSP = 8,     //	拍照响应	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_BEGIN_REQ = 9,       //	开始录像请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_BEGIN_RSP = 10,      //	开始录像响应	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_VIDEO_END_REQ = 11,   //	停止录像请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_VIDEO_END_RSP = 12,  //	停止录像响应	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_VIDEO_STATUS_REQ = 13,//	查询录像状态请求	图片和视频文件管理	DOG_5W
    JfgPanoMsgType_VIDEO_STATUS_RSP = 14,//	查询录像状态响应
    
};


#pragma mark
#pragma mark Other 其他杂乱消息
typedef NS_ENUM(NSInteger, JfgMsgType)
{
    JfgMsgType_EfamlActiveCall = 2529, //中控 呼叫 客户端
    JfgMsgType_BellActiveCall = 2516, // 门铃 呼叫 客户端
};


#endif /* JfgMsgDefine_h */
