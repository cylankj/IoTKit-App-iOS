//
//  LoginManager.h
//
//
//  Created by 杨利 on 16/5/26.
//  Copyright © 2016年 . All rights reserved.
//
/**
 *  所有登陆相关操作，请使用本类
 */

#import <Foundation/Foundation.h>
#import <JFGSDK/JFGSDK.h>

@protocol LoginManagerDelegate;


typedef NS_ENUM(NSInteger,JFGSDKLoginType){
    
    JFGSDKLoginTypeAccountLogin = 0,//账号登陆
    JFGSDKLoginTypeOpenLoginForQQ = 1,//第三方QQ登陆
    JFGSDKLoginTypeOpenLoginForSinaWeibo = 2,//新浪微博登录
    JFGSDKLoginTypeOpenLoginForTwitter,
    JFGSDKLoginTypeOpenLoginForFacebook,
    
};

/**
 *  登录状况
 */
typedef NS_ENUM(NSInteger,JFGSDKLoginStatus) {
    /**
     *  登录正常
     */
    JFGSDKCurrentLoginStatusSuccess = 0,
    
    /**
     *  退出登录(用户主动退出，修改密码，服务端强制退出)
     */
    JFGSDKCurrentLoginStatusLoginOut,
    
    /**
     *  登录失败
     */
    JFGSDKCurrentLoginStatusLoginFailed,
    
    /**
     *  登录中...
     */
    JFGSDKCurrentLoginStatusLogining,
};

@interface LoginManager : NSObject

/**
 *  登录状态，不保存历史状态
 */
@property (nonatomic,assign)JFGSDKLoginStatus loginStatus;

/**
 *  登录类型
 */
@property (nonatomic,assign)JFGSDKLoginType loginType;

/**
 *  最后一次执行登录操作的账号（即使退出登录也会保存）
 *
 *  @note nil 没有登录过
 */
@property (nonatomic,readonly)NSString *currentLoginedAcount;

/**
 *  AI相关请求authtoken
 */
@property (nonatomic,readonly)NSString *aiReqAuthToken;

/**
 *  账号缓存信息(已登录)
 *
 *  @return 账号信息对象
 */
-(JFGSDKAcount *)accountCache;

/**
 *是否已经退出登录（记录历史情况）
 */
-(BOOL)isExited;

/**
 *  单例
 *
 *  @return 获取当前登录状态
 */
+(instancetype)sharedManager;

/**
 *  使用账号密码登录(账号密码会自动存储到钥匙串)
 *
 *  @param account  账号
 *  @param password 密码
 */
-(void)loginWithAccount:(NSString *)account password:(NSString *)password;


/**
 *  qq登录
 */
-(void)openLoginByQQ;


/**
 *  微博登录
 */
-(void)openLoginByweibo;


/**
 *  其他第三方登录
 */
-(void)openLoginByType:(JFGSDKLoginType)type;


/**
 *  使用最后一次成功登录的账号登录
 */
-(void)loginForLastTimeAccount;


/**
 *  退出登录
 *
 *  @return 退出登录是否执行成功
 */
-(BOOL)loginOut;


-(void)addDelegate:(id<LoginManagerDelegate>)delegate;


-(void)removeDelegate:(id<LoginManagerDelegate>)delegate;

@end


@protocol LoginManagerDelegate <NSObject>

@optional

//登录成功
-(void)loginSuccess;

//登录失败
-(void)loginFail:(JFGErrorType)error;

//退出登录（其他端修改密码，服务器强制退出以及用户执行loginOut）
-(void)loginOut;

//服务器强制退出登录
-(void)loginOutForServer:(JFGErrorType)error;

@end
