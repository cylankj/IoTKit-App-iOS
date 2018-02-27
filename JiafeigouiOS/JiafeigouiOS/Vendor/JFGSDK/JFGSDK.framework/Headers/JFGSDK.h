//
//  JFGSDK.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/3/25.
//  Copyright © 2016年 yangli. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JFGTypeDefine.h"
#import "JFGSDKCallbackDelegate.h"
#import "JFGSDKPlayVideoDelegate.h"
#import "JFGSDKRenderView.h"

@interface JFGSDK : NSObject


#pragma mark - 基础操作  Base action
/*!
 *  JFGSDK初始化
 *  @param dir    日志存储目录
 
 ~English
 *  JFGSDK initialize
 *  @param dir  sdk work directory
 
 */
+(void)connectWithVid:(NSString *)vid vKey:(NSString *)vkey ForWorkDir:(NSString *)path;

//清空日志文件
+(void)resetLog;

/*!
 *  添加JFGSDK回调代理
 *  @param delegate 代理
 
 ~English
 *  add JFGSDK delegate
 *  @param delegate
 */
+(void)addDelegate:(id<JFGSDKCallbackDelegate>)delegate;


/*!
 *  移除代理
 *  @param delegate 代理
 
 ~English
 *  remove delegate
 */
+(void)removeDelegate:(id<JFGSDKCallbackDelegate>)delegate;

/**
 *  Current network status
 *
 *  @return network status
 */
+(JFGNetType)currentNetworkStatus;

/*!
 *  日志开关操作
 *  @param enabel YES: 记录SDK日志 NO: 关闭日志
 
 ~English
 *  Log switch
 *  @param enabel
 */
+(void)logEnable:(BOOL)enabel;


/**
 *  Write log file
 *
 *  @param str  Write content
 */
+(void)appendStringToLogFile:(NSString *)str;


/**
 *  upload devicee Token
 *
 *  @param deviceToken deviceToken
 *  @param tokenType  1:servciceTypeIosApns  2:servciceTypeIosGetui
 */
+(void)deviceTokenUpload:(NSData *)deviceToken tokenType:(int)tokenType;

+(void)deviceTokenUploadForString:(NSString *)deviceToken tokenType:(int)tokenType;

#pragma mark - 登录与注册 Login and register
/*!
 *  用户注册
 *  @param account  账号
 *  @param keyword  密码
 *  @param type     注册类型，0：手机注册  1：email注册
 *  @param code     验证码，通过#getRegisterCode:type获取
 *  @param oem      厂商名称
 *  回调 #jfgLoginResult:
 
 ~English
 *  register
 *  @param account
 *  @param keyword   password
 *  @param type      register Type 0:phone 1:email
 *  @param token     MSM check token（call-back:#jfgSendSMSResult:token） 
                     If the mailbox is registered, please fill in @""
 *  call-back  #jfgLoginResult:
 */
+(void)userRegister:(NSString *)account
            keyword:(NSString *)keyword
       registerType:(NSInteger)type
              token:(NSString *)token;

/**
 *  send SMS code
 *
 *  @param phone     phone
 *  @param type      0:register/binding phone   1:forget password   2:Modify password
 */
+(void)sendSMSWithPhoneNumber:(NSString *)phone type:(int)type;


/**
 *  验证码校验
 *
 *  @param account account
 *  @param code    SMS code
 *  @param token   Gets the token of the callback when the verification code is #jfgSendSMSResult:token:
 */
+(void)verifySMSWithAccount:(NSString *)account
                       code:(NSString *)code
                      token:(NSString *)token;

/*!
 *  用户登录（登录结果通过回调）
 *  @param account 用户名
 *  @param keyword 密码
 *  回调 #jfgLoginResult:
 
 ~English
 *  Login
 *  @param account
 *  @param keyword password
 *  call-back #jfgLoginResult:
 */
+(JFGErrorType)userLogin:(NSString *)account
                 keyword:(NSString *)keyword;


