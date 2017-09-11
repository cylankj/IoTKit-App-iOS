//
//  FLShareSDKRegister.m
//  SimpleShareSDK
//
//  Created by 紫贝壳 on 15/8/18.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "FLShareSDKHelper.h"
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerSharer.h>
#import "OemManager.h"
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "ProgressHUD.h"
#import "JfgLanguage.h"
#import "LSAlertView.h"
#import "CommonMethod.h"

static BOOL isRegister = NO;
#define ShareSDKOpenLoginPlatformTypeKey @"ShareSDKOpenLoginPlatformType"
 
 /**
 *  基础用户信息对象
 @interface SSEBaseUser : NSObject <NSCoding>
  
 *  关联标识, 能够与应用用户系统中的用户唯一对应的标识
 @property (nonatomic, copy, readonly) NSString *linkId;
  
 *  关联的社交用户信息
 @property (nonatomic, strong, readonly) NSDictionary *socialUsers;
 **/


@implementation FLShareSDKHelper


+(void)registerPlatforms
{
    if (isRegister) {
        return;
    }
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformTypeQQ),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeTwitter),
                                        @(SSDKPlatformTypeFacebook),
                                        @(SSDKPlatformTypeFacebookMessenger)] onImport:^(SSDKPlatformType platformType) {
                                            
                                            switch (platformType)
                                            {
                                                case SSDKPlatformTypeWechat:
                                                    [ShareSDKConnector connectWeChat:[WXApi class]];
                                                    break;
                                                case SSDKPlatformTypeQQ:
                                                    [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                                                    break;
                                                case SSDKPlatformTypeSinaWeibo:
                                                    [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                                                    break;
                                                case SSDKPlatformTypeFacebook:
                                                    [ShareSDKConnector connectFacebookMessenger:[FBSDKMessengerSharer class]];
                                                    break;
                                                default:
                                                    break;
                                            }
                                            
                                        } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                                            
                                            switch (platformType)
                                            {
                                                case SSDKPlatformTypeSinaWeibo:
                                                    //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                                                    if ([OemManager oemType] == oemTypeDoby) {
                                                        //1821035549
                                                        [appInfo SSDKSetupSinaWeiboByAppKey:@"2444488421"
                                                                                  appSecret:@"dfba216fe44f0d6613cdda1557790a31"
                                                                                redirectUri:@"https://api.weibo.com/oauth2/default.html"
                                                                                   authType:SSDKAuthTypeWeb];
                                                    }else{
                                                        [appInfo SSDKSetupSinaWeiboByAppKey:@"1315129656"
                                                                                  appSecret:@"5feab23e093b43f220bccf7fbab8f6c5"
                                                                                redirectUri:@"https://api.weibo.com/oauth2/default.html"
                                                                                   authType:SSDKAuthTypeWeb];
                                                    }
                                                    
                                                    break;
                                                    
                                                case SSDKPlatformTypeWechat:
                                                    //设置微信应用信息
                                                    if ([OemManager oemType] == oemTypeDoby) {
                                                        //
                                                        [appInfo SSDKSetupWeChatByAppId:@"wx81d893be5216671c"
                                                                              appSecret:@"b867a2e433701bc00dffda2099655d7e"];
                                                        
                                                    }else{
                                                        [appInfo SSDKSetupWeChatByAppId:@"wx3081bcdae8a842cf"
                                                                              appSecret:@"d93676ab7db1876c06800dee3f33fbc2"];
                                                    }
                                                    
                                                    break;
                                                case SSDKPlatformTypeQQ:
                                                    //设置QQ应用信息
                                                    //1104534926
                                                    //eePT24ZjUbNtk15J
                                                    if ([OemManager oemType] == oemTypeDoby){
                                                        [appInfo SSDKSetupQQByAppId:@"1106284318"
                                                                             appKey:@"SclSnTkp5NBWOhRi"
                                                                           authType:SSDKAuthTypeBoth];
                                                    }else{
                                                        [appInfo SSDKSetupQQByAppId:@"1103156296"
                                                                             appKey:@"lfQJHRh8dDCJtwHu"
                                                                           authType:SSDKAuthTypeBoth];
                                                    }
                                                    break;
                                                case SSDKPlatformTypeFacebook:
                                                    //107704292745179  38053202e1a5fe26c80c753071f0b573
                                                    //1866682200216878  202470e7abebe2cd768432fa3e96914e
                                                    //设置Facebook应用信息，其中authType设置为只用SSO形式授权
                                                    //
                                                    if ([OemManager oemType] == oemTypeDoby) {
                                                        [appInfo SSDKSetupFacebookByApiKey:@"1698182270477391" appSecret:@"cdb4c9fafd8cb88baba5ad91ee9529fc"  authType:SSDKAuthTypeBoth];
                                                    }else{
                                                        [appInfo SSDKSetupFacebookByApiKey:@"1866682200216878" appSecret:@"202470e7abebe2cd768432fa3e96914e"  authType:SSDKAuthTypeBoth];
                                                    }
                                                    
                                                    break;
                                                    
                                                case SSDKPlatformTypeTwitter:
                                                    
                                                    if ([OemManager oemType] == oemTypeDoby) {
                                                        [appInfo SSDKSetupTwitterByConsumerKey:@"P4mZddIEumAsk7OnzNWpcrQy8" consumerSecret:@"1T5Pg7UBRVkq6OSvOs9EBEGiMXVLYmAeOdW3HPTazuqjWyzRAm"
                                                                                   redirectUri:@"http://www.cylan.com.cn"];
                                                    }else{
                                                        [appInfo SSDKSetupTwitterByConsumerKey:@"kCEeFDWzz5xHi8Ej9Wx6FWqRL" consumerSecret:@"Ih4rUwyhKreoHqzd9BeIseAKHoNRszi2rT2udlMz6ssq9LeXw5"
                                                                                   redirectUri:@"http://www.jfgou.com"];
                                                    }
                                                    break;
                                                    
                                                default:
                                                    break;
                                            }
                                            
                                            
                                        }];
    
    
    
