//
//  JFGTypeDefine.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/3/25.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "JFGErrorType.h"



//好友相关操作结果
typedef NS_ENUM (NSUInteger,JFGFriendResultType)
{
    /// 添加好友请求的发送结果
    JFGFriendResultTypeAddFriend = 8,
    /// 删除好友请求的发送结果
    JFGFriendResultTypeDelFriend,
    /// 同意添加好友请求的发送结果
    JFGFriendResultTypeAgreeAddFriend,
    /// 设置好友备注名
    JFGFriendResultTypeSetRemarkName,
    /// 删除好友请求
    JFGFriendResultTypeDelAddFriendRequest = 19,
};

//账号相关操作结果
typedef NS_ENUM (NSInteger,JFGAccountResultType)
{
    //更新账号操作结果
    JFGAccountResultTypeUpdataAccount,
    //忘记密码
    JFGAccountResultTypeForgetPassworld,
    //修改密码
    JFGAccountResultTypeChangedPassworld,
    //账号是否注册
    JFGAccountResultTypeIsRegistered,
};

/*!
 *  网络类型定义
 */
typedef NS_ENUM(NSInteger,JFGNetType) {
    /*!
     *  无网络,不在线
     */
    JFGNetTypeOffline = 0,
    
    /*!
     *  WIFI
     */
    JFGNetTypeWifi,
    
    /*!
     *  3G
     */
    JFGNetType3G,
    
    /*!
     *  绑定后的连接中
     */
    JFGNetTypeConnect,
    
    /*!
     *  4G
     */
    JFGNetType4G,
    
    /*!
     *  5G
     */
    JFGNetType5G,
    
    /*!
     *  2G
     */
    JFGNetType2G,
    
    /*!
     *  有线模式
     */
    JFGNetTypeWired = 10,
};


/*!
 *  语言
 */
typedef NS_ENUM(NSInteger,JFGLanguageType) {
    /*!
     *  中文
     */
    JFGLanguageTypeChinese = 0,
    /*!
     *  英文
     */
    JFGLanguageTypeEnglish,
    /*!
     *  俄语
     */
    JFGLanguageTypeRussian,
    /*!
     *  葡萄牙
     */
    JFGLanguageTypePortuguese,
    /*!
     *  西班牙语
     */
    JFGLanguageTypeSpanish,
    /*!
     *  日语
     */
    JFGLanguageTypeJapanese,
    /*!
     *  法语
     */
    JFGLanguageTypeFrench,
    /*!
     *  德语
     */
    JFGLanguageTypeGerman,
};


/*!
 *  加菲狗设备类型
 */
typedef NS_ENUM(NSInteger,JFGDeviceType) {
    /*!
     *  未知设备类型
     */
    JFGDeviceTypeUnknown,
    /*!
     *  加菲狗WIFI版摄像头
     */
    JFGDeviceTypeCameraWifi,
    /*!
     *  加菲狗摄像头3G版本
     */
    JFGDeviceTypeCamera3G,
    /*!
     *  加菲狗摄像头4G版本
     */
    JFGDeviceTypeCamera4G,
    /*!
     *  加菲狗门铃
     */
    JFGDeviceTypeDoorBell,
    /*!
     *  加菲狗E家人
     */
    JFGDeviceTypeEfamily,
    /*!
     *  加菲狗门窗磁感应器
     */
    JFGDeviceTypeDoorSensor,
    /*!
     *  全景摄像头
     */
    JFGDeviceTypePanoramicCamera,
};




/*!
 *  绑定设备错误类型
 */
typedef NS_ENUM(NSInteger,JFGBindDeviceErrorType)
{
    /*!
     *  未知错误
     */
    JFGBindDeviceErrorTypeUnknow = 0,
    /*!
     *  操作超时
     */
    JFGBindDeviceErrorTypeTimeOut,
    /*!
     *  设置设备wifi失败
     */
    JFGBindDeviceErrorTypeSetWifi,
    /*!
     *  重新连接服务器失败
     */
    JFGBindDeviceErrorTypeReConnectServerFail,
    /*!
     *  重新用户登录失败
     */
    JFGBindDeviceErrorTypeReLoginFail,
    /*!
     *  未连接设备wifi
     */
    JFGBindDeviceErrorTypeNotConnectDeviceWifi,
};

//历史录像查询方式
typedef NS_ENUM (NSUInteger,JFGHistorySearchWayType){
    
    JFGHistorySearchWayTypeByMin,//按分钟查询
    JFGHistorySearchWayTypeByDay,//按天查询
    
};

/*!
 *  \~chinese
 *  第三方登录类型
 *
 *  \~english
 *  Open login type
 */
typedef NS_ENUM (NSUInteger,JFGOpenLoginType){
    
    JFGOpenLoginTypeForQQ = 3,//QQ
    JFGOpenLoginTypeForSinaWeibo,//新浪微博
    JFGOpenLoginTypeForCustomLogin,//自定义登录
    JFGOpenLoginTypeForTwitter,
    JFGOpenLoginTypeForFacebook,
    
};

/*!
 *  \~chinese
 *  短信验证码类型
 *
 *  \~english
 *  SMS verification code type
 */
typedef NS_ENUM(NSUInteger,JFGSMSCodeType){
    
    JFGSMSCodeTypeRegisterOrBind,//注册或者绑定手机号
    JFGSMSCodeTypeForgetPassword,//忘记密码
    JFGSMSCodeTypeChangePassword,//修改密码
    
};

/*!
 *  \~chinese
 *  接入APNS推送类型
 *
 *  \~english
 *  Access APNS push type
 */
typedef NS_ENUM(NSUInteger,JFGAPNSType){
    JFGAPNSTypeApple = 1,//苹果原生
    JFGAPNSTypeGetui = 2,//个推
};

typedef NS_ENUM(NSUInteger,JFGBitRateType){
    JFGBitRateTypeAuto,//自动
    JFGBitRateTypeSD,//标清
    JFGBitRateTypeHD,//高清
};