/**
 *  同上
 *
 *  @param account 同上
 *  @param keyword 同上
 *  @param cerType 开发版（bundleID.Dev）或生产版(bundleID)证书标示
 *
 *  @return
 */
+(JFGErrorType)userLogin:(NSString *)account
                 keyword:(NSString *)keyword
                 cerType:(NSString *)cerType;


/**
 md5加密后的密码登陆
 */
+(JFGErrorType)userLogin:(NSString *)account
           keywordForMD5:(NSString *)keyword
                 cerType:(NSString *)cerType;

/**
 *  Logined session
 *
 *  @return session
 */
+(NSString *)getSession;

/**
 * 注销用户登录
 * @return YES 表示成功
 
 ~English
 * Log off
 * @return YES success
 */
+(BOOL)logout;


/*!
 *  第三方登录接口
 *  @param openId   第三方唯一用户标示
 *  @param oem      第三方厂家标示
 *  @param accToken 访问凭证,可能会短期失效
 *  回调 #jfgLoginResult:
 
 ~English
 *  Third-party login
 *  @param openId   Third party unique user mark
 *  @param accToken Access credentials
 *  call-back  #jfgLoginResult:
 */
+(void)openLoginWithOpenId:(NSString *)openId
               accessToken:(NSString *)accToken;



+(void)openLoginWithOpenId:(NSString *)openId
               accessToken:(NSString *)accToken
                   cerType:(NSString *)cerType;

/**
 *  @param loginType  3.QQ Login 4.sina Login 5.user-defined Login
 */
+(void)openLoginWithOpenId:(NSString *)openId
               accessToken:(NSString *)accToken
                   cerType:(NSString *)cerType
                 loginType:(int)loginType;


/*!
 *  获取账号属性
 *  回调 #jfgUpdateAccount:
 
 ~English
 *  get account info
 *  call-back  #jfgUpdateAccount:
 */
+(void)getAccount;

/**
 *  检查账号是否已经注册
 *  check account is register
 
 *  @param account 被检查账号
 */
+(void)checkIsRegisteredForAccount:(NSString *)account;

+(void)isOpenPush:(BOOL)push;

+(void)resetAccountForWxpush:(int)wxpush;

/**
 *  Users upload the picture after the account need to call this method to notify the server
 */
+(void)resetAccountPhoto;

/**
 *  Set account mail or alias
 *
 *  @param email email（Do not set to fill nil）
 *  @param alias alias(Do not set to fill nil)
 */
+(void)resetAccountEmail:(NSString *)email orAlias:(NSString *)alias;

/**
 *  重置绑定手机号
 *
 *  @param phone 手机号
 *  @param token 手机号验证token（#sendSMSWithPhoneNumber:type获取）
 
 ~English
 *  reset binding phone
 *  @param phone
 *  @param token: phone check token
 */
+(void)resetAccountPhone:(NSString *)phone token:(NSString *)token;

/**
 *  修改密码
 *
 *  @param account     账号
 *  @param oldPassword 旧密码
 *  @param newPassword 新密码
 
 ~English
 *  change Password
 *
 *  @param account     account
 *  @param oldPassword old password
 *  @param newPassword new password
 */
+(void)changePasswordWithAccount:(NSString *)account
                     oldPassword:(NSString *)oldPassword
                     newPassword:(NSString *)newPassword;


/**
 *  忘记密码（手机号）
 *
 *  @param account     账号
 *  @param token       短信验证token（获取短信验证码回调）
 *  @param newPassword 新密码
 
 *  forget password

 */
+(void)forgetPasswordWithAccount:(NSString *)account
                           token:(NSString *)token
                     newPassword:(NSString *)newPassword;


/**
 *  忘记密码（邮箱）
 *
 *  @param email 修改的邮箱
 
 *  forget password (email)
 */
+(void)forgetPasswordWithEmail:(NSString *)email;