//    [ShareSDK registerApp:@"9bccc566e729"
//          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
//                            @(SSDKPlatformTypeQQ),
//                            @(SSDKPlatformTypeWechat),
//                            @(SSDKPlatformTypeTwitter),
//                            @(SSDKPlatformTypeFacebook),
//                            @(SSDKPlatformTypeFacebookMessenger)]
//                 onImport:^(SSDKPlatformType platformType) {
//                     
//                     switch (platformType)
//                     {
//                         case SSDKPlatformTypeWechat:
//                             [ShareSDKConnector connectWeChat:[WXApi class]];
//                             break;
//                         case SSDKPlatformTypeQQ:
//                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
//                             break;
//                         case SSDKPlatformTypeSinaWeibo:
//                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
//                             break;
//                         case SSDKPlatformTypeFacebook:
//                             [ShareSDKConnector connectFacebookMessenger:[FBSDKMessengerSharer class]];
//                             break;
//                         default:
//                             break;
//                     }
//                     
//                 }
//          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
//              
//              switch (platformType)
//              {
//                  case SSDKPlatformTypeSinaWeibo:
//                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
//                      if ([OemManager oemType] == oemTypeDoby) {
//                          //1821035549
//                          [appInfo SSDKSetupSinaWeiboByAppKey:@"2444488421"
//                                                    appSecret:@"dfba216fe44f0d6613cdda1557790a31"
//                                                  redirectUri:@"https://api.weibo.com/oauth2/default.html"
//                                                     authType:SSDKAuthTypeWeb];
//                      }else{
//                          [appInfo SSDKSetupSinaWeiboByAppKey:@"1315129656"
//                                                    appSecret:@"5feab23e093b43f220bccf7fbab8f6c5"
//                                                  redirectUri:@"https://api.weibo.com/oauth2/default.html"
//                                                     authType:SSDKAuthTypeWeb];
//                      }
//                      
//                      break;
//                  
//                  case SSDKPlatformTypeWechat:
//                      //设置微信应用信息
//                      if ([OemManager oemType] == oemTypeDoby) {
//                          //
//                          [appInfo SSDKSetupWeChatByAppId:@"wx81d893be5216671c"
//                                                appSecret:@"b867a2e433701bc00dffda2099655d7e"];
//                          
//                      }else{
//                          [appInfo SSDKSetupWeChatByAppId:@"wx3081bcdae8a842cf"
//                                                appSecret:@"d93676ab7db1876c06800dee3f33fbc2"];
//                      }
//                      
//                      break;
//                  case SSDKPlatformTypeQQ:
//                      //设置QQ应用信息
//                      //1104534926
//                      //eePT24ZjUbNtk15J
//                      if ([OemManager oemType] == oemTypeDoby){
//                          [appInfo SSDKSetupQQByAppId:@"1106284318"
//                                               appKey:@"SclSnTkp5NBWOhRi"
//                                             authType:SSDKAuthTypeBoth];
//                      }else{
//                          [appInfo SSDKSetupQQByAppId:@"1103156296"
//                                               appKey:@"lfQJHRh8dDCJtwHu"
//                                             authType:SSDKAuthTypeBoth];
//                      }
//                      break;
//                  case SSDKPlatformTypeFacebook:
//                      //107704292745179  38053202e1a5fe26c80c753071f0b573
//                      //1866682200216878  202470e7abebe2cd768432fa3e96914e
//                      //设置Facebook应用信息，其中authType设置为只用SSO形式授权
//                      //
//                      if ([OemManager oemType] == oemTypeDoby) {
//                          [appInfo SSDKSetupFacebookByApiKey:@"1698182270477391" appSecret:@"cdb4c9fafd8cb88baba5ad91ee9529fc"  authType:SSDKAuthTypeBoth];
//                      }else{
//                          [appInfo SSDKSetupFacebookByApiKey:@"1866682200216878" appSecret:@"202470e7abebe2cd768432fa3e96914e"  authType:SSDKAuthTypeBoth];
//                      }
//                      
//                      break;
//                      
//                  case SSDKPlatformTypeTwitter:
//                      
//                      if ([OemManager oemType] == oemTypeDoby) {
//                          [appInfo SSDKSetupTwitterByConsumerKey:@"P4mZddIEumAsk7OnzNWpcrQy8" consumerSecret:@"1T5Pg7UBRVkq6OSvOs9EBEGiMXVLYmAeOdW3HPTazuqjWyzRAm"
//                                                     redirectUri:@"http://www.cylan.com.cn"];
//                      }else{
//                          [appInfo SSDKSetupTwitterByConsumerKey:@"kCEeFDWzz5xHi8Ej9Wx6FWqRL" consumerSecret:@"Ih4rUwyhKreoHqzd9BeIseAKHoNRszi2rT2udlMz6ssq9LeXw5"
//                                                     redirectUri:@"http://www.jfgou.com"];
//                      }
//                    break;
//                      
//                  default:
//                      break;
//              }
//          }];
    

    isRegister = YES;

}



