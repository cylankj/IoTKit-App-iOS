//
//  JFGError.h
//  JFGSDK
//
//  Created by 杨利 on 2017/12/20.
//  Copyright © 2017年 yangli. All rights reserved.
//


/*!
 *  错误码
 */
typedef NS_ENUM (NSUInteger, JFGErrorType){
    // EOK 成功 success
    JFGErrorTypeNone = 0,
    
    // P2P 错误
    JFGErrorTypeP2PDns,
    JFGErrorTypeP2PSocket,
    JFGErrorTypeP2PCallerRelay,
    JFGErrorTypeP2PCallerStun,
    JFGErrorTypeP2PCalleeStun = 5,
    JFGErrorTypeP2PCalleeWaitCallerCheckNetTimeOut,
    JFGErrorTypeP2PPeerTimeOut,
    JFGErrorTypeP2PUserCancel,
    JFGErrorTypeP2PConnectionCheck,
    JFGErrorTypeP2PChannel = 10,
    JFGErrorTypeP2PDisconetByUser,
    JFGErrorTypeP2PUnKnown12,
    // 对端超时断开
    JFGErrorTypeP2PRTCPTimeout = 13,
    
    // 直播类
    // 对端不在线
    JFGErrorTypeVideoPeerNotExist = 100,
    // 对端断开
    JFGErrorTypeVideoPeerDisconnect,
    // 正在查看中
    JFGErrorTypeVideoPeerInConnect,
    // 本端未登陆
    JFGErrorTypeVideoPeerNotLogin = 103,
    
    // 未知错误
    JFGErrorTypeUnknown = 120,
    // 数据库错误
    JFGErrorTypeDataBase,
    // 会话无效
    JFGErrorTypeInvalidSession,
    // 消息格式错误
    JFGErrorTypeInvalidMsg = 123,
    // 消息速率超过限制，请控制合理流速（100个每秒）
    JFGErrorTypeMsgRateExceedLimit = 124,
    
    // 设备端鉴权。
    // 厂家CID达到配额。关联消息：注册。
    JFGErrorTypeCIDExceedQuota = 140,
    // SN签名验证失败。关联消息：登陆。
    JFGErrorTypeCIDSNVerifyFailed,
    // 公钥不存在, 请到萝卜头平台上传您的公钥（注意，请保管好您的私钥，不要泄漏）。关联消息：登陆。
    JFGErrorTypePublicKeyNotExist = 142,
    
    // CID重复。关联消息：登陆。
    JFGErrorTypeCIDIsDuplicate = 143,
    
    // ErrorCIDNotRegistered CID未注册
    JFGErrorTypeCIDNotRegistered = 144,
    
    
    // 双鱼眼摄像头电量低于5%
    JFGErrorTypeCIDLowBattery = 150,
    // timezone时区为空，关联消息：设备端获取夏令时接口。
    JFGErrorTypeCIDTimezoneEmpty = 151,
    
    // 客户端登陆类.
    // vid, bundleID, vkey校验失败。
    JFGErrorTypeLoginInvalidVKey = 160,
    // 帐号或密码错误。
    JFGErrorTypeLoginInvalidPass = 161,
    // 第三方帐号登陆： 鉴权URL无效，或 open_id access_token 验证失败。
    JFGErrorTypeOpenLoginInvalidToken = 162,
    
    // SDK正在初始化，请等待
    JFGErrorTypeIniting = 163,
    
    // 客户端帐号类.
    // 短信验证码错误。
    JFGErrorTypeSMSCodeNotMatch = 180,
    // 短信验证码超时。
    JFGErrorTypeSMSCodeTimeout,
    // 帐号不存在。
    JFGErrorTypeAccountNotExist,
    // 帐号已存在。
    JFGErrorTypeAccountAlreadyExist,
    // 原始密码与新密码相同。关联消息：修改密码。
    JFGErrorTypeSamePass,
    // 原密码错误。关联消息：修改密码。
    JFGErrorTypeInvalidPass = 185,
    // 此手机号码已被绑定。关联消息：帐号、手机号、邮箱绑定。
    JFGErrorTypePhoneExist,
    // 此邮箱已被绑定。关联消息：帐号、手机号、邮箱绑定。
    JFGErrorTypeEmailExist,
    // 手机号码不合规
    JFGErrorTypeIsNotPhone,
    // 邮箱账号不合规
    JFGErrorTypeIsNotEmail,
    // 忘记密码时，邮箱或手机号不存在时报错
    JFGErrorTypeInvalidPhoneNumber = 190,
    // 第三方账号设置密码超时
    JFGErrorTypeSetPassTimeout = 191,
    // 十分钟内获取验证码超过3次
    JFGErrorTypeGetCodeTooFrequent = 192,
    
    // 客户端绑定设备类.
    // CID不存在。关联消息：客户端绑定。
    JFGErrorTypeCIDNotExist = 200,
    // 绑定中，正在等待摄像头上传随机数与CID关联关系，随后推送绑定通知
    JFGErrorTypeCIDBinding,
    // 设备别名已存在。
    JFGErrorTypeCIDAliasExist,
    // 设备未绑定，不可操作未绑定设备。
    JFGErrorTypeCIDNotBind = 203,
    // 设备已经被其他账号绑定。
    JFGErrorTypeCIDBinded = 204,
    
    // 客户端分享设备类.
    // 此帐号还没有注册。
    JFGErrorTypeShareInvalidAccount = 220,
    // 此帐号已经分享。
    JFGErrorTypeShareAlready,
    // 您不能分享给自己。
    JFGErrorTypeShareToSelf,
    // 设备分享，被分享账号不能超过5个。
    JFGErrorTypeShareExceedsLimit,
    
    // 客户端亲友关系类.
    //添加好友失败 对方账户未注册
    JFGErrorTypeFriendInvalidAccount = 240,
    // 已经是好友关系
    JFGErrorTypeFriendAlready,
    // 不能添加自己为好友
    JFGErrorTypeFriendToSelf,
    // 好友请求消息过期
    JFGErrorTypeFriendInvalidRequest,
    
    // APP测错误号
    // 非法的调用，ex: 摄像头/APP 调用对方才有的功能
    JFGErrorTypeInvalidMethod = 1000,
    // 非法的调用参数，ex: 登陆不带用户名
    JFGErrorTypeInvalidParameter,
    // 非法的状态， ex: 和摄像头在连接状态再次调用连接
    JFGErrorTypeInvalidState,
    // 解析域名失败
    JFGErrorTypeResolve,
    // 连接服务器失败
    JFGErrorTypeConnect,
    
    // 每日精彩收藏夹达到上线（50条）
    JFGErrorWonderFavoriteExceedLimit = 1050,
    
    //云存储相关
    // 设备未开启云存储服务
    JFGErrorOSSAPIDeviceNotOpen = 1100,
    // 设备云存储服务过期
    JFGErrorOSSAPIDeviceExpired = 1101,
    // 用户关闭云存储服务
    JFGErrorOSSAPIUserOFFUploading = 1102,
    // 用户首次开启云存储服务
    JFGErrorOSSAPIUserOnUploading = 1103,
    // 未知错误
    JFGErrorSDUnknown = 2001,
    // 输入参数有误
    JFGErrorSDInvParam = 2002,
    // 没有空闲空间
    JFGErrorSDNoSpace = 2003,
    // 没有可用的存储设备
    JFGErrorSDNoDevice = 2004,
    // 要写入的帧数据长度过长，簇中放不下
    JFGErrorSDTooLarge = 2005,
    // 没有记录
    JFGErrorSDNoRecords = 2006,
    // 录像中不能进行一些操作
    JFGErrorSDRecording = 2007,
    // 格式化过程中
    JFGErrorSDFormating =  2008,
    // 写失败
    JFGErrorSDWrite = 2009,
    // 内存申请失败
    JFGErrorSDNoMemory = 2010,
    
    // 读失败
    JFGErrorSDRead = 2011,
    // 检索/读取过程中不能进行一些操作
    JFGErrorSDOperating = 2012,
    // 列表检索过程中不能进行一些操作
    JFGErrorSDListSearching = 2013,
    // 已存在句柄
    JFGErrorSDExistHandle = 2014,
    // 要写入的帧pts异常
    JFGErrorSDInvPTS = 2015,
    // 存储设备上的文件系统过旧
    JFGErrorSDFSVersionOld = 2020,
    // 存储设备上的文件系统较新
    JFGErrorSDFSVersionNew = 2021,
    // 文件系统无法识别
    JFGErrorSDFSDamaged = 2022,
    // 存储设备读写出错
    JFGErrorSDFSReadWrite = 2023,
    // 未正常关闭存储设备(需要进行断电恢复)
    JFGErrorSDFSDirty = 2024,
    // 文件系统未初始化或已关闭
    JFGErrorSDFSInitialized = 2025,
    // 文件系统索引块异常(需要进行数据恢复)
    JFGErrorSDFIDXAbnormal = 2026,
    // 历史录像已读完
    JFGErrorSDHistoryAll = 2030,
    // 历史录像读取失败
    JFGErrorSDFileIO = 2031,
    // 历史录像卡读取失败,同 ErrorSDRead
    JFGErrorSDIO = 2032,

};