/**
 *  第三方登录首次绑定手机/邮箱设置密码
 *
 *  @param password 密码
 *  @param type     绑定类型  0-绑定手机 1-绑定邮箱
 *  @param token    #sendSMSWithPhoneNumber:type 获取的token，如果绑定手机号，需要填充，绑定邮箱不需要
 
 *  Third party login first bind phone / mailbox password
 *
 *  @param password password
 *  @param type     bindType  0-phone 1-email
 *  @param token    Get token from #sendSMSWithPhoneNumber:type，If the binding phone number, need to fill, bind mailbox does not need
 */
+(void)setPassword:(NSString *)password forType:(int)type smsToken:(NSString *)token;

#pragma mark- 好友相关
/**
 *  获取好友列表
 
 *  get friend List
 */
+(void)getFriendList;


/**
 *  获取好友请求列表
 
 *  get friend request list
 */
+(void)getFriendRequestList;


/**
 *  删除某个添加好友请求
 *
 *  @param account 请求添加我为好友的账号
 
 *  del add friend request
 *  request add account
 */
+(void)delAddRequestForFriendAccount:(NSString *)account;


/**
 *  发送添加好友请求
 *
 *  @param account      好友账号
 *  @param additionTags 附加问候语
 
 *  Send add friend request
 *  @param account
 *  @param additionTags greetings
 */
+(void)addFriendByAccount:(NSString *)account additionTags:(NSString *)additionTags;


/**
 *  发送删除好友请求
 *
 *  @param account 好友账号
 
 *  send del friend request
 *  @param accoun  friend account
 */
+(void)delFriendByAccount:(NSString *)account;


/**
 *  同意对方加好友的请求
 *
 *  @param account 好友账号
 
 *  Agree with each other to add a friend's request
 *  @param account
 */
+(void)agreeRequestForAddFriendByAccount:(NSString *)account;


/**
 *  设置好友备注名
 *
 *  @param remarkName 备注名
 *  @param account    好友账号
 
 *  set friend nickname
 *  @param remarkName  nickName
 *  @param account  friend account
 */
+(void)setRemarkName:(NSString *)remarkName forFriendByAccount:(NSString *)account;


/**
 *  获取好友备注名
 *
 *  @param account 好友账号
 
 *  get friend nickName
 *  @param account friend account
 */
+(void)getFriendInfoByAccount:(NSString *)account;

/**
 *  检测账号是否注册过
 *
 *  @param account 账号
 
 *  Checking whether the account has been registered
 *  @param  account
 */
+(void)checkFriendIsExistWithAccount:(NSString *)account;

#pragma mark- 分享相关
/**
 *  分享设备给好友
 *
 *  @param cid     设备标示
 *  @param account 好友账号
 */
+(void)shareDevice:(NSString *)cid toFriend:(NSString *)account;

/**
 *  取消分享给好友的设备
 *
 *  @param cid     设备标示
 *  @param account 好友账号
 
 *  Cancel the devices to share your friends
 *  @param cid  device number
 *  @param account friend account
 */
+(void)unShareDevice:(NSString *)cid forFriend:(NSString *)account;

/**
 *  多对多分享
 */
+(void)shareDevices:(NSArray <NSString *> *)cids toFriends:(NSArray <NSString *> *)accounts;

/**
 *  获取设备已分享的好友列表
 *
 *  @param cidList 请求设备标示列表
 
 *  Get a list of friends that have been shared
 *  @param cidList devices number
 */
+(void)getDeviceSharedListForCids:(NSArray <NSString *>*)cidList;

/**
 *  获取某设备未分享的好友列表
 *
 *  @param cid 设备标示
 
 *  Get a device that is not shared by a friend
 *  @param cid  device number
 */
+(void)getUnShareListByCid:(NSString *)cid;



+(void)getVideoShareUrlForFileName:(NSString *)fileName content:(NSString *)content ossType:(int)ossType shareType:(int)shareType;