+(BOOL)isInstalledQQ
{
    return [ShareSDK isClientInstalled:SSDKPlatformTypeQQ];
}

#pragma mark 登陆
+(void)thirdPartyLoginForSSDKPlatformType:(SSDKPlatformType)PlatformType logintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult
{
    [SSEThirdPartyLoginHelper loginByPlatform:PlatformType onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
        
        //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
        //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
        NSLog(@"%@%@",user.uid,user.nickname);
        associateHandler (user.uid, user, user);
        
        
    } onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        //SSEBaseUser
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ShareSDKOpenLoginPlatformTypeKey];
        [[NSUserDefaults standardUserDefaults] setInteger:PlatformType forKey:ShareSDKOpenLoginPlatformTypeKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            loginResult(state,user,error);
        });
        
        
        if (state == SSDKResponseStateSuccess)
        {
            
            NSLog(@"第三方登录授权成功");
            
        }
        
    }];
}



//qq登陆
+(void)qqForThirdPartyLoginWithlogintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult
{
    [self thirdPartyLoginForSSDKPlatformType:SSDKPlatformTypeQQ logintResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            loginResult(state,user,error);
        });
        
    }];
}



//微信登陆
+(void)webChatForThirdPartyLoginWithlogintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult
{
    [self thirdPartyLoginForSSDKPlatformType:SSDKPlatformTypeWechat logintResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            loginResult(state,user,error);
        });
        
        
    }];
}

//新浪微博登陆
+(void)sinaWebForThirdPartyLoginWithlogintResult:(void(^)(SSDKResponseState state, SSEBaseUser *user, NSError *error))loginResult
{
    [self thirdPartyLoginForSSDKPlatformType:SSDKPlatformTypeSinaWeibo logintResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            loginResult(state,user,error);
        });
        
    }];
}

