//
//  FLShareSDKRegister.h
//  SimpleShareSDK
//
//  Created by 紫贝壳 on 15/8/18.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import <ShareSDKExtension/SSEBaseUser.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>

@interface FLShareSDKHelper : NSObject

#pragma mark 配置
//配置sdk
+(void)registerPlatforms;

#pragma mark 第三方登陆
/**
 *  qq登录
 *
 *  @param loginResult   登录返回事件处理
 */
+(void)qqForThirdPartyLoginWithlogintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult;

/**
 *  微信登陆
 *
 *  @param loginResult   登录返回事件处理
 */
+(void)webChatForThirdPartyLoginWithlogintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult;

/**
 *  新浪微博登陆
 *
 *  @param loginResult   登录返回事件处理
 */
+(void)sinaWebForThirdPartyLoginWithlogintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult;

+(void)thirdPartyLoginForSSDKPlatformType:(SSDKPlatformType)PlatformType logintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult;

/**
 *  取消第三方登录授权
 */
+(void)loginOut;

/**
 *  当前第三方登录用户, 如果为nil则表示尚未有用户进行登陆
 *
 *  @return 用户信息
 */
+(SSEBaseUser *)currentUser;

/**
 *  获取当前已登录的第三方用户集合, 集合中元素为SSEBaseUser
 *
 *  @return 用户集合
 */
+ (NSDictionary *)users;

/**
 *  切换用户
 *
 *  @param user 用户信息
 *  @return YES 切换成功，NO 切换失败
 */
+ (BOOL)changeUser:(SSEBaseUser *)user;


/**
 *SSEBaseUser转SSDKUser
 *
 */
+(SSDKUser *)SSDKUserBySSEBaseUser:(SSEBaseUser *)baseUser;

+(BOOL)isInstalledQQ;
#pragma mark 分享

/**
 分享(iPhone版)
 注意:1.此函数只提供微信，新浪微博与QQ分享，且分享内容为图片，文字，链接，标题的形式
     2.只有安装了微信，QQ客户端才会显示相关分享
     3.image 参数为空可能导致QQ分享功能失效
 
 */
+(void)showShareActionSheetWithtitle:(NSString *)title
                                 url:(NSString *)url
                               image:(UIImage *)image
                             content:(NSString *)content;


@end