#pragma mark - UDP通信（局域网通信）UDP signal communication
/*!
 *  fping命令
 *  获取对应ip设备的cid,mac地址，设备版本号，端口信息
 *  @note ip填写255.255.255.255将会扫描局域网内所有设备信息
 *  @param ip 设备ip地址
 *  回调 #jfgFpingRespose:
 
 ~English
 *  fping cmd
 *  Gets the CID corresponds to IP device, mac address, Device software version  version,and port information
 *  @note Fill out IP 255.255.255.255 will all devices in the LAN information
 *  @param ip Device's IP address
 *  call-back #jfgFpingRespose:
 */
+(void)fping:(NSString *)ip;


/*!
 *  ping命令
 *  获取对应ip设备的cid,网络版本类型，端口信息
 *  @note ip填写255.255.255.255将会局域网内所有设备信息
 *  @param ip 设备ip地址
 */
+(void)ping:(NSString *)ip;


/*!
 *  设置设备wifi
 *
 *  @param ssid wifi的ssid
 *  @param key  wifi密码
 *  @param cid  设备标示
 *  @param ip   设备ip
 *  @param mac  设备mac地址
 *
 *  @return 请求发送结果
 */
+(JFGErrorType)wifiSetWithSSid:(NSString *)ssid
                       keyword:(NSString *)key
                           cid:(NSString *)cid
                        ipAddr:(NSString *)ip
                           mac:(NSString *)mac;

/*!
 *  软起AP
 *
 *  @param cid  设备标示
 *  @param ip   设备ip
 *  @param model  1.开启AP   0.关闭AP
 */
+(void)udpSetDevAPForCid:(NSString *)cid
                      ip:(NSString *)ip
                   model:(int)model;

/*!
 *  设置设备速率
 *
 *  @param cid  设备标示
 *  @param ip   设备ip
 *  @param mac  设备mac地址
 *  @param bitrate  0.自动  1.标清  2.高清
 */
+(void)udpSetBitrateForCid:(NSString *)cid mac:(NSString *)mac ip:(NSString *)ip bitrate:(int32_t)bitrate;

#pragma mark - 解绑设备
/**
 * 解绑设备（解绑成功后会触发#jfgDeviceList:回调）
 
 * From the current account unbound devices
 * @param cid
 * call-back #jfgServerPushMessage:
 */
+(void)unBindDev:(NSString *)cid;


/**
 *  刷新绑定设备列表
 
 *  get list of devices already bound
 */
+(void)refreshDeviceList;


/**
 *  检测版本升级,用于摄像头或windows客户端
 *
 *  @param cid     设备标示
 *  @param pid     设备型号ID
 *  @param version 当前版本号
 */
+(void)checkDevVersionWithCid:(NSString *)cid
                          pid:(uint32_t)pid
                      version:(NSString *)version;


/**
 *  整合升级检测
 */
+(void)checkTagDeviceVersionForCid:(NSString *)cid;



/**
 *  局域网内升级设备
 *  @param ip     设备当前ip地址
 *  @param url    用于设备升级的本地文件地址
 */
+(void)deviceUpgreadeForIp:(NSString *)ip
                       url:(NSString *)url
                       cid:(NSString *)cid;


//cylan 8小时升级检测专用
+(void)checkClientVersion;


/**
 *  获取设备别名
 *
 *  @param cid 设备标示
 
 *  get device nickName
 *  @param cid device number
 */
+(void)getAliasForCid:(NSString *)cid;


/**
 *  设置设备别名
 *
 *  @param alias 别名
 *  @param cid   设备标示
 
 *  set device nikeName
 *  @param  alias nickName
 *  @param  cid  device Number
 */
+(void)setAlias:(NSString *)alias forCid:(NSString *)cid;


/**
 *  用户反馈
 *
 *  @param timestamp 时间戳
 *  @param content   反馈内容
 *  @param isSend    接下来是否会上传日志文件（#httpPostWithReqPath:filePath:）
 
 *  user feedback
 */