/**
 注销用户
 */
+(void)loginOut
{
    [SSEThirdPartyLoginHelper logout:[SSEThirdPartyLoginHelper currentUser]];
    SSDKPlatformType platformType = (SSDKPlatformType)[[NSUserDefaults standardUserDefaults] integerForKey:ShareSDKOpenLoginPlatformTypeKey];
    [ShareSDK cancelAuthorize:platformType];
}



/**
 当前登录用户, 如果为nil则表示尚未有用户进行登陆
 */
+(SSEBaseUser *)currentUser
{
    return [SSEThirdPartyLoginHelper currentUser];
}

/**
 获取当前已登录的用户集合, 集合中元素为SSEBaseUser
 */
+ (NSDictionary *)users
{
    return [SSEThirdPartyLoginHelper users];
}

/**
 切换用户
 */
+ (BOOL)changeUser:(SSEBaseUser *)user
{
    return [SSEThirdPartyLoginHelper changeUser:user];
}


#pragma mark 分享

/**
 分享
 注意:此函数只提供微信，新浪微博与QQ分享，且分享内容为图片，文字，链接，标题的形式
 */
+(void)showShareActionSheetWithtitle:(NSString *)title
                                 url:(NSString *)url
                               image:(UIImage *)image
                             content:(NSString *)content
{
    //1、创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:image
                                        url:[NSURL URLWithString:url]
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    //2.创建分享菜单
    SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:nil
                                     items:nil
                               shareParams:shareParams
                       onShareStateChanged:^(
                                             SSDKResponseState state,
                                             SSDKPlatformType platformType,
                                             NSDictionary *userData,
                                             SSDKContentEntity *contentEntity,
                                             NSError *error, BOOL end) {
                           
                           [self shareStateChangedWithResponseState:state platformType:platformType userData:userData contentEdtity:contentEntity error:error end:end];
                           
                       }];
    
    //去掉这行函数当选择分享平台时，会弹出分享内容编辑窗口
    [sheet.directSharePlatforms addObject:@(SSDKPlatformSubTypeWechatTimeline)];
}



/**
 *  分享状态变更
 *
 *  @param state         返回状态
 *  @param platformType  平台类型
 *  @param userData      用户数据
 *  @param contentEntity 分享内容实体
 *  @param error         错误信息
 *  @param end           是否已经结束本次分享标识
 */
 
+(void)shareStateChangedWithResponseState:(SSDKResponseState)state
                             platformType:(SSDKPlatformType)platformType userData:(NSDictionary *)userData
                            contentEdtity:(SSDKContentEntity *)contentEntity
                                    error:(NSError *)error
                                      end:(BOOL)end
{

    NSLog(@"state:%lu,error:%@",(unsigned long)state,error);
    
}


+(SSDKUser *)SSDKUserBySSEBaseUser:(SSEBaseUser *)baseUser
{
    NSDictionary *dict = baseUser.socialUsers;
    
    __block SSDKUser *user = nil;
    
    [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        if (obj) {
            
            
            if ([obj isKindOfClass:[SSDKUser class]]) {
                
                user = obj;
                *stop = YES;
            }
        }
    }];
    
    return user;
}

+(void)shareToFacebookWithContentText:(NSString *)text title:(NSString *)title image:(UIImage *)image url:(NSString *)url contentType:(SSDKContentType)contentType
{
    if (image) {
        
        [SSUIEditorViewStyle setTitle:@"Share To Facebook"];
        
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:@[image]
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        [ShareSDK showShareEditor:SSDKPlatformTypeFacebook
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             
             if (error) {
                 
                 NSLog(@"faceBook分享错误：userInfo:%@",error);
                 if (error.code == 0) {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
                 
                 
             }
             
             switch (state) {
                     
                 case SSDKResponseStateBegin:
                 {
                     //[theController showLoadingView:YES];
                     break;
                 }
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 default:
                     break;
             }
             
             if (state != SSDKResponseStateBegin)
             {
                 
             }
         }];
    }
    
}

