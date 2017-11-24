//
//  CommonMethod.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <JFGSDK/JFGSDK.h>
#import "JfgConfig.h"
#import "SFCParamModel.h"

@interface CommonMethod : NSObject

/**
 *  获取view所属的ViewController
 */
+ (UIViewController *)viewControllerForView:(UIView *)view;

+ (UIViewController *)getCurrentVC;

/**
 *  通信录 获取
 *
 *  @param addressBook ABAddressBookRef
 *
 *  @return 可变 数组
 */
+ (NSMutableArray *)copyAddressBook:(ABAddressBookRef)addressBook;
+ (NSMutableArray *)copyAddressBook;

/**
 *  当前连接 wifi
 *
 *  @return wifi String
 */
+ (NSString *)currentConnecttedWifi;

/**
 *  是否 是wifi连接
 *
 */
+ (BOOL)isWifiConnectted;

/**
 *  是否 连接了 任意一个 ap
 *  使用场景： 绑定设备，目前你还不知道cid，需 传入 pid
 */
+ (BOOL)isConnecttedDeviceWifiWithPid:(int)productID;
/**
 *  是否连接 当前cid 的 ap
 *  使用场景： 功能设置 给设备 配置wifi
 *  @param productID pid
 *  @param cid       cid
 *
 *  @return 是否
 */
+ (BOOL)isConnectedAPWithPid:(int)productID Cid:(NSString *)cid;
/**
 *  压缩日志
 *
 *  @param fileName 压缩包名字：log.zip
 *
 *  @return 返回压缩包的路径
 */
+(NSString *)appendAPNameWithPid:(int)productID Cid:(NSString *)cid;
+ (NSString *)logZipPath:(NSString *)fileName;

/**
 *  获取登陆错误码多语言
 *
 *  @param error 登录相关错误码
 *
 *  @return 多语言字符串
 */
+(NSString *)languageKeyForLoginErrorType:(JFGErrorType)error;

/**
 *  直播类错误码多语言
 *
 *  @param error 直播类错误码
 *
 *  @return 错误码对应的多语言
 */
+(NSString *)languaeKeyForLiveVideoErrorType:(JFGErrorType)error;

/**
 *  分享设备类错误码多语言
 */
+(NSString *)languageKeyForShareDeviceErrorType:(JFGErrorType)error;

/**
 *  添加亲友
 */
+(NSString *)languageKeyForAddFriendErrorType:(JFGErrorType)error;

/**
 *  获取头像oss链接
 *
 *  @param account 头像所属账号
 *
 *  @return 头像url
 */
+(NSString *)headImageUrlForAccount:(NSString *)account;

/**
 *  日志上传地址
 *
 *  @param account 上传日志用户账号
 *
 *  @return 上传地址
 */
+(NSString *)uplodUrlForLogWithAccount:(NSString *)account timestamp:(int64_t)timestamp;

/**
 *  上传头像地址
 *
 *  @param account 账号
 *
 *  @return Url
 */
+(NSString *)uplodUrlForHeadImageWithAccount:(NSString *)account;


/**
 *  显示其他用户头像
 *
 *  @param account   用户账号
 */
+(void)setHeadImageForImageView:(UIImageView *)imageView account:(NSString *)account;


/**
 *  获取头像链接
 *
 *  @param account 账号（nil或者@“” 获取已登录用户头像）
 *
 *  @return 头像链接
 */
+(NSString *)getCloudHeadImageForAccount:(NSString *)account;

/*
 *  部分720设备局域网请求链接
 */
+(NSString *)urlForLANFor720DevWithReqType:(JFG720DevLANReqUrlType)type ipAdd:(NSString *)ipAdd;

/**
 *  显示网络连接失败轻提示
 */
+(void)showNetDisconnectAlert;

///**
// * 设备被其他端删除界面跳转处理
// */
//+(void)delDeviceByOtherClientWithNotification:(NSNotification *)notification cid:(NSString *)vcCid superViweController:(UIViewController *)vc;

/**
 * UIAlertSheetView 弹出动画时间
 */
+(NSTimeInterval)sheetAnimationTimeIntervalForHeight:(CGFloat)height;

//十进制转二进制
+(NSString *)toBinarySystemWithDecimalSystem:(NSInteger)decimal;

//二进制转十进制
+(NSString *)toDecimalSystemWithBinarySystem:(NSString *)binar;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (NSString *)formatPhoneNum:(NSString *)phone;

#pragma mark 
#pragma mark  -- 设备类型判断
/**
 * 是否 是 摄像头
 */
+ (BOOL)isCameraWithType:(NSInteger)pType;
/*
    是否是 全景摄像头
 */
+ (BOOL)isPanoCameraWithType:(NSInteger)pType;

+ (BOOL)isDeviceHasBattery:(NSInteger)pType;

+ (BOOL)isDeviceBlockUpgrade:(NSInteger)pType;

+(NSString*)deviceType;// 需要#import "sys/utsname.h"

+(JFGDevViewType)devBigTypeForOS:(NSString *)os;

+(BOOL)isSingleFisheyeCameraForCid:(NSString *)cid;

//全角占2个字符，半角占一个字符
+(NSInteger)lenghtForString:(NSString *)string;

+(UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

//获取配置plist
+(NSDictionary *)jfgConfigPlist;

+(UIImage *)sdwebImageCacheForKey:(NSString *)key;

+(NSString *)sdwebImageDefauleCachePathForKey:(NSString *)key;

//判断手机网络是否连接此设备ap
+(BOOL)isAPModelCurrentNetForCid:(NSString *)cid pid:(NSString *)pid;

+(SFCParamModel *)panoramicViewParamModelForCid:(NSString *)cid;


@end