+(void)sendFeedbackWithTimestamp:(int64_t)timestamp content:(NSString *)content hasSendLog:(BOOL)isSend;


/**
 *  获取反馈未读回复列表
 
 *  get unread feedback msg
 */
+(void)getFeedbackList;


/*!
 * 获取SDK的代码commitId
 
 ~English
 * Access to the SDK code commitId
 */
+(NSString *)getSDKVersion;


/*!
 * 获取当前账号文件存储地区
 
 ~English
 * Get the current account file storage area
 */
+(int)getRegionType;

/*!
 *  萝卜头透传消息
 *
 *  @param message 透传消息体
 *  @return 是否发送成功
 
 ~English
 *  @param message message-body
 */
+(BOOL)robotTransmitMsg:(JFGSDKRobotMessage *)message;


/*!
 *  萝卜头透传消息
 *
 *  @param msgData 透传消息内容
 *  @param cid   设备标示
 *  @param mid   消息号
 *  @return seq  消息标记
 
 ~English
 *  @param msgData message
 */
+(uint64_t)sendUniversalData:(NSData *)msgData cid:(NSString *)cid forMsgID:(int)mid;


+(uint64_t)sendUniversalData:(NSData *)msgData forMsgID:(int)mid NS_DEPRECATED_IOS(1.0, 8.0, "Use +sendUniversalData:cid:forMsgID:") __TVOS_PROHIBITED;

#pragma mark 文件上传
/**
 *  发送数据到云存储
 *
 *  @param filePath  文件完整路径
 *  @param folderPath 上传文件存储路径
 
 *  send data to cloud storage
 *  @param  filePath  File full path
 *  @return -1:failed   other:requestID
 */
+(uint64_t)uploadFile:(NSString *)filePath toCloudFolderPath:(NSString *)folderPath;


/**
 * @brief 获取带签名的云存储URL
 * @param regionType 文件存储地区标识，如美国，中国等。
 * @param url 云存储URL
 */
+(NSString *)getCloudUrlWithFlag:(int)regionType fileName:(NSString *)fileName;


/**
 *  copy cloud file to wonder
 *
 *  @param cloudFilePath cloud file path
 *  @param wonderPath    wonder storage path
 *  @param requestId     request id
 */
+(void)copyCloudFile:(NSString *)cloudFilePath toWonderPath:(NSString *)wonderPath requestId:(uint64_t)requestId;


/*!
 * 进行HTTP POST上传文件
 * @param url 请求地址
 * @param filePath 文件路径,如果不存在会转换成 #HttpGet 操作
 * @return 请求ID, 此调用是异步请求,稍后会有 #JFG_EVENT_ID_TOOLS_HTTP_DONE 消息提示是否成功
 * @note 可通过修改文件JFGSDKConstans.h 中JFGHTTP_PORT的值，来替换请求的post
 */
+(int)httpPostWithReqPath:(NSString *)reqPath filePath:(NSString *)filePath;


+(uint64_t)sendMsgForTcpWithDst:(NSArray <NSString *>*)dst isAck:(BOOL)isAck fileType:(int)fileType msg:(NSData *)msg;

+(uint64_t)sendMsgForTcpDownloadWithDst:(NSArray <NSString *>*)dst fileName:(NSString *)fileName md5:(NSString *)md5 begin:(int)begin offset:(int)offset;

+(uint64_t)sendDPDataMsgForSockWithPeer:(NSString *)peer dpMsgIDs:(NSArray <DataPointSeg *>*)dpMsgIDs;

//广告位相关
+(void)getAdPolicyForLanguage:(int)language version:(NSString *)version resolution:(NSString *)resolution;

//广告位点击数统计
+(void)statisticsADClickForLanguage:(int)language version:(NSString *)version tapUrl:(NSString *)tapUrl;

@end