+(void)shareToTwitterWithContentText:(NSString *)text title:(NSString *)title image:(UIImage *)image url:(NSString *)url
{
    if (image) {
        
        [SSUIEditorViewStyle setTitle:@"Share To Twitter"];
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:@[image]
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        [ShareSDK showShareEditor:SSDKPlatformTypeTwitter
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             
             if (error) {
                 if (error.code == 0) {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
             }
             
             switch (state) {
                     
                 case SSDKResponseStateBegin:
                 {
                     break;
                 }
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     // [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     // [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 default:
                     break;
             }
             
             if (state != SSDKResponseStateBegin)
             {
                 
             }
         }];
    }
    
}

+(void)shareToThirdpartyPlatform:(SSDKPlatformType)platformType url:(NSString *)url image:(UIImage *)image title:(NSString *)title contentType:(SSDKContentType)contentType
{
    if (platformType == SSDKPlatformSubTypeWechatSession || platformType == SSDKPlatformSubTypeWechatTimeline) {
        if (![ShareSDK isClientInstalled:platformType]) {
            NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],[JfgLanguage getLanTextStrByKey:@"WeChat"]];
            [ProgressHUD showText:als];
            return;
        }
        
    }else if (platformType == SSDKPlatformSubTypeQQFriend || platformType ==SSDKPlatformSubTypeQZone){
        if (![ShareSDK isClientInstalled:SSDKPlatformSubTypeQQFriend]) {
            NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],@"QQ"];
            [ProgressHUD showText:als];
            return;
        }
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    SSDKPlatformType shareType = platformType;
    
    if (shareType ==SSDKPlatformSubTypeWechatTimeline || shareType ==SSDKPlatformSubTypeWechatSession) {
        
        //微信
        if (contentType == SSDKContentTypeImage) {
            [parameters SSDKSetupWeChatParamsByText:@"" title:title url:[NSURL URLWithString:url] thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeImage forPlatformSubType:shareType];
        }else{
            [parameters SSDKSetupWeChatParamsByText:@"" title:title url:[NSURL URLWithString:url] thumbImage:image image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:shareType];
        }
        
        
    }else if (shareType == SSDKPlatformTypeSinaWeibo){
    
        //新浪微博
        [parameters SSDKSetupSinaWeiboShareParamsByText:[OemManager appName] title:title image:image url:[NSURL URLWithString:url] latitude:0 longitude:0 objectID:nil type:SSDKContentTypeAuto];
        
    }else if (shareType == SSDKPlatformSubTypeQQFriend || shareType == SSDKPlatformSubTypeQZone){
        
        //QQ
        [parameters SSDKSetupQQParamsByText:@"" title:title url:[NSURL URLWithString:url] thumbImage:nil image:[CommonMethod thumbnailWithImageWithoutScale:image size:CGSizeMake(500, 500)] type:contentType forPlatformSubType:SSDKPlatformSubTypeQQFriend];
        shareType = SSDKPlatformSubTypeQQFriend;
        
    }else if (shareType == SSDKPlatformTypeFacebook){
        
        //Facebook
        //[parameters SSDKSetupFacebookParamsByText:@"" image:image url:[NSURL URLWithString:url] urlTitle:title urlName:@"" attachementUrl:nil type:contentType];
        [[self class] shareToFacebookWithContentText:@"" title:title image:image url:url contentType:contentType];
        return;
        
    }else if (shareType == SSDKPlatformTypeTwitter){
        
        NSString *text = [NSString stringWithFormat:@"%@\n%@",title,url];
        [[self class] shareToTwitterWithContentText:text title:@"" image:image url:url];
        return;
        
    }
    
    //__weak typeof(self) weakself = self
    [ShareSDK share:shareType parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         if (error) {
             if (error.code == 0) {
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
             }else{
                 //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
             }
             NSLog(@"shareError:%@",error);
         } else {
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
                     break;
                 }
                 default:
                     break;
             }
         }
         
     }];
}


+(void)shareForSinaweibo:(UIImage *)image
{
    NSMutableDictionary *sharePatam = [NSMutableDictionary dictionary];
    [sharePatam SSDKSetupShareParamsByText:@"shareContent" images:[CommonMethod thumbnailWithImageWithoutScale:image size:CGSizeMake(500, 500)] url:[NSURL URLWithString:@"http://cylan.jfg.com"] title:@"title" type:SSDKContentTypeAuto];
    
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:sharePatam onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        if (error) {
            NSLog(@"%@",error);
        }
        NSLog(@"%lu",(unsigned long)state);
        
    }];
}

@end
